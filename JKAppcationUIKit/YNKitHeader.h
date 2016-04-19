//
//  YNKitHeader.h
//  YNKit
//
//  Created by qiyun on 15/11/17.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#ifndef YNKitHeader_h
#define YNKitHeader_h


#ifdef __cplusplus          //c++ armv to c
#define YN_EXTERN_C_BEGIN  extern "C" {
#define YN_EXTERN_C_END  }
#else
#define YN_EXTERN_C_BEGIN
#define YN_EXTERN_C_END
#endif


YN_EXTERN_C_BEGIN

#ifndef YN_CLAMP // return the clamped value
#define YN_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef YN_SWAP // swap two value
#define YN_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif


#ifndef YNSYNTH_DUMMY_CLASS
#define YNSYNTH_DUMMY_CLASS(_name_) \
@interface YNSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation YNSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]


#define CurrentSystemVersion ([[UIDevice currentDevice] systemVersion])


#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

#define UIColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//GCD
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)



#ifdef DEBUG
#   define QYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define QYLog(...)
#endif


#define LOAD_IMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

#endif /* YNKitHeader_h */
