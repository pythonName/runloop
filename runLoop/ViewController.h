//
//  ViewController.h
//  runLoop
//
//  Created by loary on 2018/5/23.
//  Copyright © 2018年 eee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end
//参考：https://www.jianshu.com/p/4d5b6fc33519
/*
  1.什么事runloop？
    就是一个循环，不断的处理任务
    就是线程上的一个附属特性
    每个线程都有一个runloop，主线程默认启动了，子线程默认没有启动
    runloop运行时每次只能运行在一个mode下，如果要切换mode运行，必须先退出当前mode，然后再以新的mode进入运行
 
 2. 什么时候需要用到Run Loop？官方文档的建议是：
 
 需要使用Port或者自定义Input Source与其他线程进行通讯。
 需要在线程中使用Timer。
 需要在线程上使用performSelector*****方法。
 需要让线程执行周期性的工作。
 
 我个人在开发中遇到的需要使用Run Loop的情况有：
 
 使用自定义Input Source和其他线程通信
 子线程中使用了定时器
 使用任何performSelector*****到子线程中运行方法
 使用子线程去执行周期性任务
 NSURLConnection在子线程中发起异步请求
 */
