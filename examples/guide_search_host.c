/*
 * Host for the guide search example.
 * Provides stub http + log capabilities.
 */

#include "mog.h"
#include "mog_async.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef MOG_HOST_LIMITS_MAX_MEMORY
#define MOG_HOST_LIMITS_MAX_MEMORY (64 * 1024 * 1024)
#endif

#ifndef MOG_HOST_LIMITS_INITIAL_MEMORY
#define MOG_HOST_LIMITS_INITIAL_MEMORY (8 * 1024 * 1024)
#endif

typedef struct {
    size_t max_memory;
    int max_cpu_ms;
    int max_stack_depth;
    size_t initial_memory;
} MogLimits;

void mog_vm_set_limits(MogVM *vm, const MogLimits *limits);

static void setup_mog_limits(MogVM *vm) {
    MogLimits limits = {
        .max_memory = MOG_HOST_LIMITS_MAX_MEMORY,
        .max_cpu_ms = 0,
        .max_stack_depth = 1024,
        .initial_memory = MOG_HOST_LIMITS_INITIAL_MEMORY,
    };
    mog_vm_set_limits(vm, &limits);
}

/* ---- http capability (stub) ---- */

static MogValue host_http_get(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *url = mog_arg_string(args, 0);
    printf("[http.get] %s\n", url);

    /* Return a mock response string — the Mog parse_results function
       doesn't actually parse it, it builds results directly. */
    MogEventLoop *loop = mog_loop_get_global();
    if (loop) {
        MogFuture *future = mog_future_new();
        /* Complete immediately with a mock response */
        mog_future_complete(future, (int64_t)(intptr_t)"{\"results\": []}");
        return mog_int((int64_t)(intptr_t)future);
    }
    return mog_string("{\"results\": []}");
}

static MogValue host_http_post(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *url = mog_arg_string(args, 0);
    printf("[http.post] %s\n", url);

    MogEventLoop *loop = mog_loop_get_global();
    if (loop) {
        MogFuture *future = mog_future_new();
        mog_future_complete(future, (int64_t)(intptr_t)"{\"ok\": true}");
        return mog_int((int64_t)(intptr_t)future);
    }
    return mog_string("{\"ok\": true}");
}

/* ---- log capability ---- */

static MogValue host_log_info(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *msg = mog_arg_string(args, 0);
    printf("[INFO] %s\n", msg);
    return mog_none();
}

static MogValue host_log_warn(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *msg = mog_arg_string(args, 0);
    printf("[WARN] %s\n", msg);
    return mog_none();
}

static MogValue host_log_error(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *msg = mog_arg_string(args, 0);
    printf("[ERROR] %s\n", msg);
    return mog_none();
}

static MogValue host_log_debug(MogVM *vm, MogArgs *args) {
    (void)vm;
    const char *msg = mog_arg_string(args, 0);
    printf("[DEBUG] %s\n", msg);
    return mog_none();
}

/* ---- Registration tables ---- */

static const MogCapEntry http_functions[] = {
    { "get",  host_http_get },
    { "post", host_http_post },
    { NULL, NULL }
};

static const MogCapEntry log_functions[] = {
    { "info",  host_log_info },
    { "warn",  host_log_warn },
    { "error", host_log_error },
    { "debug", host_log_debug },
    { NULL, NULL }
};

/* ---- Constructor: runs before main() ---- */

__attribute__((constructor))
static void setup_mog_vm(void) {
    MogVM *vm = mog_vm_new();
    if (!vm) {
        fprintf(stderr, "host: failed to create MogVM\n");
        exit(1);
    }
    setup_mog_limits(vm);

    mog_register_capability(vm, "http", http_functions);
    mog_register_capability(vm, "log", log_functions);
    mog_vm_set_global(vm);
}
