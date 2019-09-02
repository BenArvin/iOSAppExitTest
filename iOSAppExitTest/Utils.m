//
//  Utils.m
//  iOSAppExitTest
//
//  Created by BenArvin on 2019/8/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

#import "Utils.h"
#import <objc/runtime.h>

@implementation Utils

+ (void)callFuncDynamically:(bool)classFunc
                targetClass:(Class)targetClass
             targetInstance:(id)targetInstance
                   selector:(SEL)selector
                paramsCount:(int)paramsCount
                     params:(void *[])params
                     result:(void *)result {
    Class realTargetClass = targetClass;
    id realTargetInstance = targetInstance;
    if (classFunc) {
        realTargetClass = objc_getMetaClass([NSStringFromClass(targetClass) UTF8String]);
        realTargetInstance = targetClass;
    }
    NSMethodSignature *sig = [realTargetClass instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.target = realTargetInstance;
    invocation.selector = selector;
    
    for (int i=0; i<paramsCount; i++) {
        void *tmpParamItem = params[i];
        [invocation setArgument:tmpParamItem atIndex:(i+2)];
    }
    
    [invocation invoke];
    
//    const char *sigretun = sig.methodReturnType;
    NSUInteger siglength = sig.methodReturnLength;
    if (siglength != 0) {
//        if (strcmp(sigretun, "@") == 0) {
//            NSString *returnStr;
//            [invocation getReturnValue:&returnStr];
//        } else if (strcmp(sigretun, "i")){
//            int a = 0;
//            [invocation setReturnValue:&a];
//        }
        if (result) {
            [invocation getReturnValue:result];
        }
    }
}

@end
