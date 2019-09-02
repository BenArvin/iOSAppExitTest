//
//  Utils.h
//  iOSAppExitTest
//
//  Created by BenArvin on 2019/8/30.
//  Copyright © 2019 BenArvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

/**
 call function dynamically

 @param classFunc bool, is class function
 @param targetClass Class
 @param targetInstance id, nil if target function is class function
 @param selector SEL
 @param paramsCount count of parameters
 @param params void *[]
 @param result void *
 @code
 //Example
 NSString *testString = @"testString";
 int testNumber = 999;
 NSObject testNull = NULL;
 void *testParam[3] = {&testString, &testNumber, &testNull};
 int testResult;
 [... callFuncDynamic:false targetClass:[TestClass class] targetInstance:[TestClass testInstance] selector:@selector(testFunc:param:) paramsCount:3 params:testParam result:&testResult];
 
 NSString *testString = @"testString";
 void *testParam[1] = {&testString};
 __unsafe_unretained NSObject *tmpTestResult;//object type tmpTestResult isn't safe for use, it may released later
 [... callFuncDynamic:false targetClass:[TestClass class] targetInstance:[TestClass testInstance] selector:@selector(testFunc:param:) paramsCount:1 params:testParam result:&tmpTestResult];
 NSObject *testResult = tmpTestResult;//now you can use result safely
 */
+ (void)callFuncDynamically:(bool)classFunc
                targetClass:(Class)targetClass
             targetInstance:(id)targetInstance
                   selector:(SEL)selector
                paramsCount:(int)paramsCount
                     params:(void *[])params
                     result:(void *)result;

@end
