
import { pasteboard,BusinessError } from '@kit.BasicServicesKit';

/**
 * 复制工具 From 冲浪喵
 */
export function copy(content: string) {
  let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);

  systemPasteboard.setData(pasteData).then(() => {
    console.info('Succeeded in setting PasteData.');
  }).catch((err: BusinessError) => {
    console.error('Failed to set PasteData. Cause: ' + err.message);
  })
}