import { common, wantConstant } from "@kit.AbilityKit";

/**
 * 拉起邮件类应用（mailto方式）
 *
 * @param address 填写示例：mailto:xfz347@gmail.com?subject=反馈&body=你的内容...
 */
export async function
handleMailto(address: string, ctx: common.UIAbilityContext) {
  ctx.startAbility({
    action: 'ohos.want.action.sendToData',
    uri: address
  })
}

/**
 * 拉起邮件类应用（Want方式）
 */
export function handleMail(email:string, subject: string, content: string, context: common.UIAbilityContext) {
  let wantParam: Record<string, Object> = {
    'sceneType': 1,
    // 收件人邮箱地址，多值以逗号分隔，对数组内容使用encodeURI()方法进行url编码
    'email': [encodeURI(email)],
    // 抄收人邮箱地址，多值以逗号分隔，对数组内容使用encodeURI()方法进行url编码
    // 'cc': [encodeURI('xxx@example.com'),encodeURI('xxx@example.com')],
    // 密送人邮箱地址，多值以逗号分隔，对数组内容使用encodeURI()方法进行url编码
    // 'bcc': [encodeURI('xxx@example.com'),encodeURI('xxx@example.com')],
    // 邮件主题，对内容使用encodeURI()方法进行url编码
    'subject': encodeURI(subject),
    // 邮件正文，对内容使用encodeURI()方法进行url编码
    'body': encodeURI(content),
    // 附件uri，多值以逗号分隔，对数组内容使用encodeURI()方法进行url编码
    // 'ability.params.stream': [encodeURI('附件uri1'),encodeURI('附件uri2')],
    'ability.want.params.uriPermissionFlag': wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
  };
  let abilityStartCallback: common.AbilityStartCallback = {
    onError: (code: number, name: string, message: string) => {
      console.log(`onError code ${code} name: ${name} message: ${message}`);
    },
    onResult: (result)=>{
      console.log(`onResult result: ${JSON.stringify(result)}`);
    }
  }

  context.startAbilityByType("mail", wantParam, abilityStartCallback,
    (err) => {
      if (err) {
        console.error(`startAbilityByType fail, err: ${JSON.stringify(err)}`);
      } else {
        console.log(`success`);
      }
    });
}