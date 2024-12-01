// 输出问候语
interface Holiday {
  month: number;
  day: number;
  message: string;
}

export function getGreeting(): string {
  const currentDate = new Date();
  const currentHour = currentDate.getHours();
  const currentDay = currentDate.getDate();
  const currentMonth = currentDate.getMonth() + 1; // getMonth() 返回的月份是从0开始的

  // 定义节假日祝福语列表
  const holidays: Holiday[] = [
    { month: 2, day: 14, message: "巧克力真甜！" },
    { month: 3, day: 8, message: "妇女节快乐！" },
    { month: 3, day: 12, message: "植树节快乐！" },
    { month: 5, day: 1, message: "劳动节快乐！" },
    { month: 5, day: 4, message: "新青年！" },
    { month: 6, day: 1, message: "儿童节快乐！" },
    { month: 9, day: 10, message: "教师节快乐！" },
    { month: 10, day: 1, message: "国庆节快乐！" },
    //
  ];

  // 检查当前日期是否是节假日
  const holiday = holidays.find(holiday =>
  holiday.month === currentMonth && holiday.day === currentDay
  );

  if (holiday) {
    return holiday.message;
  }

  // 根据时间返回问候语
  if (currentHour >= 5 && currentHour < 8) {
    return "早上好！";
  } else if (currentHour >= 8 && currentHour < 11) {
    return "上午好！";
  } else if (currentHour >= 11 && currentHour < 13) {
    return "中午好！";
  } else if (currentHour >= 13 && currentHour < 18) {
    return "下午好！";
  } else if (currentHour >= 18 && currentHour < 22) {
    return "晚上好！";
  } else {
    return "夜已深, 请注意休息";
  }
}


