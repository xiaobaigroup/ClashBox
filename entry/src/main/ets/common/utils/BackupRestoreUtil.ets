import { ClashConfig, Profile } from "proxy_core";
import { Xb_FileUtils, Xb_GetResourceString, Xb_PreferenceUtil, Xb_ToastUtil } from "xb_components";
import { AppConfig, UIConfig } from "../../entryability/AppState";
import ClashViewModel from "../../entryability/ClashViewModel";
import { filterStringsByBooleans } from "../entity/Constants";
import { getJsonArrayType } from "../entity/utils";


export interface BackupConfig {
  appConfig: AppConfig
  uiConfig: UIConfig
  configSort: string
  clashConfig: ClashConfig
  configList: Profile[]
}

class BackupRestoreUtil {

  private static context: Context

  public init(context: Context) {
    BackupRestoreUtil.context = context
  }

  public async backup(): Promise<string> {
    try {
      const appConfig: AppConfig = AppStorage.get<AppConfig>("appConfig") ?? new AppConfig()
      const uiConfig: UIConfig = AppStorage.get<UIConfig>("uiConfig") ?? new UIConfig()
      const configSort: string = await Xb_PreferenceUtil.get('config_sort', '')
      const clashConfig: ClashConfig = AppStorage.get<ClashConfig>("clashConfig") ?? new ClashConfig()
      const configList = await ClashViewModel.getProfiles()
      const backupConfig: BackupConfig = {
        appConfig: appConfig,
        uiConfig: uiConfig,
        configSort: configSort,
        clashConfig: clashConfig,
        configList: configList
      }
      const file_path = await Xb_FileUtils.exportDataByFile<BackupConfig>('ClashBoxConfig', backupConfig, BackupRestoreUtil.context, false)
      console.log(`ClashBoxConfig.backup 配置文件导出成功 备份文件的缓存路径为：${file_path}`)
      return file_path
    } catch (err) {
      Xb_ToastUtil.showToast({ message: $r('app.string.export_failed') })
      console.error(`ClashBoxConfig.backup 配置文件导出失败 code: ${err.code} message: ${err.message}`)
      return ''
    }
  }

  public async restore(config: BackupConfig | null = null) {
    if (config === null) {
      Xb_FileUtils.openFile(BackupRestoreUtil.context).then(async (uri) => {
        if (uri) {
          config = await Xb_FileUtils.importDataByFile<BackupConfig>(uri)
          if (config) {
            AppStorage.set("appConfig", config.appConfig)
            const type = getJsonArrayType(config.uiConfig.isShowHomeCard)
            if (type === 'boolean') {
              console.log(`检查到旧版本数据，开始兼容`)
              const str = config.uiConfig.isShowHomeCard
              // 转化字符串
              config.uiConfig.isShowHomeCard = filterStringsByBooleans(str, 'string') as string
              console.log(`旧版本数据转化为：${config.uiConfig.isShowHomeCard}`)
            }
            AppStorage.set("uiConfig",  config.uiConfig)
            AppStorage.set("clashConfig", config.clashConfig)
            console.info(`ClashBoxConfig.restore 配置列表：${JSON.stringify(config.configList)}`)
            try {
              await ClashViewModel.addOrUpdateProfiles(config.configList)
            } catch (err) {
              console.error(`ClashBox Restore ClashViewModel 配置恢复失败, name: ${err.name}, message: ${err.message}`)
            }
            Xb_PreferenceUtil.put('config_sort', config.configSort).then(() => {
              Xb_ToastUtil.showToast({ message: $r('app.string.import_success') })
              // 重启应用
              setTimeout(() => {
                Xb_ToastUtil.restartApp()
              }, 2000)
            }).catch((err: Error) => {
              console.error(`ClashBox Restore Xb_PreferenceUtil.put 配置列表排序恢复失败, name: ${err.name}, message: ${err.message}`)
            })
          } else {
            console.error(`ClashBoxConfig.restore 配置解析失败`)
            Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.import_failed'), this) + '配置解析失败' })
          }
        } else {
          Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.import_failed'), BackupRestoreUtil.context) + '文件uri不存在' })
          console.error(`ClashBoxConfig.restore 文件uri不存在`)
        }
      })
    } else {
      // 外部提供config
      AppStorage.set("appConfig", config.appConfig)
      const type = getJsonArrayType(config.uiConfig.isShowHomeCard)
      if (type === 'boolean') {
        console.log(`检查到旧版本数据，开始兼容`)
        const str = config.uiConfig.isShowHomeCard
        // 转化字符串
        config.uiConfig.isShowHomeCard = filterStringsByBooleans(str, 'string') as string
        console.log(`旧版本数据转化为：${config.uiConfig.isShowHomeCard}`)
      }
      AppStorage.set("uiConfig",  config.uiConfig)
      AppStorage.set("clashConfig", config.clashConfig)
      console.info(`ClashBoxConfig.restore 配置列表：${JSON.stringify(config.configList)}`)
      ClashViewModel.addOrUpdateProfiles(config.configList).then(() => {
        Xb_ToastUtil.showToast({ message: $r('app.string.import_success') })
        // 重启应用
        setTimeout(() => {
          Xb_ToastUtil.restartApp()
        }, 2000)
      })
        .catch((err: Error) => {
          console.error(`ClashBox Restore 配置恢复失败 ${err.name} ${err.message}`)
        })
    }
  }

}

export default new BackupRestoreUtil()