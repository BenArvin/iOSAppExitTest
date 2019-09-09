//
//  ViewController.m
//  iOSAppExitTest
//
//  Created by BenArvin on 2019/7/10.
//  Copyright © 2019 BenArvin. All rights reserved.
//

#import "ViewController.h"
#include <stdlib.h>
#import "my_ptrace.h"
#import <sys/syscall.h>
#import <sys/sysctl.h>

static __attribute__((always_inline)) void asm_exit() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov X16, #1\n"
            "svc #0x80\n"
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret");
#endif
}

static __attribute__((always_inline)) void asm_exit_sassy() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov X16, #1\n"
            "svc #128\n"
            );
#endif
}

static __attribute__((always_inline)) void asm_ptrace() {
#ifdef __arm64__
    __asm__("mov X0, #31\n"
            "mov X1, #0\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov X16, #26\n"
            "svc #0x80\n"
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret"
            );
#endif
}

static __attribute__((always_inline)) void asm_ptrace_sassy() {
#ifdef __arm64__
    __asm__("mov X0, #31\n"
            "mov X1, #0\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov X16, #26\n"
            "svc #0x80\n"
            );
#endif
}

static __attribute__((always_inline)) void ret() {
#ifdef __arm64__
    __asm__("mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret"
            );
#endif
}

bool sysctl_check() {
    int name[4];
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    int error = sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
//    int error = syscall(SYS_sysctl, name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
    if (error != 0) {
        return false;
    }
    return ((info.kp_proc.p_flag & P_TRACED) !=0);
}

//TODO: asm version of sysctl
//static __attribute__((always_inline)) void asm_sysctl_check() {
//#ifdef __arm64__
//    __asm__();
//#endif
//}

//useless, because ipa download from appstore doesn't contain embedded.mobileprovision file
void checkCodesign(NSString *devID){
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i = 0; i < embeddedProvisioningLines.count; i++) {
        if ([embeddedProvisioningLines[i] rangeOfString:@"application-identifier"].location != NSNotFound) {
            
            NSInteger fromPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"<string>"].location+8;
            
            NSInteger toPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"</string>"].location;
            
            NSRange range;
            range.location = fromPosition;
            range.length = toPosition - fromPosition;
            
            NSString *fullIdentifier = [embeddedProvisioningLines[i+1] substringWithRange:range];
            NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
            NSString *appIdentifier = [identifierComponents firstObject];
            
            if (![appIdentifier isEqual:devID]) {
                //do something
            }
            break;
        }
    }
}

int isattyCheck() {
    return isatty(STDOUT_FILENO);
}

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES];
    
    self.datas = @[@"exit", @"abort", @"assert",  @"signal SIGKILL", @"signal SIGQUIT", @"kill", @"fopen", @"NSThread +exit", @"_terminateWithStatus", @"terminateWithSuccess", @"killall", @"asm_exit", @"asm_exit_sassy", @"ptrace", @"asm_ptrace", @"asm_ptrace_sassy", @"ret", @"sysctl", @"isatty"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
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
        asm_exit();//退出，无崩溃日志
    } else if ([title isEqualToString:@"asm_exit_sassy"]) {
        asm_exit_sassy();//退出，无崩溃日志
    } else if ([title isEqualToString:@"ptrace"]) {
        ptrace(PT_DENY_ATTACH, 0, 0, 0);
    } else if ([title isEqualToString:@"asm_ptrace"]) {
        asm_ptrace();//退出，EXC_BAD_ACCESS
    } else if ([title isEqualToString:@"asm_ptrace_sassy"]) {
        asm_ptrace_sassy();
    } else if ([title isEqualToString:@"ret"]) {
        ret();//退出，EXC_BAD_ACCESS
    } else if ([title isEqualToString:@"sysctl"]) {
        [self showAlertView:@"sysctl" content:[NSString stringWithFormat:@"%d", sysctl_check()]];
    } else if ([title isEqualToString:@"isatty"]) {
        [self showAlertView:@"isatty" content:[NSString stringWithFormat:@"%d", isattyCheck()]];
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

- (void)showAlertView:(NSString *)title content:(NSString *)content {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
