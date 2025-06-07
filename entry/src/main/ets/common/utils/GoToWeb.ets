import { common, Want } from "@kit.AbilityKit"

/**
 * 隐式 Want 跳转网站
 */
export async function implicitStartAbility(url: string, context: common.UIAbilityContext) {
  try {
    let want: Want = {
      // 如果希望仅在特定包中隐式查询，请取消下面的注释行
      // bundleName: "com.example.myapplication",
      "action": "ohos.want.action.viewData",
      // entities可以省略
      "entities": [ "entity.system.browsable" ],
      "uri": url,
    }
    await context.startAbility(want)
    console.info(`explicit start ability succeed`)
  } catch (error) {
    console.info(`explicit start ability failed with ${error.code}`)
  }
}