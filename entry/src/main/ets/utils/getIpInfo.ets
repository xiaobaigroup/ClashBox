// 使用https://ip-api.com/网站提供的API完成IP地址查询

import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit';

// 定义返回数据的类型
interface IpInfo {
  status: string;
  country: string;
  countryCode: string;
  region: string;
  regionName: string;
  city: string;
  zip: string;
  lat: number;
  lon: number;
  timezone: string;
  isp: string;
  org: string;
  as: string;
  query: string;
}

// 地址返回值接口
interface LocationInfo {
  country: string;
  province: string;
  city: string;
}

// http请求获取IP地址信息
export function getIpInfo(ip: string): Promise<IpInfo> {
  return new Promise<IpInfo>((resolve, reject) => {
    let httpRequest = http.createHttp()
    httpRequest.request(`http://ip-api.com/json/${ip}`, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        hilog.info(0xFF00, "MoreIPtestTag", "HTTP返回值: %{public}s", JSON.stringify(data))
        // 确保 data.result 是字符串类型
        if (typeof data.result === 'string') {
          try {
            // 将 data.result 字符串解析为 JSON 对象
            const ipInfo = JSON.parse(data.result) as IpInfo
            resolve(ipInfo)
          } catch (parseErr) {
            reject(new Error('无法解析响应: ' + parseErr.message))
          }
        } else {
          reject(new Error('返回值不是string'))
        }
      } else {
        reject(new Error(JSON.stringify(err)))
      }
      httpRequest.destroy()
    })
  })
}

// 提取位置信息的函数
export function extractLocationInfo(ipInfo: IpInfo): LocationInfo | null {
  hilog.info(0xFF00, "LocationMoreIPtestTag", "status字段: %{public}s", ipInfo.status)
  if (ipInfo && ipInfo.status === 'success') {
    return {
      country: ipInfo.countryCode,
      province: ipInfo.regionName,
      city: ipInfo.city
    };
  } else {
    return null;
  }
}

// 映射函数，将简写转换为完整名称
export function mapLocation(locationInfo: LocationInfo): LocationInfo {
  return {
    country: locationMappings.country[locationInfo.country] || locationInfo.country,
    province: locationMappings.province[locationInfo.province] || locationInfo.province,
    city: locationMappings.city[locationInfo.city] || locationInfo.city,
  };
}

// 映射的类型
interface LocationMapping {
  country: Record<string, string>
  province: Record<string, string>
  city: Record<string, string>
}

// 位置映射表 // TODO 地区映射表不完全且未国际化
const locationMappings: LocationMapping = {
  country: {
    'CN': '中国',
    'RU': '俄罗斯',
    'US': '美国',
    'FR': '法国',
    'GB': '英国',
    // ...其他国家的映射
  },
  province: {
    'Beijing': '北京市',
    'Shanghai': '上海市',
    'Tianjin': '天津市',
    'Chongqing': '重庆市',
    'Anhui': '安徽省',
    'Fujian': '福建省',
    'Gansu': '甘肃省',
    'Guangdong': '广东省',
    'Guangxi': '广西壮族自治区',
    'Guizhou': '贵州省',
    'Hainan': '海南省',
    'Hebei': '河北省',
    'Heilongjiang': '黑龙江省',
    'Henan': '河南省',
    'Hubei': '湖北省',
    'Hunan': '湖南省',
    'Jiangsu': '江苏省',
    'Jiangxi': '江西省',
    'Jilin': '吉林省',
    'Liaoning': '辽宁省',
    'Nei Mongol': '内蒙古自治区',
    'Ningxia': '宁夏回族自治区',
    'Qinghai': '青海省',
    'Shaanxi': '陕西省',
    'Shandong': '山东省',
    'Shanxi': '山西省',
    'Sichuan': '四川省',
    'Taiwan': '台湾省',
    'Xinjiang': '新疆维吾尔自治区',
    'Xizang': '西藏自治区',
    'Yunnan': '云南省',
    'Zhejiang': '浙江省',
    'Hong Kong': '香港特别行政区',
    'Macao': '澳门特别行政区'
    // ...其他国家省份的映射
  },
  city: {
    'Beijing': '北京市',
    'Shanghai': '上海市',
    'Guangzhou': '广州市',
    'Shenzhen': '深圳市',
    'Chongqing': '重庆市',
    'Tianjin': '天津市',
    'Wuhan': '武汉市',
    'Chengdu': '成都市',
    'Hangzhou': '杭州市',
    'Nanjing': '南京市',
    'Suzhou': '苏州市',
    'Qingdao': '青岛市',
    'Dalian': '大连市',
    'Changsha': '长沙市',
    'Nanchang': '南昌市',
    'Fuzhou': '福州市',
    'Xiamen': '厦门市',
    'Harbin': '哈尔滨市',
    'Shenyang': '沈阳市',
    'Zhengzhou': '郑州市',
    'Jinan': '济南市',
    'Kunming': '昆明市',
    'Ningbo': '宁波市',
    'Taiyuan': '太原市',
    'Urumqi': '乌鲁木齐市',
    'Hefei': '合肥市',
    'Guiyang': '贵阳市',
    'Lhasa': '拉萨市',
    'Haikou': '海口市',
    'Xian': '西安市',
    'Changchun': '长春市',
    'Taipei': '台北市',
    'Hong Kong': '香港特别行政区',
    'Macao': '澳门特别行政区',
    // ...其他城市的映射
  }
};
