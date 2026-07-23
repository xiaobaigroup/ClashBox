import { AppStorageV2, PersistenceV2 } from "@kit.ArkUI"
import { TypeConstructorWithArgs } from "@ohos.arkui.StateManagement"
import { Xb_SettingsItemData } from "../../../../Index"

export function makePersistenceSettings<T extends object>(type: TypeConstructorWithArgs<T>, defaultFactory:() =>T, onSettings: (t: T)=> Xb_SettingsItemData[]): Xb_SettingsItemData[] {
  const state = PersistenceV2.connect(type, type.name, defaultFactory)
  if(state){
    return onSettings(state)
  }
  return []
}

// 获取持久化的状态
export function getPersistence<T extends object>(type: TypeConstructorWithArgs<T>,  defaultFactory:(() =>T) | undefined = undefined): T | undefined {
  try {
    return PersistenceV2.connect(type, type.name, defaultFactory)
  }catch (e) {
    return undefined
  }
}

export function getPersistenceByName<T extends object>(type: TypeConstructorWithArgs<T>, name: string,  defaultFactory:(() =>T) | undefined = undefined): T | undefined {
  try {
    return PersistenceV2.connect(type,  type.name + "_" + name, defaultFactory)
  }catch (e) {
    return undefined
  }
}

export function getAppStore<T extends object>(type: TypeConstructorWithArgs<T>,  defaultFactory:(() =>T) | undefined = undefined): T | undefined {
  try {
    return AppStorageV2.connect(type, type.name, defaultFactory)
  }catch (e) {
    return undefined
  }
}

// 手动持久化
export function savePersistence<T extends object>(keyOrType: string | TypeConstructorWithArgs<T>) {
  PersistenceV2.save(keyOrType)
}
