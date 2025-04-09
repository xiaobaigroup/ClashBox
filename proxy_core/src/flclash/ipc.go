package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"
)

func startIpcProxy(path string) {
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		log.Fatal("ipc_go", err)
	}
	listener, err := net.Listen("unix", path)
	if err != nil {
		log.Fatal("ipc_go", err)
	}
	defer listener.Close()
	log.Println("ipc_go", "Server is listening on", path)
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleConnection(conn)
	}
}
func handleConnection(conn net.Conn) {
	defer conn.Close()
	buffer := make([]byte, 10240)

	_, err := conn.Read(buffer)
	if err != nil {
		log.Fatal("ipc_go", err)
	}
	request := RpcRequest{}
	err = json.Unmarshal(buffer, request)
	if err != nil {
		log.Fatal("ipc_go", err)
	}
	handleRemoteRequest(request, func(rr RpcResult) {
		fmt.Println("Received:", rr)
		res, _ := json.Marshal(rr)
		conn.Write(res)
	})

}

type RpcRequest struct {
	Key    int
	Method ClashRpcType
	Params []any
}
type RpcResult struct {
	Key    int
	Result string
	Error  string
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
	SetLogObserver
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
)

func handleRemoteRequest(request RpcRequest, fn func(RpcResult)) {
	print("handle", request.Key)
	ret := RpcResult{
		Key: request.Key,
	}
	switch request.Method {
	case QueryTrafficNow:
		ret.Result = handleGetTraffic(true)
		fn(ret)
	case QueryTrafficTotal:
		ret.Result = handleGetTotalTraffic(true)
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
		handleUpdateConfig(bytes)
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
		handleUpdateExternalProvider(name, func(value string) {
			ret.Result = value
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
		proxy, _ := request.Params[0].(string)
		handleAsyncTestDelay(proxy, func(value string) {
			ret.Result = value
			fn(ret)
		})
	}
}
