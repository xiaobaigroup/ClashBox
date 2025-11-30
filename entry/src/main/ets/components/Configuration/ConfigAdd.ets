
import {
  APP_LINKING,
  BIND_SHEET_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BORDER_RADIUS_20, LIST_ITEM_HEIGHT,
  LIST_ITEM_PADDING,
  LIST_SPACE,
  RouteName
} from "../../common/entity/Constants";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BindSheetTitleCustomBuilder, ExperimentalFunction } from "../Common/Common";
import { UIConfig } from "../../entryability/AppState";
import { customAnimationUtil } from "../../common/utils/Animation";
import { removeItemsByIndex } from "../../common/utils/RemoveItemsUtils";
import { NavigationListPadding } from "../../common/breakpoint/BreakPoint";
import { ConfigData } from "../../common/entity/PageArgumentEntity";
import { scanCore, scanBarcode } from '@kit.ScanKit'; // 导入默认界面扫码
import { BusinessError } from '@kit.BasicServicesKit';

interface ConfigAddType {
  symbolStart? : Resource,
  // 内容
  text: ResourceStr,
  // NV路由栈name
  navPathStackName?: RouteName,
  isExperimentalFunction: boolean,
  symbolEnd?: Resource
}

const componentName: string = 'ConfigAdd'

@Component
export struct ConfigAdd {

  /* 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Consume('isEnableConfigPageBindSheetForegroundBlur') isEnableConfigPageBindSheetForegroundBlur: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  /* List 相关 */
  private configAddTypeArray: Array<ConfigAddType> = [
    { symbolStart: $r('sys.symbol.paperclip'), text: $r('app.string.Import_from_url'), navPathStackName: RouteName.IMPORT_CONFIG_FROM_URL, isExperimentalFunction: false,symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.qrcode'), text: $r('app.string.import_from_QR_code'), navPathStackName: RouteName.IMPORT_CONFIG_FROM_QR_CODE, isExperimentalFunction: false, symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.doc_text_fill'), text: $r('app.string.import_from_file'), navPathStackName: RouteName.IMPORT_CONFIG_FROM_FILE, isExperimentalFunction: false, symbolEnd: $r('sys.symbol.chevron_right')},
    // { symbolStart: $r('sys.symbol.doc'), text: $r('app.string.new_blank_configuration'), navPathStackName: RouteName.CREATE_NEW_CONFIG, isExperimentalFunction: true, symbolEnd: $r('sys.symbol.chevron_right')},
  ]

  /* NV路由 相关 */
  // 路由栈
  @Consume('configAddPageInfos') configAddPageInfos: NavPathStack

  // NV title Builder
  @State subTitle: string | Resource = 'subTitle'

  build() {
    Column(){
      // NV路由 START
      Navigation(this.configAddPageInfos){
        // 添加配置几种方式的ListItem START
        List({ space: LIST_SPACE }) {
          ForEach( this.configAddTypeArray, (item: ConfigAddType, index: number)=> {
            ListItem() {
              Row() {
                SymbolGlyph(item.symbolStart).fontSize(24).fontColor([this.icon_emphasize]).margin({ right: 20 })
                  .transition(customAnimationUtil.isScaleTranIcon(10,this.uiConfig))
                Text(item.text).fontSize(16).fontColor($r('sys.color.font_primary'))
                if (item.isExperimentalFunction) {
                  ExperimentalFunction()
                }
                Blank()
                SymbolGlyph(item.symbolEnd).fontSize(24).fontColor([$r('sys.color.icon')])
              }
              .width('100%')
              .padding(LIST_ITEM_PADDING)
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor($r('app.color.list_item_background_color'))
            .width('100%')
            .height(LIST_ITEM_HEIGHT)
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .borderRadius(BORDER_RADIUS_20)
            .onClick( () => {
              hilog.info(0xC020, componentName, `#ListItem#onClick(): NavPathStack.pushDestinationByName(${item?.navPathStackName}, null})`)
              if (this.uiConfig.isShowExperimentalFunction ? (index === 1 || index === 3) : index === 1) {
                this.importFromQR()
              } else {
                const params: ConfigData = {
                  configId: 'new',
                  isNewConfig: true,
                  configName: '',
                  configUrl: '',
                  disableUpdate: false,
                  isConfigAutoUpdate: false,
                  lastUpdateDateTime: 0,
                  updateTime: 0,
                }
                this.configAddPageInfos.pushPathByName(item?.navPathStackName, params, true)
              }
            })
          })
        }
        .height(`${(LIST_ITEM_HEIGHT + LIST_SPACE) * this.configAddTypeArray.length + 20}`)
        .width('100%')
        .padding({
          left: NavigationListPadding(this.widthBp, this.heightBp),
          right: NavigationListPadding(this.widthBp, this.heightBp)
        })
        // TODO下面这三个都不生效，bindSheet是用Scroll为根节点包裹的，但是nestedScroll也不生效 未知
        // .chainAnimation(true)
        .nestedScroll({scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY})
        .edgeEffect(EdgeEffect.Spring)
        // 添加配置几种方式的ListItem END
      }
      .title(
        {
          builder: BindSheetTitleCustomBuilder({
            pageInfos: this.configAddPageInfos,
            isSubPage: false,
            mainTitle: $r('app.string.add_config'),
            needSetHeight: true,
            mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
            mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
            subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
            padding: {
              left: NavigationListPadding(this.widthBp, this.heightBp),
              right: NavigationListPadding(this.widthBp, this.heightBp)
            },
            menus: []
          }),
          // height + 16 是因为设计稿里这56 没包含了dragBar的高度（16）
          height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT
        },
        {
          // barStyle: BarStyle.STACK,
        })
      .height(BIND_SHEET_CONTAINER_HEIGHT)
      .mode(NavigationMode.Stack)
      .hideBackButton(true)
      .navBarWidthRange([255, '100%'])
      .foregroundBlurStyle(this.isEnableConfigPageBindSheetForegroundBlur ? BlurStyle.Thin : BlurStyle.NONE,{ colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
      .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
      // NV路由 END
    }
    .height('auto')
    // .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })

  }

  aboutToAppear(): void {
    hilog.info(0xC020, componentName, `#aboutToAppear executed`)
    if(!this.uiConfig.enabledADvanced || !this.uiConfig.isShowExperimentalFunction) {
      // 屏蔽未开发
      this.configAddTypeArray = removeItemsByIndex(this.configAddTypeArray, [3])
    }
  }

  aboutToDisappear(): void {
    hilog.info(0xC020, componentName, `#aboutToDisappear executed`)
    this.configAddPageInfos.clear(true)
    hilog.info(0xC020, componentName, `#aboutToDisappear#NV路由configAddPageInfos已清空！`)
  }

  importFromQR() {
    // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    try {
      if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode")) {
        scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options,
          (error: BusinessError, result: scanBarcode.ScanResult) => {
            if (error) {
              hilog.error(0x0001, '[Scan CPSample]',
                `Failed to get ScanResult by callback with options. Code: ${error.code}, message: ${error.message}`);
              return;
            }
            // 解析码值结果跳转应用服务页
            const originalUrl = result.originalValue;
            hilog.info(0x0001, '[Scan CPSample]', `Succeeded in getting import origin url, origin url is ${originalUrl}`);
            let newUrl = ""
            let configName = ""
            // AppLinking 处理
            if (originalUrl.startsWith(APP_LINKING)) {
              const params= originalUrl.split("?configUrl=")[1].split("&configName=");
              newUrl = params[0]
              configName = params[1]
            } else {
              newUrl = this.processUrlByQueryIdentifier(originalUrl)
            }

            hilog.info(0x0001, '[Scan CPSample]', `Succeeded in process origin url, newUrl is ${newUrl}`);
            const params: ConfigData = {
              configId: 'newQR',
              isNewConfig: true,
              configName,
              configUrl: newUrl,
              disableUpdate: false,
              isConfigAutoUpdate: false,
              lastUpdateDateTime: 0,
              updateTime: 0,
            }
            this.configAddPageInfos.pushPathByName('ImportConfigFromURL', params, true)
          })
      } else {
        hilog.error(0x0001, '[Scan CPSample]',
          `Failed to get ScanResult by callback with options, because unsupported SystemCapability.`);
      }
    } catch (error) {
      hilog.error(0x0001, '[Scan CPSample]',
        `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 根据查询参数识别码处理URL
   * @param url 原始URL
   * @returns 处理后的URL
   */
  processUrlByQueryIdentifier(url: string): string {
    // 查找查询字符串起始位置
    const queryStartIndex = url.indexOf('?');
    // 如果没有查询参数，直接返回原URL
    if (queryStartIndex === -1) {
      return url;
    }
    // 查找片段标识符位置
    const fragmentStartIndex = url.indexOf('#', queryStartIndex);
    // 提取查询字符串部分
    const queryString = fragmentStartIndex === -1
      ? url.substring(queryStartIndex + 1)
      : url.substring(queryStartIndex + 1, fragmentStartIndex);
    // 解析查询参数
    const params = this.parseQueryString(queryString);
    // 检查是否存在flag参数（不区分大小写）
    const hasFlag = Object.keys(params).some(
      key => key.toLowerCase() === 'flag'
    );
    if (hasFlag) {
      // 删除整个查询字符串
      const baseUrl = url.substring(0, queryStartIndex);
      // 保留片段标识符（如果有）
      if (fragmentStartIndex !== -1) {
        return baseUrl + url.substring(fragmentStartIndex);
      }
      return baseUrl;
    }
    // 没有flag参数，保留原URL
    return url;
  }

  /**
   * 解析查询字符串
   * @param queryString 查询字符串（不包含?）
   * @returns 参数键值对对象
   */
  parseQueryString(queryString: string): Record<string, string> {
    const params: Record<string, string> = {};

    if (!queryString) {
      return params;
    }

    // 分割参数对
    const pairs = queryString.split('&');

    for (const pair of pairs) {
      // 分割键值
      const GeneratedDestructArray = pair.split('=', 2);
      const key = GeneratedDestructArray[0];
      const value = GeneratedDestructArray[1];

      if (key) {
        // 处理键值对（没有值时设为空字符串）
        params[key] = value !== undefined ? value : '';
      }
    }

    return params;
  }

}