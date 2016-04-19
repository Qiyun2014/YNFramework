//
//  YNButton.h
//  YNKit
//
//  Created by qiyun on 15/11/16.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNButton : UIButton

/*!
 *  init 初始化
 *  @param frame    button相对于父视图的位置
 *  @param type     button的类型
 */
- (instancetype)initWithFrame:(CGRect)frame buttonWithType:(UIButtonType)type;


//select image  选中的图片
@property (nonatomic,copy) UIImage *selectImage;


//unselect image 未选中的图片
@property (nonatomic,copy) UIImage *unselectImage;


#pragma mark    -   button selector

//selector 点击响应的方法名
@property (nonatomic,assign) SEL ynSelector;

//action 响应的block函数
@property (nonatomic, copy) void (^actionBlock)(id sender);




//response type 点击响应的事件类型
@property (nonatomic,assign) UIControlEvents controlEvent;



#pragma mark    -   attribute string

/*!
 *  setAttributedTitle  设置属性字符串文本
 *  @param title 文字
 *  @param range 属性范围
 *  @param color 颜色
 */
- (void)setAttributedTitle:(NSString *)title withRange:(NSRange)range withTextColor:(UIColor *)color;


@end
