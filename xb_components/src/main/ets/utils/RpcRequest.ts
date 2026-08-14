
export interface RpcRequest {
  method: number;
  params: (string | number | boolean) [];
}
export interface RpcResult {
  result?: string | number | boolean ;
  error?: string;
}