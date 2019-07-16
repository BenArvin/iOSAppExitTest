//
//  ViewController.m
//  iOSAppExitTest
//
//  Created by BenArvin on 2019/7/10.
//  Copyright © 2019 BenArvin. All rights reserved.
//

#import "ViewController.h"
#include <stdlib.h>

static __attribute__((always_inline)) void asm_exit() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov w16, #1\n"
            "svc #0x80\n"
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret");
#endif
}

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = @[@"exit", @"abort", @"assert",  @"signal SIGKILL", @"signal SIGQUIT", @"kill", @"fopen", @"NSThread +exit", @"_terminateWithStatus", @"terminateWithSuccess", @"killall", @"asm_exit"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [self.datas objectAtIndex:indexPath.row];
    if ([title isEqualToString:@"exit"]) {
        exit(0);
    } else if ([title isEqualToString:@"abort"]) {
        abort();
    } else if ([title isEqualToString:@"assert"]) {
        assert(nil);
    } else if ([title isEqualToString:@"signal SIGKILL"]) {
        signal(SIGKILL, NULL);//卡死不退出
    } else if ([title isEqualToString:@"signal SIGQUIT"]) {
        signal(SIGQUIT, NULL);//卡死不退出
    } else if ([title isEqualToString:@"kill"]) {
        kill(getpid(), SIGINT);
    } else if ([title isEqualToString:@"fopen"]) {
        fopen("123456", "123");//卡死不退出
    } else if ([title isEqualToString:@"NSThread +exit"]) {
        [NSThread exit];//卡死不退出
    } else if ([title isEqualToString:@"_terminateWithStatus"]) {
        [[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"_terminateWithStatus:") withObject:@(0)];
    } else if ([title isEqualToString:@"terminateWithSuccess"]) {
        [[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"terminateWithSuccess")];
    } else if ([title isEqualToString:@"killall"]) {
        //        system("killall -9 TestAPP");
        popen("killall -9 CrashTestAPP", "r");//卡死不退出
    } else if ([title isEqualToString:@"asm_exit"]) {
        asm_exit();
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

@end
