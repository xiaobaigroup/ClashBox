import { UIConfig } from "../../entryability/AppState"
import { BindSheetTitleCustomBuilderMenu, CustomConfirmDialog } from "../Common/Common"
import { fileUri, ReadOptions } from "@kit.CoreFileKit"
import { fileIo as fs } from '@kit.CoreFileKit';
import { util } from "@kit.ArkTS";
import {
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_MAIN_FONT_WEIGHT, BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT} from "../../common/entity/Constants";
import { NavigationListPadding } from "../../common/breakpoint/BreakPoint";
import { BindSheetTitleCustomBuilder } from "../Common/Common";
import { HMCodeEditor } from 'hm_code_editor';

@Builder
export function EditConfigContentBuilder(name: string, param: Object){
  EditConfigContent()
}

@Component
struct EditConfigContent {

  private configID: string = ''
  @State configStr: string = ''
  private contentChange: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 主页面栈
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 当前显示的工具集合 默认为空 待发生编辑事件之后才加入保存按钮菜单
  @State private fileMenus: Array<BindSheetTitleCustomBuilderMenu> = []
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  /** 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Consume('isEnableConfigPageBindSheetForegroundBlur') isEnableConfigPageBindSheetForegroundBlur: boolean

  build() {
    NavDestination() {
      // 标题栏
      BindSheetTitleCustomBuilder({
        pageInfos: this.pageInfos,
        isSubPage: true,
        titlePaddingLeft: BIND_SHEET_DRAG_BAR_HEIGHT / 2,
        mainTitle: $r('app.string.edit_config'),
        subTitle: '',
        mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
        mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
        subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
        titleBackgroundColor: $r('app.color.background'),
        padding: {
          // 为什么设置`15`，看Builder的参数中`padding`的介绍：ConfigAddBindSheetTitleBuilderParam
          left: 15,
          right: BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 15 * 2
        },
        menus: this.fileMenus
      })
      // 编辑器
      HMCodeEditor({
        initialContent: this.configStr,
        language: 'markdown',
        theme: 'vs',
        readOnly: false,
        fontSize: 16,
        showMinimap: true,
        wordWrap: 'on',
        lineNumbers: 'on',
        // 事件回调
        onContentChanged: (content: string) => {

          console.log('内容已更改:', content.length, '字符');
        },
        onCursorPositionChanged: (line: number, column: number) => {

        },
        onSelectionChanged: (selectedText: string) => {
          if (selectedText) {
            console.log('选中文本:', selectedText);
          }
        },
        onEditorInitialized: () => {
          console.log('编辑器初始化完成');
        },
        onError: (error: string) => {
          console.error('编辑器错误:', error);
        }
      })
    }
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.contentChange) {
        // 弹框是否保存已经编辑好的配置
        this.configCustomConfirmDialogController?.open()
        // 更改bindSheet的前景模糊
        this.isEnableConfigPageBindSheetForegroundBlur = true
        return true
      } else {
        return false
      }
    })
    .onReady( (ctx: NavDestinationContext) => {
      // 接收信息
      try {
        const params: string = ctx?.pathInfo?.param as string
        console.log('ClashBox #EditConfigContent #onReady 编辑配置页接收的params：', params)
        if (params) {
          // 赋值配置ID
          this.configID = params
          this.loadConfigContent()
        }
      } catch (e) {
        console.log(`ClashBox#ImportConfigFromFile#onReady Navigate onReady catch exception: ${JSON.stringify(e)}`)
      }
    })
    .animation({ duration:  this.uiConfig.animationSpeed , curve: Curve.Ease })
  }

  /** 保存配置 */
  saveConfigContent() {

  }

  loadConfigContent() {
    const context = this.getUIContext().getHostContext()!
    const sandPath = context.filesDir + `/ClashBox/profiles/` + this.configID + '/config.yaml'
    const sandUri = fileUri.getUriFromPath(sandPath)
    try {
      const file = fs.openSync(sandUri, fs.OpenMode.READ_ONLY);
      try {
        console.log('#EditConfigContent.loadConfigContent file fd:', file.fd);
        const stats = fs.statSync(file.path);
        const fileSize = stats.size;
        console.log('#EditConfigContent.loadConfigContentile fileSize:', fileSize);
        let buffer = new ArrayBuffer(fileSize);
        const readOptions: ReadOptions = {
          offset: 0,
          length: fileSize
        };
        console.log('#EditConfigContent.loadConfigContent readOptions:', JSON.stringify(readOptions));
        fs.readSync(file.fd, buffer, readOptions);
        let textDecoder = util.TextDecoder.create("UTF-8", { ignoreBOM: false });
        this.configStr = textDecoder.decodeToString(new Uint8Array(buffer));
        console.debug(`读取到的配置内容：${this.configStr}`)
      } catch (err) {
        console.error(`读取配置文件失败，name: ${err.name} message: ${err.message}`)
      } finally {
        // 关闭文件
        fs.closeSync(file)
      }
    } catch (error) {
      console.error(`打开配置文件失败，name: ${error.name} message: ${error.message}`)
    }
  }

  // 配置是否保存弹框 Controller定义
  private configCustomConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomConfirmDialog({
      title: $r('app.string.save_current_configuration'),
      cancelText: $r('app.string.Cancel'),
      confirmText: $r('app.string.Save'),
      cancelButtonBackgroundColor: Color.Transparent,
      cancel: () => {
        this.pageInfos.pop(true)
      },
      confirm: ()=> {
        // 保存配置
        this.saveConfigContent()
        this.pageInfos.pop(true)
      }
    }),
    cancel: () => {
      this.pageInfos.pop(true)
    },
    alignment: DialogAlignment.Center,
    width: 328,
    backgroundColor: $r('app.color.list_item_background_color'),
  })

  // 保存按钮
  private saveMenus: BindSheetTitleCustomBuilderMenu = {
    symbol: $r('sys.symbol.save'),
    symbolFontColor: ['#e6ffffff'],
    // 跟随主题色：由于在这里直接赋值 this.icon_emphasize 编译器提示需要初始化 this.icon_emphasize 的值，放到了 aboutToAppear 回调里重新赋值
    symbolBackgroundColor: '#FF0A59F7',
    action: () => {
      this.saveConfigContent()
      // 保存配置后返回上一页
      this.pageInfos.pop(true)
    }
  }

}