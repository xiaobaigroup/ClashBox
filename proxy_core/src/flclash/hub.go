package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"runtime"
	"sort"
	"strconv"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

type healthCheckTarget struct {
	name           string
	proxy          constant.Proxy
	testURL        string
	expectedStatus string
}

var (
	isInit             = false
	configParams       = ConfigExtendedParams{}
	externalProviders  = map[string]cp.Provider{}
	logSubscriber      observable.Subscription[log.Event]
	logStop            chan struct{}
	currentConfig      *config.Config
	healthCheckMu      sync.Mutex
	healthCheckRunning bool
)

func handleInitClash(homeDirStr string) bool {
	if !isInit {
		constant.SetHomeDir(homeDirStr)
		isInit = true
	}
	return isInit
}

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	updateListeners(true)
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	listener.StopListener()
	return true
}

func handleGetIsInit() bool {
	return isInit
}

func handleForceGc() {
	go func() {
		log.Infoln("[APP] request force GC")
		runtime.GC()
	}()
}

func handleShutdown() bool {
	stopListeners()
	executor.Shutdown()
	runtime.GC()
	isInit = false
	return true
}

func handleValidateConfig(bytes []byte) string {
	_, err := config.UnmarshalRawConfig(bytes)
	if err != nil {
		return err.Error()
	}
	return ""
}

func handleUpdateConfig(bytes []byte) string {
	var params = &GenerateConfigParams{}
	err := json.Unmarshal(bytes, params)
	if err != nil {
		return err.Error()
	}

	configParams = params.Params
	prof := decorationConfig(params.ProfileId, params.Config)
	err = applyConfig(prof)
	if err != nil {
		return err.Error()
	}
	return ""
}

func handleGetProxies() string {
	runLock.Lock()
	defer runLock.Unlock()
	data, err := json.Marshal(tunnel.ProxiesWithProviders())
	if err != nil {
		return ""
	}
	return string(data)
}

func handleChangeProxy(data string, fn func(string string)) {
	runLock.Lock()
	go func() {
		defer runLock.Unlock()
		var params = &ChangeProxyParams{}
		err := json.Unmarshal([]byte(data), params)
		if err != nil {
			fn(err.Error())
			return
		}
		groupName := *params.GroupName
		proxyName := *params.ProxyName
		proxies := tunnel.ProxiesWithProviders()
		group, ok := proxies[groupName]
		if !ok {
			fn("Not found group")
			return
		}
		adapterProxy := group.(*adapter.Proxy)
		selector, ok := adapterProxy.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			fn("Group is not selectable")
			return
		}
		if proxyName == "" {
			selector.ForceSet(proxyName)
		} else {
			err = selector.Set(proxyName)
		}
		if err != nil {
			fn(err.Error())
			return
		}

		fn("")
		return
	}()
}

func handleGetTraffic(onlyProxy bool) string {
	up, down := statistic.DefaultManager.NowTraffic(onlyProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleGetTotalTraffic(onlyProxy bool) string {
	up, down := statistic.DefaultManager.TotalTraffic(onlyProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleAsyncTestDelay(paramsString string, fn func(string)) {
	b.Go(paramsString, func() (bool, error) {
		var params = &TestDelayParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			fn("")
			return false, nil
		}

		expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		if err != nil {
			fn("")
			return false, nil
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		defer cancel()

		proxies := tunnel.ProxiesWithProviders()
		proxy := proxies[params.ProxyName]

		delayData := &Delay{
			Name: params.ProxyName,
		}

		if proxy == nil {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return false, nil
		}

		testUrl := constant.DefaultTestURL
		if params.TestUrl != "" {
			testUrl = params.TestUrl
		}

		delay, err := proxy.URLTest(ctx, testUrl, expectedStatus)
		if err != nil || delay == 0 {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return false, nil
		}

		delayData.Value = int32(delay)
		data, _ := json.Marshal(delayData)
		fn(string(data))
		return false, nil
		})
		 }

		 func handleAsyncTestDelayBatch(paramsString string, fn func(string)) {
		  var params = &TestDelayBatchParams{}
		  err := json.Unmarshal([]byte(paramsString), params)
		  if err != nil || len(params.ProxyNames) == 0 {
		   fn("[]")
		   return
		  }

		  expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		  if err != nil {
		   fn("[]")
		   return
		  }

		  testURL := constant.DefaultTestURL
		  if params.TestURL != "" {
		   testURL = params.TestURL
		  }

		  proxies := tunnel.ProxiesWithProviders()
		  var mu sync.Mutex
		  results := make([]Delay, 0, len(params.ProxyNames))
		  sem := make(chan struct{}, 50)
		  var wg sync.WaitGroup

		  for _, proxyName := range params.ProxyNames {
		   proxy := proxies[proxyName]
		   if proxy == nil {
		    mu.Lock()
		    results = append(results, Delay{Name: proxyName, Value: -1})
		    mu.Unlock()
		    continue
		   }

		   sem <- struct{}{}
		   wg.Add(1)
		   go func(name string, p constant.Proxy) {
		    defer func() {
		     <-sem
		     wg.Done()
		    }()

		    ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		    defer cancel()

		    d := Delay{Name: name}
		    delay, err := p.URLTest(ctx, testURL, expectedStatus)
		    if err != nil || delay == 0 {
		     d.Value = -1
		    } else {
		     d.Value = int32(delay)
		    }

		    mu.Lock()
		    results = append(results, d)
		    mu.Unlock()
		   }(proxyName, proxy)
		  }

		  // 不阻塞 IPC handler，后台等待所有测试完成再回调
		  go func() {
		   wg.Wait()
		   data, _ := json.Marshal(results)
		   fn(string(data))
		  }()
		 }

		 func handleHealthCheckAll() {
	healthCheckMu.Lock()
	if healthCheckRunning {
		healthCheckMu.Unlock()
		return
	}
	healthCheckRunning = true
	healthCheckMu.Unlock()
	defer func() {
		healthCheckMu.Lock()
		healthCheckRunning = false
		healthCheckMu.Unlock()
	}()

	// 直连模式下不需要健康检查，URLTest/Fallback 策略组不生效
	if currentConfig != nil && string(currentConfig.General.Mode) == "direct" {
		return
	}
	proxies := tunnel.ProxiesWithProviders()
	if len(proxies) == 0 {
		return
	}

	// URLTest/Fallback 的自动切换依赖子节点的 delay history。
	// 后台只测策略组本身时，可能只复用当前不可用节点，无法刷新其它候选节点的延迟，
	// 导致必须等 UI 回前台执行全量测速后才恢复。这里按每个策略组配置的 url/expectedStatus 展开子节点测速。
	targets := make(map[string]healthCheckTarget)
	visitedGroups := make(map[string]struct{})
	var collectGroupTargets func(string)
	collectGroupTargets = func(groupName string) {
		if _, visited := visitedGroups[groupName]; visited {
			return
		}
		visitedGroups[groupName] = struct{}{}
		group := proxies[groupName]
		if group == nil {
			return
		}
		raw, err := json.Marshal(group)
		if err != nil {
			return
		}
		var info struct {
			All            []string `json:"all"`
			TestURL        string   `json:"testUrl"`
			ExpectedStatus string   `json:"expectedStatus"`
		}
		if err := json.Unmarshal(raw, &info); err != nil {
			return
		}
		testURL := info.TestURL
		if testURL == "" {
			testURL = constant.DefaultTestURL
		}
		for _, childName := range info.All {
			child := proxies[childName]
			if child == nil {
				continue
			}
			if childAdapter, ok := child.(*adapter.Proxy); ok {
				switch childAdapter.ProxyAdapter.(type) {
				case *outboundgroup.URLTest, *outboundgroup.Fallback:
					collectGroupTargets(childName)
					continue
				}
			}
			key := groupName + "\x00" + childName + "\x00" + testURL + "\x00" + info.ExpectedStatus
			targets[key] = healthCheckTarget{
				name:           childName,
				proxy:          child,
				testURL:        testURL,
				expectedStatus: info.ExpectedStatus,
			}
		}
	}

	for name, proxy := range proxies {
		if proxy == nil {
			continue
		}
		adapterProxy, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}
		switch adapterProxy.ProxyAdapter.(type) {
		case *outboundgroup.URLTest, *outboundgroup.Fallback:
			collectGroupTargets(name)
		default:
			continue
		}
	}
	if len(targets) == 0 {
		return
	}

	// 限制并发健康检查数，防止大量 protect IPC 堵塞 JS 消息循环（尤其是 rule-provider 下载场景）
	sem := make(chan struct{}, 10)
	var wg sync.WaitGroup
	for _, target := range targets {
		target := target
		sem <- struct{}{}
		wg.Add(1)
		go func() {
			defer func() {
				<-sem
				wg.Done()
			}()
			expectedStatus, err := utils.NewUnsignedRanges[uint16](target.expectedStatus)
			if err != nil {
				expectedStatus, _ = utils.NewUnsignedRanges[uint16]("")
			}
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
			defer cancel()
			_, _ = target.proxy.URLTest(ctx, target.testURL, expectedStatus)
			log.Debugln("[HealthCheckAll] checked %s", target.name)
		}()
	}
	// 等待所有候选节点健康检查完成，确保 URLTest/Fallback 后台也能基于新延迟切换
	wg.Wait()
}

func handleGetConnections() string {
	runLock.Lock()
	defer runLock.Unlock()
	snapshot := statistic.DefaultManager.Snapshot()
	data, err := json.Marshal(snapshot)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleCloseConnectionsUnLock() bool {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		err := c.Close()
		if err != nil {
			return false
		}
		return true
	})
	return true
}

func handleCloseConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		err := c.Close()
		if err != nil {
			return false
		}
		return true
	})
	return true
}

func handleCloseConnection(connectionId string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return false
	}
	_ = c.Close()
	return true
}

func handleGetExternalProviders() string {
	runLock.Lock()
	defer runLock.Unlock()
	externalProviders = getExternalProvidersRaw()
	eps := make([]ExternalProvider, 0)
	for _, p := range externalProviders {
		externalProvider, err := toExternalProvider(p)
		if err != nil {
			continue
		}
		eps = append(eps, *externalProvider)
	}
	sort.Sort(ExternalProviders(eps))
	data, err := json.Marshal(eps)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleGetExternalProvider(externalProviderName string) string {
	runLock.Lock()
	defer runLock.Unlock()
	externalProvider, exist := externalProviders[externalProviderName]
	if !exist {
		return ""
	}
	e, err := toExternalProvider(externalProvider)
	if err != nil {
		return ""
	}
	data, err := json.Marshal(e)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleUpdateGeoData(geoType string, geoName string, fn func(value string)) {
	go func() {
		path := constant.Path.Resolve(geoName)
		switch geoType {
		case "MMDB":
			err := updater.UpdateMMDBWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "ASN":
			err := updater.UpdateASNWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "GeoIp":
			err := updater.UpdateGeoIpWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "GeoSite":
			err := updater.UpdateGeoSiteWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "MRS":
			// ★ BundleMRS 规则集: 官方地址下载最新 7z 覆盖内置版本(geox-url 无 mrs 字段, 用固定官方源)
			const mrsUrl = "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/BundleMRS.7z"
			_, err := handleDownloadConfig(mrsUrl, "clash-verge/v2.5.1", path)
			if err != nil {
				fn(err.Error())
				return
			}
		}
		fn("")
	}()
}

func handleUpdateExternalProvider(providerName string, fn func(value string)) {
	go func() {
		externalProvider, exist := externalProviders[providerName]
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := externalProvider.Update()
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleSideLoadExternalProvider(providerName string, data []byte, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		externalProvider, exist := externalProviders[providerName]
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := sideUpdateExternalProvider(externalProvider, data)
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleStartLog(fn func(value string)) {
	// 通知旧的 goroutine 退出，防止泄漏
	if logStop != nil {
		close(logStop)
		logStop = nil
	}
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	logSubscriber = log.Subscribe()
	logStop = make(chan struct{})
	go func() {
		for {
			select {
			case <-logStop:
				return
			case logData, ok := <-logSubscriber:
				if !ok {
					return
				}
				if logData.LogLevel < log.Level() {
					continue
				}
				logMessage, _ := json.Marshal(LogInfo{
					LogLevel: logData.LogLevel.String(),
					Payload:  logData.Payload,
					Time:     time.Now().Unix(),
				})
				fn(string(logMessage))
			}
		}
	}()
}

type LogInfo struct {
	LogLevel string `json:"logLevel"`
	Payload  string `json:"payload"`
	Time     int64  `json:"time"`
}

func handleStopLog() {
	if logStop != nil {
		close(logStop)
		logStop = nil
	}
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}
func handleGetCountryCode(ip string, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		codes := mmdb.IPInstance().LookupCode(net.ParseIP(ip))
		if len(codes) == 0 {
			fn("")
			return
		}
		fn(codes[0])
	}()
}

func handleGetMemory(fn func(value string)) {
	go func() {
		fn(strconv.FormatUint(statistic.DefaultManager.Memory(), 10))
	}()
}

var reqeustList = []statistic.Tracker{}
const maxRequestList = 1000

func init() {
	adapter.UrlTestHook = func(url string, name string, delay uint16) {
		delayData := &Delay{
			Name: name,
		}
		if delay == 0 {
			delayData.Value = -1
		} else {
			delayData.Value = int32(delay)
		}
		sendMessage(Message{
			Type: DelayMessage,
			Data: delayData,
		})
	}
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		reqeustList = append(reqeustList, c)
		if len(reqeustList) > maxRequestList {
			// 超过上限，丢弃最旧的 1/4 记录，防止无限增长
			drop := len(reqeustList) / 4
			reqeustList = reqeustList[drop:]
		}
		sendMessage(Message{
			Type: RequestMessage,
			Data: c,
		})
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		sendMessage(Message{
			Type: LoadedMessage,
			Data: providerName,
		})
	}
}
