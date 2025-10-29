import { UIConfig } from "../../entryability/AppState"
import { BindSheetTitleCustomBuilderMenu, CustomConfirmDialog } from "../Common/Common"
import {
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_MAIN_FONT_WEIGHT, BIND_SHEET_SUB_FONTSIZE,} from "../../common/entity/Constants";
import { BindSheetTitleCustomBuilder } from "../Common/Common"
import { HMCodeEditor } from 'hm_code_editor';
import { EventHub, EventKey } from "../../common/EventHub";
import { WebCodeEditor } from "../Common/CodeEditor";
import { EditorCommunicationManager, WebCodeEditorOptions } from "../../common/entity/WebCodeEditor";
import { webview } from "@kit.ArkWeb";
import { hilog } from "@kit.PerformanceAnalysisKit";

@Builder
export function EditConfigContentBuilder(name: string, param: Object){
  EditConfigContent()
}

@Component
struct EditConfigContent {

  /** 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Consume('isEnableConfigPageBindSheetForegroundBlur') isEnableConfigPageBindSheetForegroundBlur: boolean
  // 是否显示bindSheet
  @StorageLink('ShowConfigBindSheet') isShowConfigAddBindSheet: boolean = false
  @StorageLink('ConfigContentChange') configContentChange: boolean = false
  @Consume('currentColorMode') currentColorMode: boolean

  @StorageLink('ConfigContent') configStr: string = ''

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 主页面栈
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 当前显示的工具集合 默认为空 待发生编辑事件之后才加入保存按钮菜单
  @State private fileMenus: Array<BindSheetTitleCustomBuilderMenu> = []

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 导航条区域的高度
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  @State webController: webview.WebviewController = new webview.WebviewController();
  // 通信管理器实例
  @State commManager: EditorCommunicationManager = new EditorCommunicationManager(new webview.WebviewController());
  // 编辑器配置选项
  @State editorOptions: WebCodeEditorOptions = {
    // 初始内容
    content: this.configStr,
    // 编辑器配置
    theme: 'light', // 主题：'dark' | 'light'
    language: 'javascript',  // 语言：'javascript' | 'typescript' | 'css' | 'html' | 'json' | 'python' | 'java'
    fontSize: '14px',
    showMinimap: true,

    // 回调函数
    onContentChange: (content: string) => {
      this.configStr = content;
      console.info('WebCodeEditor 内容已更新');
    },
    onEditingChange: (isEditing: boolean) => {
      console.info(`WebCodeEditor 编辑状态: ${isEditing}`);
    },
    onSelectionChange: (selection) => {
      console.info(`WebCodeEditor 选中文本: ${selection.text}`);
    },
    onSave: () => {
      console.info('WebCodeEditor 保存操作触发');
      this.saveConfigContent();
    },
    // 就绪回调
    onReady: () => {
      console.info('WebCodeEditor 就绪');
    },
    // 错误回调
    onError: (error: string) => {
      console.error(`WebCodeEditor 错误: ${error}`);
    }
  };

  aboutToAppear(): void {
    this.editorOptions.theme = this.currentColorMode ? 'dark' : 'light'
    hilog.info(0x0000, 'WebCodeEditor', `初始要传递的 theme: ${this.editorOptions.theme}`);
  }

  aboutToDisappear(): void {
    // 清理通信管理器
    if (this.commManager) {
      this.commManager.destroy();
    }
  }

  build() {
    NavDestination() {
      Column() {
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
            top: this.topRectHeight,
            bottom: 5
          },
          back: () => {
            this.isShowConfigAddBindSheet = true
          },
          needSetHeight: false,
          menus: this.fileMenus
        })
        // 编辑器
        WebCodeEditor({
          options: this.editorOptions,
          webController: this.webController,
          commManager: this.commManager // 传入通信管理器
        })
          .layoutWeight(1)
          .width('100%')
          .margin(8)
      }
      .clip(true)
      .width('100%')
      .height('100%')
      .padding({ bottom: this.bottomRectHeight })
    }
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.configContentChange) {
        // 弹框是否保存已经编辑好的配置
        this.configCustomConfirmDialogController?.open()
        // 更改bindSheet的前景模糊
        this.isEnableConfigPageBindSheetForegroundBlur = true
        return true
      } else {
        this.isShowConfigAddBindSheet = true
        return false
      }
    })
    .onReady( (ctx: NavDestinationContext) => {
      // 接收信息
      try {
        const params: string = ctx?.pathInfo?.param as string
        console.log('ClashBox #EditConfigContent #onReady 编辑配置页接收的params：', params)
      } catch (e) {
        console.log(`ClashBox#ImportConfigFromFile#onReady Navigate onReady catch exception: ${JSON.stringify(e)}`)
      }
    })
    .animation({ duration:  this.uiConfig.animationSpeed , curve: Curve.Ease })
  }

  /** 保存配置 */
  saveConfigContent() {

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
        this.isShowConfigAddBindSheet = true
      },
      confirm: ()=> {
        // 保存配置
        this.saveConfigContent()
        this.pageInfos.pop(true)
        this.isShowConfigAddBindSheet = true
      }
    }),
    cancel: () => {
      this.pageInfos.pop(true)
      this.isShowConfigAddBindSheet = true
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
