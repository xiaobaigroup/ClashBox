//go:build cgo && ohos

package main

import "C"
import (
	"core/state"
	"encoding/json"
	"fmt"
	"strings"

	napi "github.com/likuai2010/ohos-napi"
	"github.com/likuai2010/ohos-napi/entry"
	"github.com/likuai2010/ohos-napi/js"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/log"
)

func initClash(env js.Env, this js.Value, args []js.Value) any {
	homeDirStr, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	return handleInitClash(homeDirStr)
}

func startTun(env js.Env, this js.Value, args []js.Value) any {
	tunFd, _ := napi.GetValueInt32(env.Env, args[0].Value)
	tsfn := env.CreateThreadsafeFunction(args[1], "startTun")
	StartTUN(int(tunFd), func(fd Fd) {
		tsfn.Call(env.ValueOf(fd.Id), env.ValueOf(fd.Value))
	})
	return nil
}
func stopTun(env js.Env, this js.Value, args []js.Value) any {
	StopTun()
	return nil
}

func validateConfig(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	bytes := []byte(paramsString)
	promise := env.NewPromise()
	go func() {
		promise.Resolve(handleValidateConfig(bytes))
	}()
	return promise
}

func updateConfig(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	fmt.Println("updateConfig", paramsString)
	promise := env.NewPromise()
	bytes := []byte(paramsString)
	go func() {
		promise.Resolve(handleUpdateConfig(bytes))
	}()
	return promise
}

func getProxies(env js.Env, this js.Value, args []js.Value) any {
	return handleGetProxies()
}

func changeProxy(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	promise := env.NewPromise()
	fmt.Println("changeProxy", paramsString)
	handleChangeProxy(paramsString, func(value string) {
		promise.Resolve(value)
	})
	return promise
}

func getTraffic(env js.Env, this js.Value, args []js.Value) any {
	onlyProxy := true
	handleGetTraffic(onlyProxy)
	return handleGetTraffic(onlyProxy)
}
func getTotalTraffic(env js.Env, this js.Value, args []js.Value) any {
	onlyProxy := true
	return handleGetTotalTraffic(onlyProxy)
}
func resetTraffic(env js.Env, this js.Value, args []js.Value) any {
	handleResetTraffic()
	return nil
}
func forceGc(env js.Env, this js.Value, args []js.Value) any {
	handleForceGc()
	return nil
}
func asyncTestDelay(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	promise := env.NewPromise()
	handleAsyncTestDelay(paramsString, func(value string) {
		promise.Resolve(value)
	})
	return promise
}
func getExternalProviders(env js.Env, this js.Value, args []js.Value) any {
	return handleGetExternalProviders()
}
func getExternalProvider(env js.Env, this js.Value, args []js.Value) any {
	externalProviderName, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	return handleGetExternalProvider(externalProviderName)
}
func updateGeoData(env js.Env, this js.Value, args []js.Value) any {
	geoType, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	geoName, _ := napi.GetValueStringUtf8(env.Env, args[1].Value)
	promise := env.NewPromise()
	handleUpdateGeoData(geoType, geoName, func(value string) {
		promise.Resolve(value)
	})
	return promise
}
func updateExternalProvider(env js.Env, this js.Value, args []js.Value) any {
	providerName, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	promise := env.NewPromise()
	handleUpdateExternalProvider(providerName, func(value string) {
		promise.Resolve(value)
	})
	return promise
}

func sideLoadExternalProvider(env js.Env, this js.Value, args []js.Value) any {
	providerName, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	dataChar, _ := napi.GetValueStringUtf8(env.Env, args[1].Value)
	data := []byte(dataChar)
	promise := env.NewPromise()
	handleSideLoadExternalProvider(providerName, data, func(value string) {
		promise.Resolve(value)
	})
	return promise
}
func getConnections(env js.Env, this js.Value, args []js.Value) any {
	return handleGetConnections()
}

func closeConnections(env js.Env, this js.Value, args []js.Value) any {
	return handleCloseConnections()
}

func closeConnection(env js.Env, this js.Value, args []js.Value) any {
	connectionId, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	return handleCloseConnection(connectionId)
}
func startLog(env js.Env, this js.Value, args []js.Value) any {
	tsfn := env.CreateThreadsafeFunction(args[0], "startLog")
	handleStartLog(func(value string) {
		tsfn.Call(env.ValueOf("startLog"), env.ValueOf(value))
	})
	return nil
}
func stopLog(env js.Env, this js.Value, args []js.Value) any {
	handleStopLog()
	return nil
}
func getCountryCode(env js.Env, this js.Value, args []js.Value) any {
	ip, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	promise := env.NewPromise()
	handleGetCountryCode(ip, func(value string) {
		promise.Resolve(value)
	})
	return promise
}
func getMemory(env js.Env, this js.Value, args []js.Value) any {
	promise := env.NewPromise()
	handleGetMemory(func(value string) {
		promise.Resolve(value)
	})
	return promise
}
func updateDns(env js.Env, this js.Value, args []js.Value) any {
	dnsList, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	promise := env.NewPromise()
	go func() {
		log.Infoln("[DNS] updateDns %s", dnsList)
		dns.UpdateSystemDNS(strings.Split(dnsList, ","))
		dns.FlushCacheWithDefaultResolver()
		promise.Resolve(nil)
	}()
	return promise
}
func setState(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	err := json.Unmarshal([]byte(paramsString), state.CurrentState)
	if err != nil {
		return nil
	}
	return nil
}
func setProcessMap(env js.Env, this js.Value, args []js.Value) any {
	paramsString, _ := napi.GetValueStringUtf8(env.Env, args[0].Value)
	return SetProcessMap(paramsString)
}

func getVpnOptions(env js.Env, this js.Value, args []js.Value) any {
	return GetVpnOptions()
}
func getCurrentProfileName(env js.Env, this js.Value, args []js.Value) any {
	if state.CurrentState == nil {
		return ""
	}
	return state.CurrentState.CurrentProfileName
}

func setFdMap(env js.Env, this js.Value, args []js.Value) any {
	fdInt, _ := napi.GetValueInt32(env.Env, args[0].Value)
	go func() {
		fdMap.Store(int64(fdInt))
	}()
	return nil
}

func init() {
	entry.Export("initClash", js.AsCallback(initClash))
	entry.Export("startTun", js.AsCallback(startTun))
	entry.Export("setFdMap", js.AsCallback(setFdMap))
	entry.Export("stopTun", js.AsCallback(stopTun))
	entry.Export("forceGc", js.AsCallback(forceGc))
	entry.Export("validateConfig", js.AsCallback(validateConfig))
	entry.Export("updateConfig", js.AsCallback(updateConfig))
	entry.Export("getTraffic", js.AsCallback(getTraffic))
	entry.Export("getTotalTraffic", js.AsCallback(getTotalTraffic))
	entry.Export("resetTraffic", js.AsCallback(resetTraffic))
	entry.Export("getProxies", js.AsCallback(getProxies))
	entry.Export("changeProxy", js.AsCallback(changeProxy))
	entry.Export("asyncTestDelay", js.AsCallback(asyncTestDelay))
	entry.Export("getConnections", js.AsCallback(getConnections))
	entry.Export("closeConnections", js.AsCallback(closeConnections))
	entry.Export("closeConnection", js.AsCallback(closeConnection))
	entry.Export("updateExternalProvider", js.AsCallback(updateExternalProvider))
	entry.Export("sideLoadExternalProvider", js.AsCallback(sideLoadExternalProvider))
	entry.Export("getExternalProviders", js.AsCallback(getExternalProviders))
	entry.Export("getVpnOptions", js.AsCallback(getVpnOptions))
	entry.Export("getCurrentProfileName", js.AsCallback(getCurrentProfileName))
	entry.Export("setProcessMap", js.AsCallback(setProcessMap))
	entry.Export("updateDns", js.AsCallback(updateDns))
	entry.Export("startLog", js.AsCallback(startLog))
	entry.Export("stopLog", js.AsCallback(stopLog))
	entry.Export("getCountryCode", js.AsCallback(getCountryCode))
	entry.Export("getMemory", js.AsCallback(getMemory))
}
func main() {
}
