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
 
  3. autoreleasepool的理解
     autoreleasepool并没有单独的数据结构，也不是之前之前理解的是一个一个内存管理池子，它实质上是由众多AutoreleasePoolPage(c++类)组成的一个双向链表，每次项目里需要创建变量并分配内存时都会先创建这么一个AutoreleasePoolPage对象，然后将这些变量的地址都存储到这个对象的指针栈里，如果当前AutoreleasePoolPage对象栈满了又会创建一个新的AutoreleasePoolPage，那么所谓的一个一个的autoreleasepool其实是以这个栈里的哨兵指针分割开来的
  4. autoreleasepool与runloop、线程的关系
     autoreleasepool会在runloop的一次迭代启动时创建，并在此次迭代结束时销毁，进入睡眠时先销毁旧的池子然后再创建一个新的
     autoreleasepool与线程一一对应，就像runloop鱼线程的关系一样，一个线程，不管是主线程还是子线程，创建的时候会默认创建一个最外层的autoreleasepool，所以，通常情况下，对子线程任务块无需手动加@autoreleasepool{}，里面的自动释放对象不会产生内存泄露，但以下情况除外：
            a、如果你编写的程序不是基于 UI 框架的，比如说命令行工具；
 
            b、如果你编写的循环中创建了大量的临时对象；
 
            c、如果你创建了一个辅助线程。
  参考：http://www.cocoachina.com/ios/20150610/12093.html
        https://www.jianshu.com/p/f87f40592023
        https://www.jianshu.com/p/03f0c41410d9
        http://blog.sunnyxx.com/2014/10/15/behind-autorelease/
 */
