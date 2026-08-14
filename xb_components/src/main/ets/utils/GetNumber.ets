/* number处理 */
@ObservedV2
class GetNumber{

  // 小数点数值取整数
  TruncNumber(v: number){
    console.info('整数值:', Math.trunc(v))
    return Math.trunc(v)
  }

  // 取值为保留小数点后2位
  TwoDecimalPlaces(v: number){
    let arr = v.toString().split('.')

    if(arr.length > 1){
      return arr[0] + '.' + arr[1].substring(0,2);
    } else {
      return arr[0] + '.00';
    }
  }

  // 求数值数组的平均值
  AverageNumber(l: number[]): number{
    let num: number = 0
    for(let i = 0; i < l.length; i++){
      num += l[i]
    }
    console.info('平均值:', num)
		return Math.floor(num) / l.length
	}

  // 获取数值数组里最大值
  MaxNumber(l: number[]){
    console.info('最大值:', Math.max(...l))
    return Math.max(...l)
  }

  // 获取数值数组里最小值
  MinNumber(l: number[]){
    console.info('最小值:', Math.min(...l))
    return Math.min(...l)
  }

  // ......可以写别的数值处理
}

export const Xb_GetNumber: GetNumber = new GetNumber()