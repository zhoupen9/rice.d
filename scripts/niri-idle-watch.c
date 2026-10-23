/*
 * niri-idle-watch - print a waybar-ready countdown until idle screen lock.
 *
 * usage: niri-idle-watch <lock-timeout-seconds> <state-file>
 *
 * It listens to the compositor's ext-idle-notify-v1 protocol, so it follows
 * the same input-idle definition as hypridle.  A single 1 second notification
 * is used; after it fires the remaining idle time is counted locally and the
 * countdown is emitted as one JSON object per line for waybar's custom module.
 *
 * The state file contains "on" or "off".  Missing/anything else means "on".
 */

#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <poll.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <wayland-client.h>

#include "ext-idle-notify-v1-client-protocol.h"

struct idle_watch {
    struct wl_display *display;
    struct wl_registry *registry;
    struct wl_seat *seat;
    struct ext_idle_notifier_v1 *notifier;
    struct ext_idle_notification_v1 *notification;

    const char *state_file;
    long lock_timeout;

    bool enabled;
    bool idle;
    long idle_seconds;
    struct timespec next_tick;
};

static void format_duration(long seconds, char *buf, size_t len)
{
    long h, m, s;

    if (seconds < 0)
        seconds = 0;

    h = seconds / 3600;
    m = (seconds % 3600) / 60;
    s = seconds % 60;

    if (h > 0)
        snprintf(buf, len, "%ld:%02ld:%02ld", h, m, s);
    else
        snprintf(buf, len, "%02ld:%02ld", m, s);
}

static bool read_enabled(const char *path)
{
    char buf[32];
    FILE *f;

    f = fopen(path, "r");
    if (!f)
        return true;

    if (!fgets(buf, sizeof(buf), f)) {
        fclose(f);
        return true;
    }
    fclose(f);

    buf[strcspn(buf, "\r\n")] = '\0';
    return strcmp(buf, "off") != 0;
}

static void print_state(struct idle_watch *w)
{
    char remaining[32], idle_text[32], text[64], tooltip[512];
    const char *icon, *cls;
    long left;

    left = w->lock_timeout - w->idle_seconds;
    if (left < 0)
        left = 0;

    format_duration(left, remaining, sizeof(remaining));
    format_duration(w->idle_seconds, idle_text, sizeof(idle_text));

    if (!w->enabled) {
        icon = "\xf3\xb0\x8c\xbf"; /* nf-md-lock_open */
        cls = "disabled";
        snprintf(text, sizeof(text), "%s off", icon);
        snprintf(tooltip, sizeof(tooltip),
                 "Idle screen lock: <b>OFF</b>\\n"
                 "Idle: %s\\n"
                 "Left click to enable\\n\\n"
                 "Manual lock (Mod+L) still works.",
                 idle_text);
    } else {
        icon = "\xf3\xb0\x8c\xbe"; /* nf-md-lock */
        if (left == 0)
            cls = "critical";
        else if (left <= 60)
            cls = "warning";
        else
            cls = "enabled";

        snprintf(text, sizeof(text), "%s %s", icon, remaining);
        if (left == 0)
            snprintf(tooltip, sizeof(tooltip),
                     "Idle screen lock: <b>ON</b>\\n"
                     "Idle: %s\\n"
                     "Locking now...\\n\\n"
                     "Left click to disable",
                     idle_text);
        else
            snprintf(tooltip, sizeof(tooltip),
                     "Idle screen lock: <b>ON</b>\\n"
                     "Idle: %s\\n"
                     "Locks in: %s\\n\\n"
                     "Left click to disable",
                     idle_text, remaining);
    }

    printf("{\"text\":\"%s\",\"class\":\"%s\",\"tooltip\":\"%s\"}\n",
           text, cls, tooltip);
    fflush(stdout);
}

static int timespec_cmp(const struct timespec *a, const struct timespec *b)
{
    if (a->tv_sec != b->tv_sec)
        return a->tv_sec < b->tv_sec ? -1 : 1;
    if (a->tv_nsec != b->tv_nsec)
        return a->tv_nsec < b->tv_nsec ? -1 : 1;
    return 0;
}

static void on_idled(void *data, struct ext_idle_notification_v1 *notification)
{
    struct idle_watch *w = data;

    (void)notification;

    w->idle = true;
    w->idle_seconds = 1;
    clock_gettime(CLOCK_MONOTONIC, &w->next_tick);
    w->next_tick.tv_sec += 1;
    print_state(w);
}

static void on_resumed(void *data, struct ext_idle_notification_v1 *notification)
{
    struct idle_watch *w = data;

    (void)notification;

    if (w->idle || w->idle_seconds != 0) {
        w->idle = false;
        w->idle_seconds = 0;
        print_state(w);
    }
}

static const struct ext_idle_notification_v1_listener notification_listener = {
    .idled = on_idled,
    .resumed = on_resumed,
};

static void on_global(void *data, struct wl_registry *registry, uint32_t name,
                      const char *interface, uint32_t version)
{
    struct idle_watch *w = data;

    (void)version;

    if (strcmp(interface, wl_seat_interface.name) == 0 && !w->seat) {
        w->seat = wl_registry_bind(registry, name, &wl_seat_interface, 1);
    } else if (strcmp(interface, ext_idle_notifier_v1_interface.name) == 0 &&
               !w->notifier) {
        w->notifier = wl_registry_bind(registry, name,
                                       &ext_idle_notifier_v1_interface, 1);
    }
}

static void on_global_remove(void *data, struct wl_registry *registry,
                             uint32_t name)
{
    (void)data;
    (void)registry;
    (void)name;
}

static const struct wl_registry_listener registry_listener = {
    .global = on_global,
    .global_remove = on_global_remove,
};

static void tick_if_needed(struct idle_watch *w)
{
    struct timespec now;
    long elapsed_ms, steps;

    if (!w->idle)
        return;

    clock_gettime(CLOCK_MONOTONIC, &now);
    if (timespec_cmp(&now, &w->next_tick) < 0)
        return;

    elapsed_ms = (now.tv_sec - w->next_tick.tv_sec) * 1000L +
                 (now.tv_nsec - w->next_tick.tv_nsec) / 1000000L;
    steps = elapsed_ms / 1000L;
    if (steps < 1)
        steps = 1;

    w->idle_seconds += steps;
    w->next_tick.tv_sec += steps;
    print_state(w);
}

int main(int argc, char **argv)
{
    struct idle_watch w = {0};
    struct pollfd pfd;
    time_t last_state_check = 0;
    char *end = NULL;
    long timeout;

    if (argc != 3) {
        fprintf(stderr, "usage: %s <lock-timeout-seconds> <state-file>\n",
                argv[0]);
        return 2;
    }

    errno = 0;
    timeout = strtol(argv[1], &end, 10);
    if (errno || !end || *end || timeout <= 0) {
        fprintf(stderr, "invalid lock timeout: %s\n", argv[1]);
        return 2;
    }

    w.lock_timeout = timeout;
    w.state_file = argv[2];
    w.enabled = read_enabled(w.state_file);

    w.display = wl_display_connect(NULL);
    if (!w.display) {
        fprintf(stderr, "niri-idle-watch: cannot connect to wayland display\n");
        return 1;
    }

    w.registry = wl_display_get_registry(w.display);
    wl_registry_add_listener(w.registry, &registry_listener, &w);
    if (wl_display_roundtrip(w.display) < 0) {
        fprintf(stderr, "niri-idle-watch: wayland roundtrip failed\n");
        return 1;
    }

    if (!w.seat || !w.notifier) {
        fprintf(stderr,
                "niri-idle-watch: compositor does not expose "
                "ext-idle-notify-v1 (or no seat)\n");
        return 1;
    }

    /* 1 second notification: gives us the start of the idle period. */
    w.notification = ext_idle_notifier_v1_get_idle_notification(
        w.notifier, 1000, w.seat);
    ext_idle_notification_v1_add_listener(w.notification,
                                          &notification_listener, &w);
    if (wl_display_flush(w.display) < 0) {
        fprintf(stderr, "niri-idle-watch: wayland flush failed\n");
        return 1;
    }

    print_state(&w);

    pfd.fd = wl_display_get_fd(w.display);
    pfd.events = POLLIN;

    for (;;) {
        int poll_timeout = 1000;
        int ret;

        if (w.idle) {
            struct timespec now;
            long ms;

            clock_gettime(CLOCK_MONOTONIC, &now);
            ms = (w.next_tick.tv_sec - now.tv_sec) * 1000L +
                 (w.next_tick.tv_nsec - now.tv_nsec) / 1000000L;
            if (ms < 0)
                ms = 0;
            if (ms < poll_timeout)
                poll_timeout = (int)ms;
        }

        ret = poll(&pfd, 1, poll_timeout);
        if (ret < 0) {
            if (errno == EINTR)
                continue;
            perror("niri-idle-watch: poll");
            break;
        }

        if (ret > 0 && (pfd.revents & (POLLIN | POLLERR | POLLHUP))) {
            if (wl_display_dispatch(w.display) < 0) {
                fprintf(stderr, "niri-idle-watch: wayland dispatch failed\n");
                break;
            }
        } else {
            wl_display_dispatch_pending(w.display);
        }

        tick_if_needed(&w);

        {
            struct timespec now;
            clock_gettime(CLOCK_MONOTONIC, &now);
            if (now.tv_sec != last_state_check) {
                bool enabled;

                last_state_check = now.tv_sec;
                enabled = read_enabled(w.state_file);
                if (enabled != w.enabled) {
                    w.enabled = enabled;
                    print_state(&w);
                }
            }
        }

        wl_display_flush(w.display);
    }

    return 0;
}
