import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * WebDAV 客户端配置
 */
export interface WebDavConfig {
  /** WebDAV 服务器根地址，例如 'https://dav.jianguoyun.com/dav/' */
  baseUrl: string;
  /** 用户名 (用于 Basic Auth) */
  username?: string;
  /** 密码 (用于 Basic Auth) */
  password?: string;
  /** 认证类型，目前仅支持 'basic' */
  authType?: 'basic' | 'digest' | 'bearer' | 'none';
}

/**
 * WebDAV 操作结果
 */
export interface WebDavResponse {
  statusCode: number;
  headers: rcp.ResponseHeaders;
  data: string | ArrayBuffer | Record<string, Object>;
}

/**
 * 文件信息接口
 */
export interface FileInfo {
  name: string;
  path: string;
  isDirectory: boolean;
  size: number; // 文件大小（字节），文件夹为 0
  lastModified: string;
}

/**
 * WebDAV 连通性测试结果配置
 */
export interface ConnectionTestResult {
  /** 测试是否成功 */
  success: boolean;
  /** 结果的详细描述，可直接用于 UI 提示 */
  message: string;
  /** HTTP 响应状态码（如果收到响应） */
  statusCode?: number;
}

/**
 * 日志条目接口
 */
export interface LogEntry {
  timestamp: Date;
  level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';
  category: string;
  message: string;
  data?: any;
}

/**
 * 日志回调函数类型
 */
export type LogCallback = (log: LogEntry) => void;