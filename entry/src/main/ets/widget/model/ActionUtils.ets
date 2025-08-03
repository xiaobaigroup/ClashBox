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

import { BUNDLE_NAME, CallMethod, ENTRY_ABILITY, FormCarAction, ProxyActionType, RouterType } from './FormCardConstant';

class ActionUtils {
  /** @description 卡片切换代理 */
  public SwitchProxyAction(component: Object, type: ProxyActionType, formId: string) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.CHANGE_PROXY,
        formId: formId,
        proxyActionType: type,
      },
    });
  }

  /** @description 更新卡片ID */
  public updateCardIdAction(component: Object, formId: string) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.UPDATE_CARD_ID,
        formId: formId,
      },
    });
  }
  
  /** @description 刷新IP地址 */
  public refreshIPAddress(component: Object) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.REFRESH_IPADDRESS,
      },
    });
  }

  /** @description 卡片跳转页面 */
  jumpPage(component: Object) {
    postCardAction(component, {
      action: FormCarAction.ROUTER,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
      params: {
        type: RouterType.PROXY,
      },
    });
  }
  
  /** @description 卡片跳转APP */
  jumpApp(component: Object) {
    postCardAction(component, {
      action: FormCarAction.ROUTER,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
    });
  }
}

export default new ActionUtils();
