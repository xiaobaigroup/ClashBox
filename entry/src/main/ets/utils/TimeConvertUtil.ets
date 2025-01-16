import { getResourceString } from "./ResourceStringUtil"

/**
 * 时间戳转化工具
 * @param timeStamp 传入的时间戳
 */
export function convertTime(timeStamp: number): string {
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