
export const initClash: (path: string, version: string) => void;
export const startTun: (fd: number, callback: (id: number, fd: number) => void) => number;
export const getVpnOptions: ()  => string;
export const setFdMap: (fd: number) => void;
export const stopTun: () => void;
export const forceGc: () => void;
export const validateConfig: (paramsString: string) => Promise<string>;
export const updateConfig: (paramsString: string) => Promise<string>;

export const getProxies: () => string;
export const changeProxy: () => Promise<string>;
export const getTraffic: () => string;
export const getTotalTraffic: () => string;
export const resetTraffic: () => void;
export const asyncTestDelay: (paramsString: string) => Promise<string>;
export const getExternalProviders: () => string;
export const getExternalProvider: (name: string) => string;
export const updateExternalProvider: (name: string) =>  Promise<string>;
export const sideLoadExternalProvider: (name: string, data: string) =>  Promise<string>;
export const updateGeoData: (type: string, name: string) => Promise<string>;
export const getConnections: () => Promise<string>;
export const closeConnections: () => string;
export const closeConnection: (connectionId: string) => string;

export const startLog: (callback: (message: string) => void) => string;

export const stopLog: () => void;