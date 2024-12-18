
@Component
struct MoreMenu {
  @Link isShowMenu: boolean
  @Link EnableLogger: boolean
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  build() {
    Column() {
      Row() {
        Column() {

        }
        .onClick(() => {
          this.isShowMenu = false
        })
        .height(220)
        .flexGrow(1) // 设置 flexGrow 为 1 让这个列占据所有剩余空间
        //.backgroundColor('red')
        Column() {
          Column() {}
          .height(56)
          .width(177)
          .onClick(() => {
            this.isShowMenu = false
          })

          Column() {
            Column() {
              Row() {
                Text($r('app.string.EnableLogger'))
                  .fontSize(16)
                  .margin({left: 12, right: 8 })
                if (this.EnableLogger) {
                  Image($r('app.media.ok'))
                    .width(24)
                    .margin({right: 11 })
                }
              }
              .shadow(this.EnableLogger ? {radius: 0 } : {radius: 20, color: 'gray'})
              .backgroundColor($r('app.color.container_background'))
              .borderRadius(19)
              .width(152)
              .height(48)
              .onClick(() => {
                this.EnableLogger = !this.EnableLogger
              })

              /*MenuItem({ content: $r('app.string.EnableLogger') })
                .selectIcon(true)
                .selected(this.EnableLogger)
                .onChange((selected) => {
                  this.EnableLogger = !this.EnableLogger
                })*/
              if (!this.EnableLogger) {
                Row() {  }
                .width(152)
                .height(96)
                .onClick(() => {
                  this.isShowMenu = false
                })
              }
              if (this.EnableLogger) {

                  Row() {
                    Text($r('app.string.ClearLogs'))
                      .fontSize(16)
                      .margin({left: 12})
                  }
                  .onClick(() => {
                    // 清除日志
                  })
                  .justifyContent(FlexAlign.Start)
                  .width(152)
                  .height(48)
                  Row() {
                    Text($r('app.string.ExportLog'))
                      .fontSize(16)
                      .margin({left: 14})
                  }
                  .onClick(() => {
                    // 导出日志
                  })
                  .width(152)
                  .height(48)

                /*MenuItem({ content: $r('app.string.ClearLogs')})
                  .selectIcon(true)
                MenuItem({ content: $r('app.string.ExportLog')})
                  .selectIcon(true)*/
              }
            }
            .shadow(this.EnableLogger?{radius: 20, color: 'gray'} : {radius: 0})
            .backgroundColor(this.EnableLogger? $r('app.color.container_background') : '')
            .borderRadius(this.EnableLogger? 18 : 0)

          }
          .height(168)

        }
        .width(177)
        .onClick(() => {
          this.isShowMenu = true
        })

      }
      .height(220)
      .width('100%')
      Row() {}
      .onClick(() => {
        this.isShowMenu = false
      })
      //.backgroundColor('green')
      .flexGrow(1) // 设置 flexGrow 为 1 让这个列占据所有剩余空间
      .width('100%')

    }
    .width('100%')
    .height('100%')
    //.menuItemDivider({color:Color.Black, strokeWidth:LengthMetrics.vp(1)})
  }
}

export default MoreMenu
