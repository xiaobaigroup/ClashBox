//go:build ohos && cgo

package main

import "C"
import (
	"core/platform"
	"core/state"
	t "core/tun"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
    "net"
	"github.com/metacubex/mihomo/component/iface"
)

type ProcessMap struct {
	m sync.Map
}

type FdMap struct {
	m sync.Map
}

type Fd struct {
	Id    int64 `json:"id"`
	Value int64 `json:"value"`
}

var (
	tunListener *sing_tun.Listener
	fdMap       FdMap
	fdCounter   int64 = 0
	counter     int64 = 0
	processMap  ProcessMap
	tunLock     sync.Mutex
	runTime     *time.Time
	errBlocked  = errors.New("blocked")
)

func (cm *ProcessMap) Store(key int64, value string) {
	cm.m.Store(key, value)
}

func (cm *ProcessMap) Load(key int64) (string, bool) {
	value, ok := cm.m.Load(key)
	if !ok || value == nil {
		return "", false
	}
	return value.(string), true
}

func (cm *FdMap) Store(key int64) {
	cm.m.Store(key, struct{}{})
}

func (cm *FdMap) Load(key int64) bool {
	_, ok := cm.m.Load(key)
	return ok
}

func StartTUN(fd int, markSocket func(Fd)) {
	if fd == 0 {
		tunLock.Lock()
		defer tunLock.Unlock()
		now := time.Now()
		runTime = &now
		// SendMessage(Message{
		// 	Type: StartedMessage,
		// 	Data: strconv.FormatInt(runTime.UnixMilli(), 10),
		// })
		return
	}
	initSocketHook(markSocket)
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()
		f := int(fd)
		tunListener, _ = t.Start(f, currentConfig.General.Tun.Device, currentConfig.General.Tun.Stack)
		if tunListener != nil {
			log.Infoln("TUN address: %v", tunListener.Address())
		}
		now := time.Now()
		runTime = &now
	}()
}

func GetRunTime() string {
    if runTime == nil {
		return "clash服务未启动"
	}
	return strconv.FormatInt(runTime.UnixMilli(), 10)
}
func ConfigInited() string {
	if currentConfig != nil {
		return "true"
	}
	return "false"
}

func StopTun() {
	go func() {
		tunLock.Lock()
		defer tunLock.Unlock()

		runTime = nil

		if tunListener != nil {
			_ = tunListener.Close()
		}
		removeSocketHook()
	}()
}

func SetFdMap(fd C.long) {
	fdInt := int64(fd)
	go func() {
		fdMap.Store(fdInt)
	}()
}

func initSocketHook(markSocket func(Fd)) {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		return conn.Control(func(fd uintptr) {
			fdInt := int64(fd)
			timeout := time.After(500 * time.Millisecond)
			id := atomic.AddInt64(&fdCounter, 1)

			markSocket(Fd{
				Id:    id,
				Value: fdInt,
			})

			for {
				select {
				case <-timeout:
					return
				default:
					exists := fdMap.Load(id)
					if exists {
						return
					}
					time.Sleep(20 * time.Millisecond)
				}
			}
		})
	}
}

func removeSocketHook() {
	dialer.DefaultSocketHook = nil
}

func init() {
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		if metadata == nil {
			return "", process.ErrInvalidNetwork
		}
		id := atomic.AddInt64(&counter, 1)

		timeout := time.After(200 * time.Millisecond)

		// SendMessage(Message{
		// 	Type: ProcessMessage,
		// 	Data: Process{
		// 		Id:       id,
		// 		Metadata: metadata,
		// 	},
		// })

		for {
			select {
			case <-timeout:
				return "", errors.New("package resolver timeout")
			default:
				value, exists := processMap.Load(id)
				if exists {
					return value, nil
				}
				time.Sleep(20 * time.Millisecond)
			}
		}
	}
}

func SetProcessMap(s string) string {
	paramsString := s
	go func() {
		var processMapItem = &ProcessMapItem{}
		err := json.Unmarshal([]byte(paramsString), processMapItem)
		if err == nil {
			processMap.Store(processMapItem.Id, processMapItem.Value)
		}
	}()
	return ""
}

func GetCurrentProfileName() string {
	if state.CurrentState == nil {
		return ""
	}
	return state.CurrentState.CurrentProfileName
}

func GetVpnOptions() string {
	tunLock.Lock()
	defer tunLock.Unlock()
	port := 7980
	if (currentConfig != nil){
	    port = currentConfig.General.MixedPort
	}
	options := state.AndroidVpnOptions{
		Enable:           state.CurrentState.Enable,
		Port:             port,
		Ipv4Address:      state.CurrentState.TunIp,
		Ipv6Address:      state.GetIpv6Address(),
		AccessControl:    state.CurrentState.AccessControl,
		SystemProxy:      state.CurrentState.SystemProxy,
		AllowBypass:      state.CurrentState.AllowBypass,
		RouteAddress:     state.CurrentState.RouteAddress,
		BypassDomain:     state.CurrentState.BypassDomain,
		DnsServerAddress: state.GetDnsServerAddress(),
	}
	data, err := json.Marshal(options)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func SetState(s *C.char) {
	paramsString := C.GoString(s)
	err := json.Unmarshal([]byte(paramsString), state.CurrentState)
	if err != nil {
		return
	}
}

func UpdateDns(s *C.char) {
	dnsList := C.GoString(s)
	go func() {
		log.Infoln("[DNS] updateDns %s", dnsList)
		dns.UpdateSystemDNS(strings.Split(dnsList, ","))
		dns.FlushCacheWithDefaultResolver()
	}()
}


type NetIpMacInfo struct {
    IpAddress NetAddress  `json:"ipAddress"`
	Iface string `json:"iface"`
	MacAddress string `json:"macAddress"`
}
type NetAddress struct {
    Address string `json:"address"`   // IP地址
    Family  int    `json:"family"`    // 地址族：4(IPv4)或6(IPv6)
    Port    int    `json:"port"`      // 端口号（如果有）
}

func (info *NetIpMacInfo) ToNetInterface() (*net.Interface, error) {
    // 解析 MAC 地址
    var mac net.HardwareAddr
    if info.MacAddress != "" {
        var err error
        mac, err = net.ParseMAC(info.MacAddress)
        if err != nil {
            return nil, fmt.Errorf("parse MAC address failed: %w", err)
        }
    }

    // 获取接口索引（通过接口名）
    var index int
    if info.Iface != "" {
        iface, err := net.InterfaceByName(info.Iface)
        if err == nil && iface != nil {
            index = iface.Index
        }
    }

    return &net.Interface{
        Index:        index,
        MTU:          1500,                    // 默认值，你可能需要从其他地方获取
        Name:         info.Iface,
        HardwareAddr: mac,
        Flags:        getInterfaceFlags(info), // 需要实现这个函数
    }, nil
}
func getInterfaceFlags(info *NetIpMacInfo) net.Flags {
    var flags net.Flags

    // 如果 MAC 地址存在，通常接口是启用的
    if info.MacAddress != "" {
        flags |= net.FlagUp
        flags |= net.FlagBroadcast
        flags |= net.FlagMulticast
    }

    // 检查是否为回环接口
    if info.Iface == "lo" || info.Iface == "lo0" {
        flags |= net.FlagLoopback
    }
    return flags
}

func SetInterfaces(paramsString string) error{
    var interfaces []net.Interface
    var infos []NetIpMacInfo
    err := json.Unmarshal([]byte(paramsString), infos)
    if(err != nil){
        return err
    }
    seen := make(map[string]bool) // 去重
    for _, info := range infos {
        if seen[info.Iface] {
            continue
        }
        iface, err := info.ToNetInterface()
        if err != nil {
            continue // 或者返回错误
        }

        if iface != nil {
            interfaces = append(interfaces, *iface)
            seen[info.Iface] = true
        }
    }
    iface.SetNetInterfaces(interfaces)
    return nil
}
