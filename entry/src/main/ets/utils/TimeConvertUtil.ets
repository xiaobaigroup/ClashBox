

function toTimestamp(dateString: string): number {
  const timestampMs = new Date(dateString.split("Z")[0].slice(0, -3) + "Z").getTime();

  // 转换为秒级时间戳（如果需要）
  const timestampSec = Math.floor(timestampMs / 1000);
  return timestampMs
}

/**
 * 时间戳转化计算间隔工具
 * @param timeStamp 传入的时间戳
 */
export function convertTime(timeStamp: number | string): string {
 if(typeof timeStamp == "string")
    timeStamp = toTimestamp(timeStamp)
 if(timeStamp <= 0) {
   // 如果时间戳小于等于0
   return `${getContext().resourceManager.getStringSync($r('app.string.now'))}`
 } else {
   const currentTimeStamp = new Date().getTime()
   // 将时间戳转化为秒
   const timeDifference = (currentTimeStamp - timeStamp) / 1000

   if (timeDifference < 60) {
     return `${getContext().resourceManager.getStringSync($r('app.string.now'))}`
   } else if (timeDifference < 3600) {
     return `${Math.floor(timeDifference / 60)}${getContext().resourceManager.getStringSync($r('app.string.minutes_ago'))}`
   } else if (timeDifference < 86400) {
     return `${Math.floor(timeDifference / 3600)}${getContext().resourceManager.getStringSync($r('app.string.hours_ago'))}`
   } else if (timeDifference < 604800) {
     return `${Math.floor(timeDifference / 86400)}${getContext().resourceManager.getStringSync($r('app.string.days_ago'))}`
   } else if (timeDifference < 2592000) {
     return `${Math.floor(timeDifference / 604800)}${getContext().resourceManager.getStringSync($r('app.string.weeks_ago'))}`
   }  else if (timeDifference < 31536000) {
     return `${Math.floor(timeDifference / 2592000)}${getContext().resourceManager.getStringSync($r('app.string.months_ago'))}`
   }else {
     return `${Math.floor(timeDifference / 3153600)}${getContext().resourceManager.getStringSync($r('app.string.years_ago'))}`
   }
 }
}

/**
 * 时间戳转化日常时间工具
 * @param timestamp 传入的时间戳
 */
export function timestampToDateTime(timestamp: number | string): string {
  if(typeof timestamp == "string")
    timestamp = toTimestamp(timestamp)
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  const seconds = date.getSeconds().toString().padStart(2, '0')

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}