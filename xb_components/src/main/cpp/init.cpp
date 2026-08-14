//
// Created on 2025/7/28.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "napi_utils.h"
#include <dlfcn.h>
#include <sys/mman.h>  // mmap, mprotect
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int32_t (*LockCursorFunc)(int32_t windowId, bool isCursorFollowMovement);
typedef int32_t (*UnlockCursorFunc)(int32_t windowId);

static void* s_window_lib_handle = NULL;
static LockCursorFunc s_lock_cursor_func = NULL;
static UnlockCursorFunc s_unlock_cursor_func = NULL;
static int s_initialized = 0;

// 初始化库加载
int window_manager_init(void) {
    if (s_initialized) {
        return 1;
    }
    
    // 尝试加载窗口管理库
    const char* lib_names[] = {
        "libnative_window_manager.so",
        "libnative_window.so",
        NULL
    };
    
    for (int i = 0; lib_names[i] != NULL; i++) {
        s_window_lib_handle = dlopen(lib_names[i], RTLD_LAZY);
        if (s_window_lib_handle != NULL) {
            printf("Loaded library: %s\n", lib_names[i]);
            break;
        }
        printf("Failed to load %s: %s\n", lib_names[i], dlerror());
    }
    
    if (s_window_lib_handle == NULL) {
        printf("Failed to load window manager library\n");
        return 0;
    }
    
    // 获取函数指针
    s_lock_cursor_func = (LockCursorFunc)dlsym(s_window_lib_handle, 
                                               "OH_WindowManager_LockCursor");
    if (s_lock_cursor_func == NULL) {
        printf("Failed to find OH_WindowManager_LockCursor: %s\n", dlerror());
    }
    
    s_unlock_cursor_func = (UnlockCursorFunc)dlsym(s_window_lib_handle, 
                                                   "OH_WindowManager_UnlockCursor");
    if (s_unlock_cursor_func == NULL) {
        ("Failed to find OH_WindowManager_UnlockCursor: %s\n", dlerror());
    }
    
    s_initialized = 1;
    return 1;
}


bool canJit(){
    unsigned char code[] = {
        0xc0, 0x03, 0x5f, 0xd6      // ret                    (返回)
    };
    size_t code_size = sizeof(code);
    void *mem = mmap(NULL, code_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mem == MAP_FAILED) {
        return false;
    }
    memcpy(mem, code, code_size);
    if (mprotect(mem, code_size, PROT_READ | PROT_EXEC) == -1) {
        munmap(code, code_size);
        return false;
    } else {
       return true;
    }
}
napi_value HasJit(napi_env env, napi_callback_info info){
    return NapiUtils::toNapiValue(env, canJit());
}


napi_value LockCursor(napi_env env, napi_callback_info info){
    SETUP_NAPI_ARGS(env, info, 2);
    DEFINE_NAPI_ARG(int32_t, windowId, env, args[0]);
    DEFINE_NAPI_ARG(bool, isCursorFollowMovement, env, args[1]);
    if(s_lock_cursor_func == nullptr){
        return NapiUtils::toNapiValue(env, -1);
    }
    int ret = s_lock_cursor_func(windowId, isCursorFollowMovement);
    return NapiUtils::toNapiValue(env, ret);
}
napi_value UnlockCursor(napi_env env, napi_callback_info info){
    SETUP_NAPI_ARGS(env, info, 1);
    DEFINE_NAPI_ARG(int32_t, windowId, env, args[0]);
    if(s_unlock_cursor_func == nullptr){
        return NapiUtils::toNapiValue(env, -1);
    }
    int ret = s_unlock_cursor_func(windowId);
    return NapiUtils::toNapiValue(env, ret);
}


EXTERN_C_START

 napi_value Init(napi_env env, napi_value exports)
{
    window_manager_init();
    napi_property_descriptor desc[] = {
        { "lockCursor", nullptr, LockCursor, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "unlockCursor", nullptr, UnlockCursor, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "hasJit", nullptr, HasJit, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

EXTERN_C_END
static napi_module xbModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "xb_components",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&xbModule);
}
