# taxi_milecounter
汇编语言写的单片机出租车计价器
主要作为一个能够实现出租车实时速度显示以及行走里程和当前价格的小型单片机装置。出租车计价的原则如下：
* 2公里以内按8元计算，超过2公里每公里按2.6元计算。
* 不考虑其他费用。
* 用信号发生器作为模拟的出租车，每一次发送一个高电平的信号说明轮胎转过一圈。
* 当按下按钮时，出租车开始计费，当抬起按钮时，显示屏上的数据不动，再次按下按钮时，所有数据清零，再次重新计数。
