# 上游 Issue 草稿(提交至 xiaobaigroup/ClashBox,可关联 #158)

## 标题

[问题报告 BUG] 商店版(V2/2.0.x)每隔约 180.5 秒周期性清空全部活动连接(长连接被同步 FIN)

## 正文

### 现象

ClashBox 商店版(org.xbgroup.clashbox,V2/2.0.x)运行时,所有活动连接(TUN/Fake-IP、
localhost mixed/socks 入站、无关的不同远端、不同建立时长的连接)会在同一时刻被
关闭。应用侧表现为有序 FIN:read()==0、POLLRDHUP、SO_ERROR==0、TCP_INFO=CLOSE_WAIT;
TLS 上层(rustls)报 "peer closed connection without sending TLS close_notify"。
Mihomo 控制器在同一时刻 connections 变为 null(全部 tracker 被移除),随后立刻出现
全新 ID 的连接。ClashBox 两个进程、vpn-tun 网卡、路由表、系统网络回调全部正常。

### 周期

对 8 个 wipe 时刻做最小二乘拟合:周期 180.5004 s,52 个周期内残差 < ±0.5 s。
这是软件定时器,不是网络抖动。网格相位锚定在 ClashBox(VPN/核心)启动时刻
+约 3 秒,而不是绝对墙钟;重启 ClashBox 后网格相位随新实例平移。

### 关键判据(可复核)

1. 对照实验(同机同网):ClashBox 关闭时,独立运行的 mihomo v1.19.27(相同订阅
   配置)+ 探针存活 11 个完整网格周期无任何 wipe;ClashBox 开启后,每个可观测
   网格周期都会清掉全部连接(包括走 ClashBox VPN 的独立 mihomo 的连接)。
2. 每个 wipe 时刻,空闲的 HTTP/1.1 keep-alive 控制器连接(127.0.0.1:9090)存活。
   若是非 patch 的 Load(method 12):hub.ApplyConfig → route.ReCreateServer →
   httpServer.Close(),会关闭该连接(metacubex/http v0.1.6 server.go:3082)。
   因此周期性 RPC 不是非 patch Load。
3. wipe 时刻核心日志中**没有** "RESTful API listening at"(每次 ReCreateServer
   都会打这行 info 日志,hub/route/server.go:174)。再次排除 Load。
4. 综合 2、3:周期性 RPC 是 method 11(ClearConnections)。公开 LTS 源码中它的
   唯一调用方是"连接管理"页面的手动清理按钮(Connect.ets:147-157)。因此周期性
   调用方只存在于未公开的 V2 代码中。
5. 该周期任务只在 ClashBox **UI 进程正在执行**(前台,或持有后台保活:长时任务/
   模拟画中画等)时运行;UI 进程被冻结(CPU 计数完全不动)时,网格 wipe 停止,
   但 VPN 转发正常。

### 影响

- 任何超过约 180 s 的长连接(WebSocket、SSE、HTTP/2 长连接、下载、SSH 等)
  必然在下一个网格时刻被掐断;对 TLS 上层表现为 UnexpectedEof。
- 正常用户(开启后台保活)全天候受影响;表现为"代理周期性地全部断线又瞬间恢复"。

### 请求维护者确认

V2 中是否存在一个约 180 s 周期的 ArkTS 定时任务,会经 clash_go.sock 调用
ClearConnections(method 11)?(候选方向:连接管理/状态同步/健康检查/自动更新
相关逻辑。)该定时任务不应在例行执行中清空全部活动连接;手动清理功能本身需要保留。

### 环境

- HarmonyOS PC(鸿蒙电脑),HongMeng Kernel 1.12.0;商店版 ClashBox(V2 线,
  控制器报告 Mihomo 1.19.27)。
- 注:公开仓库当前为 LTS 线(1.7.4/master 1fdc47eb),与商店版无源码对应关系;
  以上 2、3 两条判据依赖商店版内核在这两个路径上与公开 v1.19.27 行为一致。
