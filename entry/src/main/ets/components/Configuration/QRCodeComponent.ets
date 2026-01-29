/**
 * @projectName:    clashnext 
 * @fileName:      QRCodeComponent
 * @author:     SummerKaze
 * @description:  二维码组件
 * @date:    2025/11/23 17:17
 * @version:    1.0
 */

import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { Xb_ToastUtil } from "xb_components"
import { image } from "@kit.ImageKit"
import { fileIo as fs } from "@kit.CoreFileKit"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ANIMATION_DURATION_300, APP_LINKING } from "../../common/entity/Constants"
import { BusinessError } from '@kit.BasicServicesKit';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from "@kit.ArkUI"


export interface IQRCodeParam {
  url: string
  name: string
}

const TAG = "QRCodeDialog"

@Component
export struct QRCodeDialog {
  @Prop theDialogTitle: ResourceStr
  @Prop QRCodeParam: IQRCodeParam
  @State QRCodeUrl: string = ''
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: 'App Linking' }, { text: '通用链接' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedFontColor: Color.White,
    backgroundColor: $r("app.color.FavoriteProxyDivider")
  });
  @State tabSelectedIndexes: number[] = [0];
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  cancel?: () => void
  confirm?: (result: SaveButtonOnClickResult) => void

  aboutToAppear(): void {
    // 开启背景模糊
    this.isEnableIndexForegroundBlur = true
    // 拼接 App Linking
    this.QRCodeUrl = `${APP_LINKING}?configUrl=${this.QRCodeParam.url}&configName=${this.QRCodeParam.name}`
    // 设置 tabs 选择的背景色
    this.tabOptions.selectedBackgroundColor = this.icon_emphasize
    this.tabOptions.fontColor = this.icon_emphasize
  }

  aboutToDisappear(): void {
    setTimeout(() => {
      // 关闭背景模糊
      this.isEnableIndexForegroundBlur = false
    })
  }

  build() {
    Column() {
      // 标题、副标题
      Column({ space: 8 }) {
        Text(this.theDialogTitle)
          .fontWeight(FontWeight.Medium)
          .fontSize(20)

        Text(this.tabSelectedIndexes[0] === 0 ? $r('app.string.qrcode_share_subtitle') : $r('app.string.qrcode_universal_link_subtitle'))
          .fontSize(14)
          .fontColor(Color.Gray)
          .transition(TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300 }))
      }

      SegmentButton({
        options: this.tabOptions,
        selectedIndexes: $tabSelectedIndexes
      })

      // 二维码
      Stack({ alignContent: Alignment.Center }) {
        // App Linking
        if (this.tabSelectedIndexes[0] === 0) {
          // 二维码内容
          this.QRCodeBuilder(this.QRCodeUrl)
        } else if (this.tabSelectedIndexes[0] === 1) {
          // 二维码内容
          this.QRCodeBuilder(this.QRCodeParam.url)
        }

        // 应用图标
        Image($r("app.media.box_cat_round"))
          .width(50)
          .aspectRatio(1)
      }
      .id("Configuration_QRCode")
      .width(282)
      .padding(16)
      .borderRadius(8)
      .backgroundColor($r("app.color.FavoriteProxyDivider"))

      // 按钮
      Column({ space: 16 }) {
        SaveButton({ text: SaveDescription.SAVE_TO_GALLERY })
          .width('100%')
          .height(39)
          .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
            try { // 保存二维码到图库
              const pixelMap = await this.getUIContext().getComponentSnapshot().get("Configuration_QRCode")
              if (result === SaveButtonOnClickResult.SUCCESS && pixelMap !== undefined) {
                this.savePixelMapToAlbum(pixelMap)
              }
            } catch (e) {
              Xb_ToastUtil.showToast({
                message: $r('app.string.qrcode_save_failed')
              })
            }

            this.confirm && this.confirm(result)
          })
          .backgroundColor(this.icon_emphasize)
          .fontColor(Color.White)

        Button($r('app.string.close'))
          .type(ButtonType.Capsule)
          .height(39)
          .width('100%')
          .fontColor(this.icon_emphasize)
          .backgroundColor($r("app.color.FavoriteProxyDivider"))
          .onClick(() => {
            this.cancel && this.cancel()
          })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
    .height("100%")
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  QRCodeBuilder(url: string) {
    // 二维码
    QRCode(url)
      .width(250)
      .aspectRatio(1)
      .backgroundColor($r("app.color.container_background"))
      .transition(TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300 }))
  }

  private async savePixelMapToAlbum(pixelMap: image.PixelMap) {
    const context = this.getUIContext().getHostContext()
    let file: fs.File | null = null;
    // 获取相册路径
    const helper = photoAccessHelper.getPhotoAccessHelper(context);
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
    try {
      // 创建图片文件
      file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const imagePackerApi = image.createImagePacker();
      // 压缩图标
      let packOpts: image.PackingOption = { format: 'image/png', quality: 98 };
      imagePackerApi.packToFile(pixelMap, file.fd, packOpts, (err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, TAG, `Failed to pack the image to file.code ${err.code},message is ${err.message}`);
        } else {
          hilog.info(0x0000, TAG, 'Succeeded in packing the image to file.');
          imagePackerApi.release((err: BusinessError) => {
            if (err) {
              hilog.error(0x0000, TAG,
                `Failed to release the image source instance.code ${err.code},message is ${err.message}`);
            } else {
              hilog.info(0x0000, TAG, 'Succeeded in releasing the image source instance.');
            }
          });
          Xb_ToastUtil.showToast({
            message: $r('app.string.qrcode_saved_to_gallery')
          });
        }
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `An error occurred error.code ${err.code},message is ${err.message}`);
    } finally {
      if (file !== null) {
        fs.close(file.fd);
      }
    }
  }
}