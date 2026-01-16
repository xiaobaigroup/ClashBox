import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Xb_ToastUtil } from 'xb_components'
import { UIConfig } from '../../../entryability/AppState'
import { customAnimationUtil } from '../../../common/utils/Animation'

const TAG = "SubmitAppDialog"

/**
 * @projectName:    clashnext
 * @fileName:      SubmitApp
 * @author:     SummerKaze
 * @description:  提交未找到的应用信息
 * @date:    2026/1/16 15:00
 * @version:    1.0
 */

/**
 * 搜索结果为空时的提示组件
 * 允许用户提交未找到的应用信息
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
        this.isEnableIndexForegroundBlur = false
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
      Text('未找到相关应用')
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      Text('您可以提交应用信息，帮助我们完善数据')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })

      // 提交按钮
      Button('提交应用')
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
      if (response.success) {
        Xb_ToastUtil.showToast({ message: '提交成功，感谢您的贡献！', duration: 2000 })
        this.onSubmitSuccess?.()
      } else {
        Xb_ToastUtil.showToast({ message: response.message ?? '提交失败，请稍后重试', duration: 2000 })
      }
    } catch (error) {
      hilog.error(0xFF00, TAG, "提交应用失败: %{public}s", error.message)
      Xb_ToastUtil.showToast({ message: '提交失败，请检查网络连接', duration: 2000 })
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
                resolve({ success: true, message: null })
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

/**
 * 提交应用信息弹窗组件
 * 收集 appid、包名、链接 三个字段
 */
@CustomDialog
struct SubmitAppDialog {
  /** 搜索文本（用于预填充包名） */
  @Prop searchText: string = ''
  /** 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /** 是否开启背景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  /** 弹窗控制器 */
  controller: CustomDialogController
  /** 表单字段 - AppID */
  @State appId: string = ''
  /** 表单字段 - 包名 */
  @State packageName: string = ''
  /** 表单字段 - 链接 */
  @State appLink: string = ''
  /** 是否正在提交 */
  @State isSubmitting: boolean = false
  /** 提交回调 */
  onSubmit?: (data: SubmitAppRequest) => Promise<void>

  aboutToAppear(): void {
    // 开启背景模糊
    this.isEnableIndexForegroundBlur = true
    // 预填充包名（如果搜索文本像包名格式）
    if (this.searchText.includes('.')) {
      this.packageName = this.searchText
    }
  }

  aboutToDisappear(): void {
    this.isEnableIndexForegroundBlur = false
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Text('提交应用信息')
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ bottom: 8 })

      // 提示文本
      Text('请至少填写以下任意一项信息')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 8 })

      // AppID 输入框
      Column({ space: 4 }) {
        Text('AppID')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .alignSelf(ItemAlign.Start)
        TextInput({ placeholder: '例如: C123456789', text: this.appId })
          .onChange((value: string) => {
            this.appId = value
          })
      }
      .width('100%')

      // 包名输入框
      Column({ space: 4 }) {
        Text('包名')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .alignSelf(ItemAlign.Start)
        TextInput({ placeholder: '例如: com.example.app', text: this.packageName })
          .onChange((value: string) => {
            this.packageName = value
          })
      }
      .width('100%')

      // 链接输入框
      Column({ space: 4 }) {
        Text('应用商店链接')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .alignSelf(ItemAlign.Start)
        TextInput({ placeholder: '例如: https://appgallery.huawei.com/app/C123456789', text: this.appLink })
          .onChange((value: string) => {
            this.appLink = value
          })
      }
      .width('100%')

      // 按钮组
      Row() {
        Button('取消')
          .height(39)
          .width('50%')
          .fontColor(this.icon_emphasize)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.controller.close()
          })

        Button(this.isSubmitting ? '提交中...' : '提交')
          .width('50%')
          .height(39)
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .enabled(!this.isSubmitting && this.isFormValid())
          .onClick(async () => {
            if (this.onSubmit) {
              this.isSubmitting = true
              try {
                // 构建请求体，只包含非空字段
                const requestData: SubmitAppRequest = {}
                if (this.appId.trim()) {
                  requestData.appid = this.appId.trim()
                }
                if (this.packageName.trim()) {
                  requestData.pkg_name = this.packageName.trim()
                }
                if (this.appLink.trim()) {
                  requestData.input = this.appLink.trim()
                }
                await this.onSubmit(requestData)
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
   * 验证表单是否有效
   * @returns boolean 表单是否有效（至少填写一个字段）
   */
  private isFormValid(): boolean {
    // 至少需要填写一个字段
    return this.appId.trim().length > 0 ||
      this.packageName.trim().length > 0 ||
      this.appLink.trim().length > 0
  }
}


/**
 * 提交应用请求体结构
 * 字段均为可选，但至少需要填写其中一个
 */
export interface SubmitAppRequest {
  /** AppID */
  appid?: string
  /** 包名 */
  pkg_name?: string
  /** 链接 */
  input?: string
}

/** 提交应用响应结构 */
interface SubmitAppResponse {
  success: boolean
  message: string | null
}