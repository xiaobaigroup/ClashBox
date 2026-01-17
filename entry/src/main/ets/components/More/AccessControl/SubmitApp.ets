import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Xb_ToastUtil } from 'xb_components'
import { UIConfig } from '../../../entryability/AppState'
import { customAnimationUtil } from '../../../common/utils/Animation'
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI'
import { ANIMATION_DURATION_300 } from '../../../common/entity/Constants'

const TAG = "SubmitAppDialog"

/**
 * @projectName:    clashnext
 * @fileName:      SubmitApp
 * @author:     SummerKaze
 * @description:  提交未找到的应用信息
 * @date:    2026/1/16 15:00
 * @version:    1.0
 */

@Component
export struct EmptySearchResult {
  /** 搜索文本（用于预填充） */
  @Prop searchText: string = ''
  /** 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /** 是否开启背景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  /** 提交成功回调 */
  onSubmitSuccess?: () => void
  /** UI配置 */
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /** 提交应用弹窗控制器 */
  submitDialogController: CustomDialogController = new CustomDialogController({
    builder: SubmitAppDialog({
      searchText: this.searchText,
      onSubmit: async (data: SubmitAppRequest) => {
        await this.submitApp(data)
      }
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        dismissDialogAction.dismiss()
        // this.isEnableIndexForegroundBlur = false
      }
    }
  })

  build() {
    Column() {
      // 空状态图标
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(48)
        .fontColor([this.icon_emphasize])
        .margin({ bottom: 16 })

      // 提示文本
      Text($r('app.string.no_apps_found'))
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      Text($r('app.string.submit_app_help_text'))
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })

      // 提交按钮
      Button($r('app.string.submit_app'))
        .width(160)
        .height(40)
        .backgroundColor(this.icon_emphasize)
        .fontColor(Color.White)
        .fontSize(16)
        .onClick(() => {
          this.submitDialogController.open()
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .transition(customAnimationUtil.isOpacity(this.uiConfig))
  }

  /**
   * 提交应用信息到服务器
   * @param data 提交的应用数据
   */
  private async submitApp(data: SubmitAppRequest): Promise<void> {
    try {
      const response = await this.postSubmitApp(data)
      if (response.success && response.data) {
        // 使用接口返回的 message 提示用户
        const message = response.data.message ?? $r('app.string.submit_success_thanks')
        Xb_ToastUtil.showToast({ message, duration: 2000 })
        this.onSubmitSuccess?.()
      } else {
        Xb_ToastUtil.showToast({ message: response.message ?? $r('app.string.submit_failed_retry'), duration: 1000 })
      }
    } catch (error) {
      hilog.error(0xFF00, TAG, "提交应用失败: %{public}s", error.message)
      Xb_ToastUtil.showToast({ message: $r('app.string.submit_failed_network'), duration: 1000 })
    }
  }

  /**
   * 发送 POST 请求提交应用信息
   * @param data 请求体数据
   * @returns Promise<SubmitAppResponse> 提交响应
   */
  private postSubmitApp(data: SubmitAppRequest): Promise<SubmitAppResponse> {
    return new Promise<SubmitAppResponse>((resolve, reject) => {
      let httpRequest = http.createHttp()
      const url = 'https://next.vcck.cn/api/apps/submit'

      httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(data)
        },
        (err: Error, response: http.HttpResponse) => {
          if (!err) {
            hilog.info(0xFF00, TAG, "提交应用返回值: %{public}s", JSON.stringify(response))
            if (typeof response.result === 'string') {
              try {
                const result = JSON.parse(response.result) as SubmitAppResponse
                resolve(result)
              } catch (parseErr) {
                reject(new Error('无法解析响应: ' + parseErr.message))
              }
            } else {
              // 如果返回的不是字符串，尝试直接判断状态码
              if (response.responseCode === 200 || response.responseCode === 201) {
                resolve({ success: true })
              } else {
                reject(new Error('请求失败，状态码: ' + response.responseCode))
              }
            }
          } else {
            reject(new Error(JSON.stringify(err)))
          }
          httpRequest.destroy()
        }
      )
    })
  }
}

/** 提交应用信息弹窗组件 */
@CustomDialog
struct SubmitAppDialog {
  /** 搜索文本（用于预填充） */
  @Prop searchText: string = ''
  /** 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /** 是否开启背景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  /** 弹窗控制器 */
  controller: CustomDialogController
  /** Tab 选项配置 */
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.app_id_tab') },
      { text: $r('app.string.package_name') },
      { text: $r('app.string.link_tab') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    selectedFontColor: Color.White,
    backgroundColor: $r('app.color.FavoriteProxyDivider')
  })
  /** 当前选中的 Tab 索引 */
  @State tabSelectedIndexes: number[] = [0]
  /** 输入内容 */
  @State inputValue: string = ''
  /** 是否正在提交 */
  @State isSubmitting: boolean = false
  /** 提交回调 */
  onSubmit?: (data: SubmitAppRequest) => Promise<void>

  aboutToAppear(): void {
    // 开启背景模糊
    this.isEnableIndexForegroundBlur = true
    // 设置 Tab 选中背景色和字体颜色
    this.tabOptions.selectedBackgroundColor = this.icon_emphasize
    this.tabOptions.fontColor = this.icon_emphasize
    // TODO 预填充输入内容 先测试使用 如果体验不太好就注释掉
    if (this.searchText.trim()) {
      this.inputValue = this.searchText
      // 自动判断输入类型并切换 Tab
      if (this.searchText.startsWith('C') && /^C\d+$/.test(this.searchText)) {
        // 看起来像 AppID
        this.tabSelectedIndexes = [0]
      } else if (this.searchText.includes('.') && !this.searchText.startsWith('http')) {
        // 看起来像包名
        this.tabSelectedIndexes = [1]
      } else if (this.searchText.startsWith('http')) {
        // 看起来像链接
        this.tabSelectedIndexes = [2]
      }
    }
    // TODO End
  }

  aboutToDisappear(): void {
    // this.isEnableIndexForegroundBlur = false
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Text($r('app.string.submit_app_info'))
        .fontWeight(FontWeight.Medium)
        .fontSize(20)

      // 提示文本（根据选中的 Tab 显示不同提示）
      Text(this.getHintText())
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .transition(TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300 }))

      // Tab 切换按钮
      SegmentButton({
        options: this.tabOptions,
        selectedIndexes: $tabSelectedIndexes
      })

      // 输入框区域
      Column() {
        TextInput({
          placeholder: this.getPlaceholder(),
          text: this.inputValue
        })
          .onChange((value: string) => {
            this.inputValue = value
          })
      }
      .width('100%')

      // 按钮组
      Row() {
        Button($r('app.string.Cancel'))
          .height(39)
          .width('50%')
          .fontColor(this.icon_emphasize)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.controller.close()
          })

        Button(this.isSubmitting ? $r('app.string.submitting') : $r('app.string.submit'))
          .width('50%')
          .height(39)
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .enabled(!this.isSubmitting && this.isFormValid())
          .onClick(async () => {
            if (this.onSubmit) {
              this.isSubmitting = true
              try {
                await this.onSubmit({ input: this.inputValue.trim() })
                this.controller.close()
              } finally {
                this.isSubmitting = false
              }
            }
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .padding({
      left: 16,
      right: 16,
      top: 15,
      bottom: 15
    })
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
  }

  /**
   * 获取当前 Tab 对应的提示文本资源
   * @returns 提示文本资源
   */
  private getHintText(): Resource {
    switch (this.tabSelectedIndexes[0]) {
      case 0:
        return $r('app.string.hint_input_app_id')
      case 1:
        return $r('app.string.hint_input_package_name')
      case 2:
        return $r('app.string.hint_input_app_link')
      default:
        return $r('app.string.hint_fill_app_info')
    }
  }

  /**
   * 获取当前 Tab 对应的占位符资源
   * @returns 占位符资源
   */
  private getPlaceholder(): Resource {
    switch (this.tabSelectedIndexes[0]) {
      case 0:
        return $r('app.string.placeholder_app_id')
      case 1:
        return $r('app.string.placeholder_package_name')
      case 2:
        return $r('app.string.placeholder_app_link')
      default:
        return $r('app.string.text_input_placeholder')
    }
  }

  /**
   * 验证表单是否有效
   * @returns boolean 表单是否有效
   */
  private isFormValid(): boolean {
    return this.inputValue.trim().length > 0
  }
}


/** 提交应用请求体结构 */
interface SubmitAppRequest {
  input: string
}

/** 提交应用响应数据结构 */
interface SubmitAppData {
  /** 应用ID */
  app_id: string
  /** 应用名称 */
  name: string
  /** 图标URL */
  icon_url: string
  /** 包名 */
  pkg_name: string
  /** 是否为新增应用 */
  is_new: boolean
  /** 提示消息 */
  message: string
}

/** 提交应用响应结构 */
interface SubmitAppResponse {
  success: boolean
  data?: SubmitAppData
  message?: string | null
}