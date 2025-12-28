
export interface PCTabInfo {
  group: string
  groupName: ResourceStr
  items: PCTabItem[]
}

export interface PCTabItem {
  name: string
  title: ResourceStr
  icon: Resource
}