import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export default class EntryFormAbility extends FormExtensionAbility {
  /** @description 卡片添加生命周期 */
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    const formId = want.parameters![formInfo.FormParam.IDENTITY_KEY] as string;
    return formBindingData.createFormBindingData({
      formId
    });
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  /** @description 卡片删除生命周期 */
  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    const store = preferences.getPreferencesSync(this.context, { name: 'cardPreference' })
    let list = store.getSync('formId', []) as string[]
    // 移除卡片ID
    list = list.filter(id => id !== formId)
    // 持久化存储
    store.putSync('formId', list)
    store.flushSync()
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}