import { hiAppEvent } from '@kit.PerformanceAnalysisKit';
import { router, window } from '@kit.ArkUI';
import { bundleManager, common } from '@kit.AbilityKit';
import { BusinessError, deviceInfo, pasteboard } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

const context = getContext() as common.UIAbilityContext
const crashData: Array<hiAppEvent.AppEventGroup> | undefined = AppStorage.get<Array<hiAppEvent.AppEventGroup>>('crashEvent')

@Component
export struct CrashPage {
  eventGroup?: hiAppEvent.AppEventGroup = undefined
  eventInfoList: Array<hiAppEvent.AppEventInfo> = this.eventGroup?.appEventInfos ?? []
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  windowClass = window.getLastWindow(context)
  @State topSafeHeight: number = 0;
  @State bottomSafeHeight: number = 0;

  aboutToAppear(): void {
    this.isEnableIndexForegroundBlur = true
    if (crashData && Array.isArray(crashData) && crashData.length > 0) {
      // eventGroup赋值为第一个数据
      this.eventGroup = crashData[0]
    }
  }

  build() {
    Column() {
      Swiper() {
        ForEach(this.eventGroup?.appEventInfos, (eventInfo: hiAppEvent.AppEventInfo) => {
          SwiperPage({
            eventInfo: eventInfo
          })
        })
      }
      .indicator(false)
      .loop(false)
    }.padding({top:AppStorage.get('topSafeHeight') as number,bottom:AppStorage.get('bottomSafeHeight') as number })
    .backgroundColor($r('app.color.start_window_background'))
  }
}

@Component
export struct SwiperPage {
  @Prop eventInfo: hiAppEvent.AppEventInfo
  //
  @State deviceType: string = ''
  @State marketName: string = ''
  @State displayVersion: string = ''
  @State osFullName: string = ''
  @State abiList: string = ''
  @State ODID: string = ''
  @State sdkApiVersion: string = ''
  //
  @State version: string = ''
  @State versionCode: string = ''
  @State releaseType: string = ''
  @State appProvisionType: string = ''
  @State show: boolean = false

  build() {
    Stack(){
      List({space: 15}){
        ListItem(){
          Column({space: 2}){
            Text($r('app.string.crash_title'))
              .fontSize(23)
              .fontWeight(FontWeight.Bold)
            Text($r('app.string.crash_subtitle'))
              .opacity(0.8)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          }.alignItems(HorizontalAlign.Start).padding({top: 10,left: 5,right: 5})

        }
        ListItem(){
          Column({space:5}){
            Item({ type: '设备型号', message: this.marketName })
            Item({ type: '系统版本', message: this.displayVersion })
            Item({ type: '内部版本', message: this.osFullName })
            Item({ type: '应用版本', message: this.eventInfo.params['bundle_version'] })
          }
        }.listItemStyles()

        ListItem(){
          Column({space: 5}){
            Item({ type: '崩溃类型', message: this.eventInfo.params['crash_type'] })
            Item({ type: '错误名称', message: this.eventInfo.params['exception'].name })
            Item({ type: '错误信息', message: this.eventInfo.params['exception'].message })
          }
        }.listItemStyles()

        ListItem(){
          Column({space: 5}){
            Item({ type: '详细信息' })
            Item1({ message: this.eventInfo.params['exception'].stack })
          }
        }.listItemStyles()

        ListItem(){
          Column({space: 5}){
            Text($r('app.string.show_full_log'))
              .size({width:'100%'})
              .textAlign(TextAlign.Start)
              .visibility(this.show?Visibility.None:Visibility.Visible)
              .animation({duration: 300, curve: Curve.Ease})
            Text(JSON.stringify(this.eventInfo.params))
              .size({width:'100%'})
              .textAlign(TextAlign.Start)
              .copyOption(CopyOptions.LocalDevice)
              .visibility(this.show?Visibility.Visible:Visibility.None)
              .animation({duration: 300,curve: Curve.Ease})
          }
          .onClick(()=>{
              this.show = !this.show
          })
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: this.show ? 1 : 0.95 })
        }.listItemStyles()

      }.clip(true)
      .borderRadius(20)
      .contentEndOffset(45)
      .scrollBar(BarState.Off)
      .size({width:'90%',height:'100%'})
    }.size({width:'100%',height:'100%'})
  }


  getDeviceInfo() {
    this.deviceType = deviceInfo.deviceType
    this.marketName = deviceInfo.marketName
    this.displayVersion = deviceInfo.displayVersion
    this.osFullName = deviceInfo.osFullName
    this.abiList = deviceInfo.abiList
    this.sdkApiVersion = deviceInfo.sdkApiVersion.toString()
    this.ODID = deviceInfo.ODID
  }

  getBundleInfo() {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.version = bundleInfo.versionName
      this.versionCode = bundleInfo.versionCode.toString()
      bundleInfo.minCompatibleVersionCode
      bundleInfo.targetVersion
      this.releaseType = bundleInfo.appInfo.releaseType
      this.appProvisionType = bundleInfo.appInfo.appProvisionType // debug
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
  }

  aboutToAppear(): void {
    this.getDeviceInfo()
    this.getBundleInfo()
  }
}

@Component
export struct Item {
  @Prop type: string
  @Prop message: string

  build() {
    Row() {
      Text(`${this.type}: `)
      Text(this.message).opacity(0.8)
        .layoutWeight(1).copyOption(CopyOptions.LocalDevice)
    }
  }
}

@Component
export struct Item1 {
  @Prop message: string

  build() {
    Row() {
      Text(this.message)
        .layoutWeight(1)
        .fontColor(Color.Red)
        .copyOption(CopyOptions.LocalDevice)
    }
  }
}

@Extend(ListItem)
function listItemStyles() {
  .borderRadius(20)
  .padding({ right: 15, left: 15, top: 10, bottom: 10 })
  .backgroundColor($r('app.color.FavoriteProxyDivider'))
}