/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export const ENTRY_ABILITY = 'EntryAbility';

export const BUNDLE_NAME = 'org.xbgroup.clashbox'

/** @description 卡片拉起方式 */
export enum FormCarAction {
  CALL = 'call',
  ROUTER = 'router',
}

/** @description 卡片名 */
export enum FormCardName {
  SwitchProxyCard_1X2 = 'SwitchProxyCard1x2',
}

/** @description 卡片代理状态枚举 */
export enum ProxyActionType {
  STOP = '0',
  START = '1',
}

/** @description  */
export enum RouterType {
  HOME = '1',
  PROXY = '2',
  CONFIG = '3',
  SETTING = '4',
}

export enum CallMethod {
  UPDATE_CARD_ID = 'updateFormId',
  CHANGE_PROXY = 'cardChangeProxy',
  REFRESH_STATE = 'refreshState',
}
