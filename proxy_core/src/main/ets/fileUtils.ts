
import  fs from  "@ohos.file.fs"
import { fileUri } from "@kit.CoreFileKit";

export async  function readFileUri(uri: string, tempPath: string): Promise<Uint8Array | null> {
  fs.copy(uri, fileUri.getUriFromPath(tempPath))
  return await readFile(tempPath)
}

export async function readFile(filePath: string): Promise<Uint8Array | null> {
  if(!await fs.access(filePath))
    return null;
  const file = await fs.open(filePath)
  const stats = await fs.stat(filePath)
  let bufSize = stats.size;
  let buf = new ArrayBuffer(bufSize);
  await fs.read(file.fd, buf, { offset: 0, length: bufSize });
  await fs.close(file);
  return new Uint8Array(buf);
}
export async function readText(filePath: string): Promise<string>{
  if(!await fs.access(filePath))
    return "";
  return await fs.readText(filePath)
}
export function writeFile(filePath: string, data: Uint8Array | null) {
  if(data != null && data.byteLength > 0){
    const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
    fs.writeSync(file.fd, data.buffer);
    fs.fsyncSync(file.fd)
    fs.closeSync(file);
  }
}

 /**
 * 解码 Unicode 转义字符串
 * 支持 \uXXXX 格式（包括代理对 \uD83D\uDE00 → emoji）
 */
export function decodeUnicodeEscape(str: string): string {
  return str.replace(/\\u([0-9a-fA-F]{4})/g, (_, hex) => {
    return String.fromCharCode(parseInt(hex, 16));
  });
}
