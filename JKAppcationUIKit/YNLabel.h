//
//  YNLabel.h
//  YNKit
//
//  Created by qiyun on 15/11/17.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNLabel : UILabel


/*!
 *  init 初始化
 *  @param frame 位置
 *  @param bgColor 背景色
 *  @param title 标题
 */
- (instancetype)initWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)bgColor textTitle:(NSString *)title;


//auto accommodate title of size
@property (nonatomic,assign) BOOL sizeThatTitle;


@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;



/*!
 *  the underlying attributed string drawn by the label, if set, the label ignores the properties above.
 *  @param text 文字
 *  @param range 范围
 *  @param aDict 属性设定
 *  @param sample   @{NSForegroundColorAttributeName:[UIColor whiteColor]}
 */
- (void)setAttributedText:(NSString *)text withRange:(NSRange)range attibutetDictionary:(NSDictionary *)aDict;


/*!
 *  sepline
 *  @param frame 位置
 *  @param width 宽度
 *  @param color 颜色
 */
+ (UILabel *)sepLine_label_crateWithFrame:(CGRect)frame width:(CGFloat)width strokeColor:(UIColor *)color;


@end
