
//
//  YNLabel.m
//  YNKit
//
//  Created by qiyun on 15/11/17.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNLabel.h"

@implementation YNLabel


/*!
 *  init 初始化
 *  @param frame 位置
 *  @param bgColor 背景色
 *  @param title 标题
 */
- (instancetype)initWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)bgColor textTitle:(NSString *)title{

    self = [super initWithFrame:frame];

    if (self) {

        self.frame = frame;

        if (bgColor) self.backgroundColor = bgColor;

        self.text = title;
    }
    return self;
}


- (void)setSizeThatTitle:(BOOL)sizeThatTitle{

    _sizeThatTitle = sizeThatTitle;

    if (sizeThatTitle) {

        [self setHeight:[self getTextOfSize].height];
    }
}

- (CGFloat)left{

    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left{

    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)right{

    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right{

    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)top{

    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top{

    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)bottom{

    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom{

    CGRect frame = self.frame;
    frame.origin.y = bottom -frame.size.height;
    self.frame = frame;
}


- (CGFloat)width{

    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{

    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height{

    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{

    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}



- (CGSize)getTextOfSize{

    NSDictionary *attribute = @{NSFontAttributeName:self.font};

    CGSize size = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                    options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:attribute
                                    context:nil].size;

    return size;
}



/*!
 *  attribute
 *  @param text 文字
 *  @param range 范围
 *  @param aDict 属性设定
 */
- (void)setAttributedText:(NSString *)text withRange:(NSRange)range attibutetDictionary:(NSDictionary *)aDict{

    NSMutableAttributedString *attributedSrting = [[NSMutableAttributedString alloc] initWithString:text];

    [attributedSrting setAttributes:aDict range:range];

    self.attributedText = attributedSrting;
}



/*!
 *  sepline
 *  @param frame 位置
 *  @param width 宽度
 *  @param color 颜色
 */
+ (UILabel *)sepLine_label_crateWithFrame:(CGRect)frame width:(CGFloat)width strokeColor:(UIColor *)color{

    YNLabel *label = [[YNLabel alloc] initWithFrame:frame];
    label.backgroundColor = color;
    [label setHeight:width];
    return label;
}

@end
