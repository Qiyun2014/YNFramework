//
//  YNButton.m
//  YNKit
//
//  Created by qiyun on 15/11/16.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNButton.h"
#import <objc/runtime.h>
#import "YNKit.h"

YNSYNTH_DUMMY_CLASS(YNActionWithEventBlockTarget)

static const int block_key;

@interface YNActionWithEventBlockTarget : NSObject

@property (nonatomic,copy) void (^block) (id sender);

- (id)initWithBlock:(void (^)(id sender))block;

- (void)invoke:(id)sender;

@end

@implementation YNActionWithEventBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    
    if (_block) _block(sender);
}

@end

@implementation YNButton

/*!
 *  init 初始化
 *  @param frame    button相对于父视图的位置
 *  @param type     button的类型
 */
- (instancetype)initWithFrame:(CGRect)frame buttonWithType:(UIButtonType)type{

    self = [super initWithFrame:frame];

    if (self) {

        self = [YNButton buttonWithType:type];
        self.frame = frame;
    }
    return self;
}


- (void)setSelectImage:(UIImage *)selectImage{

    _selectImage = selectImage;

    self.selected = YES;

    [self setImage:_selectImage forState:UIControlStateNormal];
}

- (void)setUnselectImage:(UIImage *)unselectImage{

    _unselectImage = unselectImage;

    self.selected = NO;

    [self setImage:_unselectImage forState:UIControlStateSelected];
}

- (void)setYnSelector:(SEL)ynSelector{

    _ynSelector = ynSelector;

    YNActionWithEventBlockTarget *target = [[YNActionWithEventBlockTarget alloc] initWithBlock:nil];

    [self addTarget:target action:_ynSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void (^)(id sender)) actionBlock {

    YNActionWithEventBlockTarget *target = objc_getAssociatedObject(self, &block_key);

    return target.block;
}

- (void)setActionBlock:(void (^)(id))actionBlock{

    self.userInteractionEnabled = YES;

    YNActionWithEventBlockTarget *target = [[YNActionWithEventBlockTarget alloc] initWithBlock:actionBlock];

    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addTarget:target action:@selector(invoke:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setControlEvent:(UIControlEvents)controlEvent{

    _controlEvent = controlEvent;

    [self removeTarget:self action:_ynSelector forControlEvents:UIControlEventAllEvents];

    [self addTarget:self action:_ynSelector forControlEvents:controlEvent];
}

#pragma mark    -   attribute string

- (void)setAttributedTitle:(NSString *)title withRange:(NSRange)range withTextColor:(UIColor *)color{

    NSMutableAttributedString *attributedSrting = [[NSMutableAttributedString alloc] initWithString:title];

    [attributedSrting setAttributes:@{NSForegroundColorAttributeName : color} range:range];

    [self setAttributedTitle:attributedSrting forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
