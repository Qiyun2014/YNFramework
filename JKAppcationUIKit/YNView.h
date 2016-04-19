//
//  YNView.h
//  YNKit
//
//  Created by qiyun on 15/11/17.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNView : UIView


- (instancetype)initWithFrame:(CGRect)frame;


/*!
 *  绘制一条直线
 *  @param sPoint 起点
 *  @param ePoint 终点
 *  @param color 颜色
 */
- (void)drawLineWithStartPoint:(CGPoint)sPoint toEndPoint:(CGPoint)ePoint withLineColor:(UIColor *)color lineHeight:(CGFloat)height;


/*!
 *  绘制矩形
 *  @param frame 位置
 *  @param color 边框颜色
 *  @param width 边框宽度
 *  @param bgColor 填充颜色
 */
- (void)drawRectangleWithFrame:(CGRect)frame strokeColor:(UIColor *)color strokeWidth:(CGFloat)width fillBackgroundColor:(UIColor *)bgColor;


/*!
 *  绘制渐变矩形
 *  @param frame 位置
 *  @param sColor 开始颜色
 *  @param tColor 结束颜色
 */
- (void)drawGradientWithFrame:(CGRect)frame startColor:(UIColor *)sColor toColor:(UIColor *)tColor;


//snapshot 快照
@property (nonatomic,readonly) UIImage *snapshotImage;


/**
 Create a snapshot PDF of the complete view hierarchy.
 */
- (NSData *)snapshotPDF;


/*!
 *  @discussion When the current method is called when will make the imageView images like cards and broken, and then spread out
 *
 *  @discussion CAAnimation animations, a key-frame animation to simulate the dynamic 3D effects
 *
 *  @discussion remove all layer ,and remove self from superview
 *
 *  @par [self removeCurrentLayer]
 */
- (void)removeCurrentLayer;

@end


#pragma mark    -   YNPicker view 

/*!
 *  only show year and mounth
 *
 * @discussion
 *
 * example:
 *   _pickerView = [[YNPickerView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 216)];
 *   _pickerView.minYear = 2015;
 *   _pickerView.maxYear = 2100;
 *   _pickerView.pDelegate = self;
 *   [self.view addSubview:_pickerView];

 *   _pickerView.mouthValue = 12;
 *   _pickerView.showDateCurrent = YES;
 */

@protocol YNPickerDelegate <NSObject>

/*!
 *  当前日期
 *  @param dateString 日期字符串
 */
- (void)getCurrentPickerWithDateString:(NSString *)dateString;

@end

@interface YNPickerView : YNView<UIPickerViewDataSource,UIPickerViewDelegate>

//日历选择器
@property (nonatomic,readonly) UIPickerView     *pickerView;

//设置最小年
@property (nonatomic,assign) NSInteger  minYear;

//设置最大年
@property (nonatomic,assign) NSInteger  maxYear;

//是否默认显示当前年
@property (nonatomic,assign) BOOL   showDateCurrent;

//默认月份
@property (nonatomic,assign) NSInteger  mouthValue;


/*!
 *  代理
 */
@property (nonatomic,assign) id<YNPickerDelegate> pDelegate;


@end
