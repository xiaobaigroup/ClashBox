// 问候语工具

interface Holiday {
  month: number;
  day: number;
  message: Resource;
}

export function getGreeting(): Resource {
  const currentDate = new Date();
  const currentHour = currentDate.getHours();
  const currentDay = currentDate.getDate();
  const currentMonth = currentDate.getMonth() + 1; // getMonth() 返回的月份是从0开始的

  // 定义节假日祝福语列表
  const holidays: Holiday[] = [
    { month: 2, day: 14, message: $r('app.string.Valentine') },
    { month: 3, day: 8, message: $r('app.string.Women') },
    { month: 3, day: 12, message: $r('app.string.Tree') },
    { month: 5, day: 1, message: $r('app.string.Work')},
    { month: 5, day: 4, message: $r('app.string.Youth') },
    { month: 6, day: 1, message: $r('app.string.Children') },
    { month: 9, day: 10, message: $r('app.string.Teacher') },
    { month: 10, day: 1, message: $r('app.string.National')},
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
    return $r('app.string.GoodMorning');
  } else if (currentHour >= 8 && currentHour < 11) {
    return $r('app.string.Good_Morning');
  } else if (currentHour >= 11 && currentHour < 13) {
    return $r('app.string.Good_Afternoon');
  } else if (currentHour >= 13 && currentHour < 18) {
    return $r('app.string.Good_afternoon');
  } else if (currentHour >= 18 && currentHour < 24) {
    return $r('app.string.GoodNiight');
  } else {
    return $r('app.string.Sleep');
  }
}


