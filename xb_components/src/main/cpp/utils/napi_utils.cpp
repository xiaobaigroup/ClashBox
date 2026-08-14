//
// Created on 2024/4/16.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "napi_utils.h"
#include <string>



napi_value NapiUtils::javascriptClassConstructor(napi_env env, napi_callback_info info) {
    napi_value thisArg = nullptr;
    void *data = nullptr;
    NAPI_RETURN_IF_NOT_OK(nullptr, napi_get_cb_info(env, info, nullptr, nullptr, &thisArg, &data));
    napi_value global = nullptr;
    NAPI_RETURN_IF_NOT_OK(nullptr, napi_get_global(env, &global));
    return thisArg;
}


NapiUtils::ThreadSafeFunction::ThreadSafeFunction(napi_threadsafe_function tsfn) : tsfn(tsfn) {
}

NapiUtils::ThreadSafeFunction::~ThreadSafeFunction() {
    if (tsfn) {
        (void) [&] { NAPI_RETURN_IF_NOT_OK(napiCallResult, napi_release_threadsafe_function(tsfn, napi_tsfn_abort)); return napi_ok; }();
    }
    tsfn = nullptr;
}

napi_status NapiUtils::ThreadSafeFunction::operator()(void *data) {
    if (!tsfn) {
        return napi_closing;
    }
    if (auto napiCallResult = napi_call_threadsafe_function(tsfn, data, napi_tsfn_blocking); napiCallResult != napi_ok) {
        OH_LOG_WARN(LOG_APP, "Failed to call thread-safe function %{public}d", napiCallResult);
        tsfn = nullptr;
        return napiCallResult;
    }
    return napi_ok;
}

NapiUtils::ThreadSafeFunction::Arguments::Arguments(std::initializer_list<NapiValueType> l) : data(l) {
}

NapiUtils::ThreadSafeFunction::Arguments::~Arguments() = default;

std::vector<napi_value> NapiUtils::ThreadSafeFunction::Arguments::toNapiValues(napi_env env) const {
    std::vector<napi_value> values;
    for (const auto &d : data) {
        values.push_back(std::visit([&] (auto &&d) {
            return toNapiValue(env, d);
        }, d));
    }
    return values;
}


static std::unordered_map<std::string, std::unique_ptr<NapiUtils::ThreadSafeFunction>> callbackMap = {};
void NapiUtils::callJsCb(napi_env env, napi_value jsCallback, void *context, void *data) {
    using Arg = ThreadSafeFunction::Arguments;
    /* data will be automatically deleted once out of this callback */
    const std::unique_ptr<Arg> args{reinterpret_cast<Arg*>(data)};
    auto jsArgs = args ? args->toNapiValues(env) : std::vector<napi_value>();
    (void) [&] { NAPI_RETURN_IF_NOT_OK(napiCallResult, napi_call_function(env, nullptr, jsCallback,
        jsArgs.size(), jsArgs.data(), nullptr)); return napi_ok; }();
}

void NapiUtils::registerFunc(napi_env env, std::string name, napi_value func){
    napi_threadsafe_function callback;
    napi_create_threadsafe_function(
            env, func,
            /*async_resource=*/nullptr, /*async_resource_name=*/NapiUtils::toNapiValue(env, name),
            /*max_queue_size=*/0, /*initial_thread_count=*/1,
            /*thread_finalize_data=*/nullptr, /*thread_finalize_cb=*/nullptr,
            /*context=*/nullptr, NapiUtils::callJsCb, &callback
        );
    callbackMap.insert({name, std::make_unique<NapiUtils::ThreadSafeFunction>(callback)});
}
void NapiUtils::callFunc(std::string name, std::initializer_list<NapiUtils::NapiValueType> args){
    if (const auto cbit = callbackMap.find(name); cbit != callbackMap.cend()) {
        (void) [&] { NAPI_RETURN_IF_NOT_OK(napiCallResult, (*cbit->second)(new NapiUtils::ThreadSafeFunction::Arguments(args))); return napi_ok; }();
    } else {
        OH_LOG_INFO(LOG_APP, "Event %{public}s has no associated callback from %{public}d", name.c_str(), reinterpret_cast<uintptr_t>(&callbackMap));
    }
}

