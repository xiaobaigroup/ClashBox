import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Xb_ToastUtil } from '../utils/ToastUtils';
import { LoginPanel, loginComponentManager } from '@kit.AccountKit';


/**
 * 华为账号登录
 */
@ComponentV2
export struct Xb_Account{
  //头像
  @Local avatar?: ResourceStr = ''
  @Local isShow: boolean = false

  build() {
    Row(){
      if (this.isShow){
        Image(this.avatar).width(80).height(80).borderRadius(100)
        Text('账号登录').textStyle()
      }else {
        Column({space: 10}){
          SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
            .fontSize(80)
            .fontColor([Color.White]).borderRadius(100)
          Text('账号登录').textStyle()
        }
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({top: 10, bottom: 10})
    //.bindSheet(this.isShow!!, this.login())
    .onClick(()=>{

    })
  }
}

@Extend(Text)
function textStyle(){
  .padding({right: 10, left: 10, top: 5, bottom: 5})
  .backgroundColor($r('sys.color.font_emphasize')).borderRadius(100)
}