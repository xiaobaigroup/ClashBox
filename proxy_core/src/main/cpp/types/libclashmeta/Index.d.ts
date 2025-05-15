

export const nativeStartTun: (fd: number, callback: (fd: number) => void) => number;
export const nativeFetchAndValid: (path: string, url: string, force: boolean, callback: (type: string, value: string) => void ) => boolean;
export const nativeHealthCheck: ( name: string, callback: (value: string) => void ) => string;
export const nativeLoad: (path: string,  callback: (value: string) => void ) => boolean;
export const nativeSubscribeLogcat: (callback: (value: string) => void ) => string
export const nativeUpdateProvider: (type: string, name: String, callback: ( value: string) => void ) => void;


export const nativeStopTun: () => void;
export const nativeStartHttp: (listenAt: string) => string;
export const nativeStopHttp: () => void;
export const nativeQueryGroupNames: (excludeNotSelectable: boolean) => string;
export const nativeQueryGroup: (name: string, sort: string) => string;
export const nativeHealthCheckAll: () => void;
export const nativePatchSelector: (selector: string, name: string) => boolean;
export const nativeInit: (path: string, version: string) => void;
export const nativeQueryProviders: () => string;
export const nativeInstallSideloadGeoip: (bytes: Uint8Array) => void
export const nativeQueryConfiguration: () => string
export const nativeCoreVersion: ( ) => string
export const nativeReset: () => void;
export const nativeForceGc: () => void;
export const nativeSuspend: (suspend: Boolean) => void;
export const nativeQueryTunnelState: () => string;
export const nativeWriteOverride: (slot: number, content: String) => void;
export const nativeReadOverride: (slot: number) => string;
export const nativeClearOverride: (slot: number) => void;

export const nativeQueryTrafficNow: () => number;
export const nativeQueryTrafficTotal: () => number;

//TODO ohos 不一定支持
export const nativeNotifyDnsChanged: (dnsList: string) => number;