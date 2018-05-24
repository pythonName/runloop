//
//  ViewController.m
//  runLoop
//
//  Created by loary on 2018/5/23.
//  Copyright © 2018年 eee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    BOOL _isNewThreadAborted;
    NSThread *_thread;
    NSRunLoop *_runl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.0x6000001fb900
    _isNewThreadAborted = NO;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn addTarget:self action:@selector(extt) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"tst" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:btn];

    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 400, 100, 100);
    [btn1 addTarget:self action:@selector(killThread) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitle:@"release thread" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:btn1];
    
    //子线程是否销毁取决于该子线程中的runloop是否结束，如果runloop没有启动或是runloop已结束停止，则该线程便会被销毁，而不是取决于项目工程中指向该线程的线程对象变量是否是nil【即设置_thread=nil】这样的操作并不能销毁线程
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(childThreadMethod) object:nil];
    [_thread setName:@"常驻线程"];
    [_thread start];
}

/* 1、一次性的耗时异步任务，无需启动子线程的runloop，任务执行完毕该线程便销毁
   2、频繁多次的异步任务，可以每次都创建一个一次性的线程来处理，但频繁的创建销毁线程开销大浪费资源，故可创建一个“常驻子线程”来处理，最简单的方式便是开启runloop的run函数【模式是NSDefaultRunLoopMod】，因为run之后，很难将runloop停止，即使用CFRunLoopStop(runloopRef);也无法停止Run Loop的运行，除非能移除这个runloop上的所有事件源，包括定时器和source事件，不然这个子线程就无法停止，只能永久运行下去
 */
- (void)childThreadMethod {
    NSLog(@"childThreadMethod----%@",_thread);
    @autoreleasepool{
        NSLog(@"休眠一秒！！");
        
        /*第一种方式-- - (void)run; 无条件运行,无法通过CFRunLoopStop(runloopRef)来停止*/
        //一种简单的“常驻子线程”创建方式,直接run；
        //还可以用另外两个相关的run函数来实现，不过没有必要也更麻烦，另外两个主要是对runloop的的生命周期进行控制，如该runloop运行多久就可以销毁、该runloop在满足什么样的情况下就可以销毁了等
//        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];//添加一个空的端口,添加事件源
//        [runloop run];
        
        
        /*第二种方式  - (void)runUntilDate:(NSDate *)limitDate;
          无法通过CFRunLoopStop(runloopRef)来停止*/
        /* 一个runloop就是一个循环，那么如何保证这个循环一直运行不退出呢？也即保证该runloop一直在跑、线程不销毁？
           一种方式就是给这个runloop添加各种事件源、另外一种就是手动写一个while循环，直接定义一个循环变量，根据这个循环变量的值来一直执行runloop的run代码,这两种不要搞混了[但还是觉得自定义一个while循环的效率没有runloop自带的好]
         */
//        while (!_isNewThreadAborted) {
//            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//            //[runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];//添加一个空的端口
//
//            //[runloop run];
//
//            //[runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];//表示运行runloop 10秒再退出runloop，也可以指定为[NSDate distantFuture]，这表示一直运行，跟直接调用run函数效果一样了
//
//
//            NSLog(@"exiting runloop.........:");
//        }
        
        /*第三种方式 - (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate;
          可以通过CFRunLoopStop(runloopRef)来停止
         貌似无法通过此方法来做保活线程，因为这里除了time事件源外其他任何事件源在处理之后都会退出runloop，可通过返回值来判断*/
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        _runl = runloop;
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        BOOL flag = [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"exiting runloop.........:%d",flag);
        
       /*
        NSRunLoop是线程不安全的
        CFRunLoop是线程安全的
        */
        
        /*
          前两种方式实质是一样的，运行了就不那么容易退出了，除非移除runloop上的所有事件源，一般实际项目中不那么容易，第三种方式实质是基于CoreFoundation的CFRunLoopRunInMode来封装的，基于CoreFoundation启动的runloop都能通过CFRunLoopStop来停止，不管当前runloop上有没有事件源
         */
    }
}


/*
  1.runloop与autoreleasePool的关系？
    每个线程都会一一对应一个runloop对象来处理各种事件，而此处所说的runloop指的是一次事件处理过程（比如处理一个按钮点击事件、一次timer定时操作、一个系统delegate【如tableview的一次所有的代理函数回调】等），那么在开始这个过程之前，也即启动一个“runloop”之前，系统会默认创建一个autoreleasepool来将此次要做的所有任务都放在这个自动释放池里来管理其中的对象；
    并且在该“runloop”过程结束或休眠的时候销毁这个池子，即达到自动释放此次任务中的对象
    autoreleasepool是可以嵌套的，这也就解释了ios项目中main函数有一个最外层的autureleasepool，但实际上项目中各个地方系统都隐试的创建了很多自动释放池
 2. 面试：NSAutoreleasePool何时释放？
    应该这么说：ARC管理的对象应该在其当前所处的自动释放池释放时释放，那这个自动释放池是在其当前所处的“runloop”结束或休眠时释放
 在没有手加Autorelease Pool的情况下，Autorelease对象是在当前的runloop迭代结束时释放的，而它能够释放的原因是系统在每个runloop迭代中都加入了自动释放池Push和Pop
 */
- (void)killThread {
    /*
      比如这个按钮点击响应事件处理，其就是当前主线程的一次“runloop”，这个方法里隐试的被一个autoreleasepool所包含，这也就解释了在这个方法里创建的自动释放的对象在该方法结束之后便不能再使用了
     */
    
    NSLog(@"killThread");
    //_thread = nil;
    //CFRunLoopStop([_runl getCFRunLoop]);
}

- (void)extt {
    NSLog(@"执行extt！");
    [self performSelector:@selector(abc) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)abc {
    //NSLog(@"abc----%@",[NSThread currentThread]);
    NSLog(@"abc---");
}


@end
