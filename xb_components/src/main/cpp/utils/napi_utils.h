//
// Created on 2024/4/16.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef napi_utils_H
#define napi_utils_H
#include <hilog/log.h>
#include <napi/native_api.h>
#include <cstdint>
#include <sstream>
#include <span>
#include <string>


#define REGISTER_FUNCTION(name) { #name, nullptr, name, nullptr, nullptr, nullptr, napi_default, nullptr }


/**
 * Return `r` if napi call `expr` is not ok.
 *
 * You may use `napiCallResult` to return the code returned by `expr`.
 */
#define NAPI_RETURN_IF_NOT_OK(r, expr) \
    if (auto napiCallResult = (expr); napiCallResult != napi_ok) { \
        OH_LOG_ERROR(LOG_APP, "NAPI call %{public}s failed with %{public}d", #expr, napiCallResult); \
        return (r); \
    }

#define RETURN_IF_NULLOPT_OR_ASSIGN(r, recv, expr) \
    if (auto val = (expr); !val) {\
        return (r); \
    } else { \
        (recv) = *val; \
    }

#define SETUP_NAPI_ARGS_OR_RETURN(env, info, argsCnt, r) \
    size_t argc; \
    NAPI_RETURN_IF_NOT_OK(r, napi_get_cb_info(env, info, &argc, nullptr, nullptr, nullptr)); \
    if (argc != (argsCnt)) { \
        OH_LOG_ERROR(LOG_APP, "NAPI function implementation expects %{public}d arguments, but got %{public}d", \
            (argsCnt), (int)argc); \
        return (r); \
    } \
    napi_value args[(argsCnt)] = { nullptr }; \
    NAPI_RETURN_IF_NOT_OK(r, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));

#define SETUP_NAPI_ARGS(env, info, argsCnt) \
    constexpr const char *__funcname_setup_args = __PRETTY_FUNCTION__; \
    SETUP_NAPI_ARGS_OR_RETURN(env, info, argsCnt, [&] { \
        std::stringstream ss; \
        ss << __funcname_setup_args << " Failed to initialize args"; \
        napi_throw_error(env, "NapiError", ss.str().c_str()); \
        return nullptr; \
    }());

#define DEFINE_NAPI_ARG_OR_RETURN(type, var, env, arg, r) \
    type var{}; \
    RETURN_IF_NULLOPT_OR_ASSIGN(r, var, NapiUtils::getValue<type>(env, arg));

#define DEFINE_NAPI_ARG(type, var, env, arg) \
    constexpr const char *__funcname_define_##var = __PRETTY_FUNCTION__; \
    DEFINE_NAPI_ARG_OR_RETURN(type, var, env, arg, [&] { \
        std::stringstream ss; \
        ss << __funcname_define_##var << " Failed to extracting arg " << #var; \
        napi_throw_error(env, "IllegalArgument", ss.str().c_str()); \
        return nullptr; \
    }());


struct NapiUtils {
 

    static napi_value javascriptClassConstructor(napi_env env, napi_callback_info info);

public:
    template<typename T>
    static std::optional<T> getValue(napi_env env, napi_value value);

    template<>
    std::optional<int32_t> getValue(napi_env env, napi_value value) {
        int32_t i;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_int32(env, value, &i));
        return i;
    }

    template<>
    std::optional<uint32_t> getValue(napi_env env, napi_value value) {
        uint32_t i;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_uint32(env, value, &i));
        return i;
    }

    template<>
    std::optional<int64_t> getValue(napi_env env, napi_value value) {
        int64_t i;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_int64(env, value, &i));
        return i;
    }

    template<>
    std::optional<bool> getValue(napi_env env, napi_value value) {
        bool b;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_bool(env, value, &b));
        return b;
    }
    template<>
    std::optional<float> getValue(napi_env env, napi_value value) {
        double d;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_double(env, value, &d));
        return d;
    }
    template<>
    std::optional<double> getValue(napi_env env, napi_value value) {
        double d;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_double(env, value, &d));
        return d;
    }
    template<>
    std::optional<std::vector<std::string>> getValue(napi_env env, napi_value value) {
        bool is_array;
        napi_status status = napi_is_array(env, value, &is_array);
        if (status != napi_ok || !is_array) {
            return std::nullopt;
        }
    
        uint32_t length;
        status = napi_get_array_length(env, value, &length);
        if (status != napi_ok) {
            return std::nullopt;
        }
    
        std::vector<std::string> result;
        result.reserve(length);
        for (uint32_t i = 0; i < length; ++i) {
            napi_value element;
            status = napi_get_element(env, value, i, &element);
            if (status != napi_ok) {
                return std::nullopt;
            }
            // 获取字符串值
            auto string_opt = getValue<std::string>(env, element);
            if (!string_opt.has_value()) {
                return std::nullopt;
            }
            result.push_back(std::move(string_opt.value()));
        }
    
        return result;
    }
    template<>
    std::optional<std::vector<bool>> getValue(napi_env env, napi_value value) {
        uint32_t length;
        napi_get_array_length(env, value,  &length);
        napi_status status;
        std::vector<bool> list;
        for (uint32_t i = 0; i < length; i++) {
            napi_value element;
            bool result;
            status = napi_get_element(env, value, i, &element);
            if (status != napi_ok) {
                continue;
            }
            status = napi_get_value_bool(env, element, &result);
            if (status == napi_ok) {
                list.push_back(value);
            }
        }
        return list;
    }

    template<>
    std::optional<std::string> getValue(napi_env env, napi_value value) {
        size_t length;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_string_latin1(env, value, nullptr, 0, &length));
        std::string str(length, '\0');
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_value_string_latin1(env, value, str.data(), str.capacity(), nullptr));
        return str;
    }

    template<>
    std::optional<std::span<uint8_t>> getValue(napi_env env, napi_value value) {
        size_t length;
        void *addr;
        NAPI_RETURN_IF_NOT_OK(std::nullopt, napi_get_typedarray_info(env, value, nullptr, &length, &addr, nullptr, nullptr));
        return std::span(reinterpret_cast<uint8_t*>(addr), length);
    }

    template<typename T>
    static napi_value toNapiValue(napi_env env, const T &data);
    template<>
    napi_value toNapiValue(napi_env env, const int32_t &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_int32(env, data, &value));
        return value;
    }
    template<>
    napi_value toNapiValue(napi_env env, const int64_t &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_int64(env, data, &value));
        return value;
    }
    template<>
    napi_value toNapiValue(napi_env env, const bool &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_get_boolean(env, data, &value));
        return value;
    }
    template<>
    napi_value toNapiValue(napi_env env, const double &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_double(env, data, &value));
        return value;
    }

    template<>
    napi_value toNapiValue(napi_env env, const std::string &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_string_utf8(env, data.c_str(), NAPI_AUTO_LENGTH, &value));
        return value;
    }
    template<>
    napi_value toNapiValue(napi_env env, const char* const &data) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_string_utf8(env, data, NAPI_AUTO_LENGTH, &value));
        return value;
    }
    template<>
    napi_value toNapiValue(napi_env env, const std::function<napi_value(napi_env)> &data) {
        return data(env);
    }
    template<size_t N>
    static napi_value toNapiValue(napi_env env, const char (&data)[N]) {
        napi_value value;
        NAPI_RETURN_IF_NOT_OK(nullptr, napi_create_string_utf8(env, data, NAPI_AUTO_LENGTH, &value));
        return value;
    }

    using NapiValueType = std::variant<int32_t, int64_t, bool, double, std::string, std::function<napi_value(napi_env)>>;

    template<typename T, size_t N>
    static napi_value toArray(napi_env env, const T (&array)[N]) {
        napi_value result;
        napi_create_array_with_length(env, N, &result);
        for (uint32_t i = 0; i < N; i++) {
            napi_set_element(env, result, i, toNapiValue(env, array[i]));
        }
        return result;
    }
    // 重载版本，支持初始化列表
    template<typename T>
    static napi_value toArray(napi_env env, std::initializer_list<T> list) {
        napi_value array;
        napi_create_array_with_length(env, list.size(), &array);
        uint32_t index = 0;
        for (const auto& item : list) {
            napi_set_element(env, array, index, toNapiValue(env, item));
            index++;
        }
        return array;
    }
    // 重载版本，支持初始化列表
    template<typename T>
    static napi_value toArray(napi_env env, std::vector<T> list) {
        napi_value array;
        napi_create_array_with_length(env, list.size(), &array);
        uint32_t index = 0;
        for (const auto& item : list) {
            napi_set_element(env, array, index, toNapiValue(env, item));
            index++;
        }
        return array;
    }
    template<typename T>
    static napi_value vectorToTypedArray(napi_env env, const std::vector<T>& vec, napi_typedarray_type type) {
        napi_value arraybuffer, typedarray;
        void* data;
        napi_create_arraybuffer(env, vec.size() * sizeof(T), &data, &arraybuffer);
        memcpy(data, vec.data(), vec.size() * sizeof(T));
        napi_create_typedarray(env, type, vec.size(), arraybuffer, 0, &typedarray);
        return typedarray;
    }
    static napi_value toUnit8Array(napi_env env, std::vector<unsigned char> vec) {
         return vectorToTypedArray(env, vec, napi_uint8_array);
    }
public:

    class ThreadSafeFunction final {
    public:
        ThreadSafeFunction(napi_threadsafe_function tsfn);
        ~ThreadSafeFunction();
        napi_status operator()(void *data);

        class Arguments {
        public:
            Arguments(std::initializer_list<NapiValueType> l);
            virtual ~Arguments();
            virtual std::vector<napi_value> toNapiValues(napi_env env) const;
        private:
            const std::vector<NapiValueType> data;
        };

    private:
        napi_threadsafe_function tsfn;

        // NOTE copy has to be disabled otherwise may call release on tsfn more than expected
        ThreadSafeFunction(const ThreadSafeFunction &) = delete;
        ThreadSafeFunction &operator=(const ThreadSafeFunction &) = delete;
    };

    /**
     * Call JavaScript callback `jsCallback` with `data` as arguments.
     * @param env
     * @param jsCallback A JavaScript callback with signature of `(...args: object[]) => void`.
     * @param context Not used.
     * @param data Pointer to `ThreadSafeFunction::Argument`. Will be freed by this callback.
     */
    static void callJsCb(napi_env env, napi_value jsCallback, void *context, void *data);
    static void registerFunc(napi_env env, std::string name, napi_value func);
    static void callFunc(std::string name, std::initializer_list<NapiUtils::NapiValueType> args);
};


#endif //napi_utils_H
