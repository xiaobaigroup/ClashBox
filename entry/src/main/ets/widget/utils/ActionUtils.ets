import { BUNDLE_NAME, CallMethod, ENTRY_ABILITY, FormCarAction, ProxyActionType, RouterType } from '../model/FormCardConstant';

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
  public refreshState(component: Object) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      bundleName: BUNDLE_NAME,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.REFRESH_STATE,
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
