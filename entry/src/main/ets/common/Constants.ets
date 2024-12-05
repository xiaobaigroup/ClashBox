/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { ListItemProp } from './ListItemProp';

export default class Constants {
  /**
   * MoreListItem
   */
  static readonly MoreList: ListItemProp[] = [
    {
      title: $r('app.string.More'),
      icons: $r('sys.symbol.square_fill_grid_2x2'),
      children: [
        {
          icons: $r('sys.symbol.doc_text_fill'), title: $r('app.string.Log'), name: 'Log'
        },
        {
          icons: $r('sys.symbol.externaldrive_fill_3'), title: $r('app.string.Resources'), name: 'Resources'
        },
        {
          icons: $r('sys.symbol.list_bullet'), title: $r('app.string.Request'), name: 'Request'
        },
        {
          icons: $r('sys.symbol.swap'), title: $r('app.string.Connect'), name: 'Connect'
        },
        {
          icons: $r('sys.symbol.pencil_line'), title: $r('app.string.Overwrite'), name: 'Overwrite'
        },
        /*{
          icons: $r('sys.symbol.doc_text_fill'), title: $r('app.string.AccessControl'), name: 'AccessControl'
        },*/
        {
          icons: $r('sys.symbol.gearshape'), title: $r('app.string.Settings'), name: 'Settings'
        }
      ]
    },
  ]
}

// 主页 -> 代理启动按钮内计时器的初始值
export const PROXY_STARTED_DURATION_INIT_VALUE: string = '00:00:00'

// 组件animation duration值: 300
export const ANIMATION_DURATION_300: number = 300