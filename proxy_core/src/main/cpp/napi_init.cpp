#include "napi/native_api.h"
#include "hilog/log.h"
#include <thread>

static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;

}
static napi_threadsafe_function tsfn;
static napi_value nativeStartTun(napi_env env, napi_callback_info info)
{
 
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    
    int tunFd;
    napi_get_value_int32(env, args[0], &tunFd);

    napi_value resourceName;
    napi_create_string_latin1(env, "nativeStartTun'", NAPI_AUTO_LENGTH, &resourceName);
   
    napi_create_threadsafe_function(env, args[1], NULL, resourceName, 0, 1, NULL, NULL, NULL, [](napi_env env, napi_value js_callback, void *context, void *data){
        CallbackData* cd = (CallbackData *)data;
        if (cd == nullptr)
            return ;
        napi_value params[1];
        napi_value result;
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "ClashNative", "Error get status %{public}d, %{public}d", cd->fd);
        napi_create_int32(env, cd->fd, &result);
        params[0] = result;
        napi_call_function(env, nullptr, js_callback, 1, params, nullptr);
        }, &tsfn);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "ClashNative", "Error get tunfd status %{public}d, ", tunFd);
   
    std::thread t([](int fd){
        OH_LOG_Print(LOG_APP, LOG_DEBUG, 0x00000, "ClashVpn", "startRun %{public}d", fd);
        startTun(fd, (void*)+[](void *tun_interface, int fd){
            callbackData.fd = fd;
            napi_call_threadsafe_function(tsfn, &callbackData, napi_tsfn_blocking);
        });
    }, tunFd);
    t.detach();
    return NULL;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "startFlClash", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "proxy_core",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterProxy_coreModule(void)
{
    napi_module_register(&demoModule);
}
