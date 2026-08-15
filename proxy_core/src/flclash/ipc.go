package main

import (
	"context"
	"core/state"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"

	"github.com/metacubex/http"
)

func fileExists(filename string) bool {
	_, err := os.Stat(filename)
	return !os.IsNotExist(err)
}

func startIpcProxy(path string) {

	if fileExists(path) {
		if err := os.Remove(path); err != nil {
			log.Println("ipc_go", err)
			return
		}
	}

	listener, err := net.Listen("unix", path)
	if err != nil {
		log.Println("ipc_go", err)
		return
	}
	defer listener.Close()
	log.Println("ipc_go", "Server is listening on", path)
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Println("ipc_go Accept err:", err)
		}
		go handleConnection(conn)
	}
}
func handleConnection(conn net.Conn) {
	defer conn.Close()

	buffer := make([]byte, 10240)

	n, err := conn.Read(buffer)
	if err != nil {
		log.Println("ipc_go", err)
		return
	}
	request := RpcRequest{}
	err = json.Unmarshal(buffer[:n], &request)
	if err != nil {
		log.Println("ipc_go error", err)
		return
	}
	handleRemoteRequest(request, func(rr RpcResult) {
		res, _ := json.Marshal(rr)
		conn.Write([]byte(string(res) + "EOF"))
	})
}

type RpcRequest struct {
	Key    int          `json:"key"`
	Method ClashRpcType `json:"method"`
	Params []any        `json:"params"`
}
type RpcResult struct {
	Key    int          `json:"key"`
	Method ClashRpcType `json:"method"`
	Result string       `json:"result"`
	Error  string       `json:"error"`
}
type ClashRpcType int

// 定义常量来模拟枚举
const (
	QueryTrafficNow ClashRpcType = iota
	QueryTunnelState
	QueryTrafficTotal
	QueryProxyGroup
	QueryProviders
	ChangeProxy
	HealthCheck
	UpdateProvider
	UploadProvider
	QueryConnections
	CloseConnection
	ClearConnections
	Load
	StartClash
	StopClash
	ValidConfig
	Reset
	GetCountryCode
	UpdateGeoData
	RegisterOnMessage
	GetRequestList
	ClearRequestList
	SetLogObserver
	StopLogObserver
	VpnOptions
	SetOptionState
	GetVpnRunTime
	VpnConfigInited
	SetNetInterfaces
	DownloadConfig
	SetSystemDns
	HealthCheckAll
	HealthCheckBatch
	GetVersion
)

func handleRemoteRequest(request RpcRequest, fn func(RpcResult)) {
	ret := RpcResult{
		Key:    request.Key,
		Method: request.Method,
	}
	switch request.Method {
	case QueryTrafficNow:
		onlyProxy := true
		if len(request.Params) > 1 {
			res, _ := request.Params[0].(bool)
			onlyProxy = res
		}
		ret.Result = handleGetTraffic(onlyProxy)

		fn(ret)
	case QueryTrafficTotal:
		onlyProxy := true
		if len(request.Params) > 1 {
			res, _ := request.Params[0].(bool)
			onlyProxy = res
		}
		ret.Result = handleGetTotalTraffic(onlyProxy)
		fn(ret)
	case QueryProviders:
		ret.Result = handleGetExternalProviders()
		fn(ret)
	case QueryConnections:
		ret.Result = handleGetConnections()
		fn(ret)
	case QueryProxyGroup:
		ret.Result = handleGetProxies()
		fn(ret)
	case GetCountryCode:
		str, _ := request.Params[0].(string)
		handleGetCountryCode(str, func(value string) {
			ret.Result = value
			fn(ret)
		})
	case GetRequestList:
		ret.Result = HandleRequestList()
		fn(ret)
	case ClearRequestList:
		reqeustList = []statistic.Tracker{}
		fn(ret)
	case CloseConnection:
		str, _ := request.Params[0].(string)
		handleCloseConnection(str)
		fn(ret)
	case ClearConnections:
		handleCloseConnections()
		fn(ret)
	case Load:
		paramsString, _ := request.Params[0].(string)
		bytes := []byte(paramsString)
		ret.Result = handleUpdateConfig(bytes)
		fn(ret)
	case Reset:
		handleForceGc()
		fn(ret)
	case ValidConfig:
		filePath, _ := request.Params[0].(string)
		data, err := os.ReadFile(filePath)
		if err != nil {
			ret.Error = err.Error()
			fn(ret)
			return
		}
		ret.Result = handleValidateConfig(data)
		fn(ret)

	case UpdateGeoData:
		geoType, _ := request.Params[0].(string)
		geoName, _ := request.Params[1].(string)
		handleUpdateGeoData(geoType, geoName, func(value string) {
			ret.Result = value
			fn(ret)
		})
	case UpdateProvider:
		name, _ := request.Params[0].(string)
		log.Println("ipc_go", "UploadProvider ")
		handleUpdateExternalProvider(name, func(value string) {
			ret.Result = value
			log.Println("ipc_go", "UploadProvider: "+value)
			fn(ret)
		})
	case UploadProvider:
		provider, _ := request.Params[0].(string)
		pathUri, _ := request.Params[1].(string)
		data, err := os.ReadFile(pathUri)
		if err != nil {
			ret.Error = err.Error()
			fn(ret)
			return
		}

		handleSideLoadExternalProvider(provider, data, func(value string) {
			ret.Result = value
			fn(ret)
		})
	case ChangeProxy:
		group, _ := request.Params[0].(string)
		proxy, _ := request.Params[1].(string)
		proyInfo := map[string]string{
			"group-name": group,
			"proxy-name": proxy,
		}
		json, _ := json.Marshal(proyInfo)
		handleChangeProxy(string(json), func(value string) {
			ret.Result = value
			fn(ret)
		})
	case HealthCheck:
		name, _ := request.Params[0].(string)
		timeout := anyToInt(request.Params[1])
		testInfo := map[string]any{
			"proxy-name": name,
			"timeout":    timeout,
		}
		json, _ := json.Marshal(testInfo)

		handleAsyncTestDelay(string(json), func(value string) {
			ret.Result = value
			fn(ret)
		})
	case SetLogObserver:
		handleStartLog(func(value string) {
			ret.Result = value
			fn(ret)
		})
	case StopLogObserver:
		handleStopLog()
		fn(ret)
	case StartClash:
		tunFd := anyToInt(request.Params[0])
		log.Println("ipc_go", "tunFd", tunFd)
		StartTUN(tunFd, func(fd Fd) {
			res, _ := json.Marshal(fd)
			ret.Result = string(res)
			fn(ret)
		})
	case StopClash:
		StopTun()
		fn(ret)
	case VpnOptions:
		ret.Result = GetVpnOptions()
		fn(ret)
	case SetOptionState:
		paramsString, _ := request.Params[0].(string)
		err := json.Unmarshal([]byte(paramsString), state.CurrentState)
		if err != nil {
			ret.Error = err.Error()
		} else {
			ret.Result = ""
		}
		fn(ret)
	case GetVpnRunTime:
		ret.Result = GetRunTime()
		fn(ret)
	case VpnConfigInited:
		ret.Result = ConfigInited()
		fn(ret)
	case SetNetInterfaces:
		paramsString, _ := request.Params[0].(string)
		err := SetInterfaces(paramsString)
		if err != nil {
			ret.Error = err.Error()
		} else {
			ret.Result = ""
		}
		fn(ret)
	case DownloadConfig:
		if len(request.Params) < 3 {
			ret.Error = "downloadConfig requires url, User-Agent and filePath"
			fn(ret)
			return
		}
		url, _ := request.Params[0].(string)
		userAgent, _ := request.Params[1].(string)
		filePath, _ := request.Params[2].(string)
		data, err := handleDownloadConfig(url, userAgent, filePath)
		if err != nil {
			ret.Error = err.Error()
		} else {
			ret.Result = data
		}
		fn(ret)
	case SetSystemDns:
		paramsString, _ := request.Params[0].(string)
		UpdateSystemDns(paramsString)
		ret.Result = ""
		fn(ret)
	case HealthCheckAll:
		go handleHealthCheckAll()
		ret.Result = ""
		fn(ret)
	case HealthCheckBatch:
	  paramsString, _ := request.Params[0].(string)
	  handleAsyncTestDelayBatch(paramsString, func(value string) {
	   ret.Result = value
	   fn(ret)
	  })
	 case GetVersion:
		ver := constant.Version
		if ver == "" {
			ver = "Mihomo-release-v1.19.27"
		}
		ret.Result = ver
		fn(ret)
	default:
		ret.Error = "未知请求"
		fn(ret)
	}

}

func handleDownloadConfig(url string, userAgent string, filePath string) (string, error) {
	rawURL := strings.TrimSpace(url)
	userAgent = strings.TrimSpace(userAgent)
	filePath = strings.TrimSpace(filePath)
	if filePath == "" {
		return "", fmt.Errorf("filePath is empty")
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*20)
	defer cancel()

	parsedURL, authHeader, err := normalizeDownloadURL(rawURL)
	if err != nil {
		return "", err
	}
	// 不使用系统http, 因为系统http在某些机场配置返回403
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, parsedURL, nil)
	if err != nil {
		return "", err
	}
	if authHeader != "" {
		req.Header.Set("Authorization", authHeader)
	}
	if userAgent != "" {
		req.Header.Set("User-Agent", userAgent)
	} else {
		req.Header.Set("User-Agent", "clash-verge/v2.5.1")
	}

	client := &http.Client{
		Timeout:       time.Second * 20,
		Transport:     newDownloadTransport(),
		CheckRedirect: limitDownloadRedirects,
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		return "", fmt.Errorf("download config failed: %s %s", resp.Status, limitErrorBody(data))
	}
	if err := os.WriteFile(filePath, data, 0o644); err != nil {
		return "", err
	}

	result := map[string]string{
		"content-disposition":   resp.Header.Get("Content-Disposition"),
		"subscription-userinfo": getSubscriptionUserInfo(resp.Header),
	}
	resultJson, err := json.Marshal(result)
	if err != nil {
		return "", err
	}
	return string(resultJson), nil
}

func normalizeDownloadURL(rawURL string) (string, string, error) {
	parsedURL, err := url.Parse(rawURL)
	if err != nil {
		return "", "", fmt.Errorf("failed to parse subscription URL: %w", err)
	}

	if parsedURL.RawQuery == "" && strings.Contains(parsedURL.Path, "&") {
		path, dirtyParams, _ := strings.Cut(parsedURL.Path, "&")
		parsedURL.Path = path
		parsedURL.RawPath = ""
		parsedURL.RawQuery = dirtyParams
	}

	authHeader := ""
	if parsedURL.User != nil && parsedURL.User.Username() != "" {
		username, _ := url.PathUnescape(parsedURL.User.Username())
		password, _ := parsedURL.User.Password()
		password, _ = url.PathUnescape(password)
		authHeader = "Basic " + base64.StdEncoding.EncodeToString([]byte(username+":"+password))
		parsedURL.User = nil
	}

	return parsedURL.String(), authHeader, nil
}

func newDownloadTransport() *http.Transport {
	dialer := &net.Dialer{
		Timeout:   time.Second * 20,
		KeepAlive: time.Second * 60,
	}
	return &http.Transport{
		Proxy:               nil,
		DialContext:         dialer.DialContext,
		DisableKeepAlives:   true,
		TLSHandshakeTimeout: time.Second * 10,
	}
}

func limitDownloadRedirects(req *http.Request, via []*http.Request) error {
	if len(via) >= 10 {
		return fmt.Errorf("stopped after 10 redirects")
	}
	return nil
}

func getSubscriptionUserInfo(header http.Header) string {
	for key, values := range header {
		keyLower := strings.ToLower(key)
		if keyLower == "subscription-userinfo" || strings.HasSuffix(keyLower, "-subscription-userinfo") {
			if len(values) > 0 {
				return values[0]
			}
			return ""
		}
	}
	return ""
}

func limitErrorBody(data []byte) string {
	body := strings.TrimSpace(string(data))
	if body == "" {
		return ""
	}
	if len(body) > 512 {
		body = body[:512]
	}
	return body
}

func HandleRequestList() string {
	json, _ := json.Marshal(reqeustList)
	return string(json)
}

func anyToInt(val any) int {
	switch v := val.(type) {
	case int:
		return v
	case int64:
		return int(v)
	case float64:
		return int(v)
	case string:
		i, err := strconv.Atoi(v)
		if err == nil {
			return i
		}
	}
	return 0
}
