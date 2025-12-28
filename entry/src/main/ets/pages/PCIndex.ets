import { ListItemMarginValue } from "../common/breakpoint/BreakPoint";
import { LIST_ITEM_HEIGHT, LIST_SPACE, PCTabList } from "../common/entity/Constants";
import { PCTabInfo, PCTabItem } from "../common/entity/PCTabInfo";
import { skipRowList } from "../components/Common/Common";


@Component
export struct PCIndex {

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  private tabList: Array<PCTabInfo> = PCTabList;

  build() {
    Navigation(this.pageInfos) {
      // 导航的一级界面
      List({ space: LIST_SPACE, initialIndex: 0 }) {
        ForEach(this.tabList, (group: PCTabInfo) => {
          ListItemGroup({ header: this.itemHead(group.groupName)}) {
            ForEach(group.items, (item: PCTabItem) => {
              ListItem() {
                skipRowList({
                  icons: item.icon,
                  name: item.name,
                  title: item.title,
                  isPrimaryIcons: true,
                  needBackgroundColor: false
                })
              }
              .width('100%')
              .height(LIST_ITEM_HEIGHT)
              .onClick(() => {
                this.pageInfos.pushPathByName(`${item.name}`, '详情页面参数'); // 将name指定的NaviDestination页面信息入栈,传递的参数为param
              })
            }, (item: PCTabItem) => item.name)
          }
        })
      }
      .padding({ left: 12, right: 12})
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
      .chainAnimation(false)
      .width('100%')
    }
    .width('100%')
    .hideToolBar(true)
    .mode(NavigationMode.Auto)
  }

  @Builder
  itemHead(text: ResourceStr) {
    Row() {
      Text(text)
        .fontSize(16)
    }
    .width("100%")
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.Transparent)
  }

}