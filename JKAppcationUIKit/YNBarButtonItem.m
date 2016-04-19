//
//  YNBarButtonItem.m
//  YNKit
//
//  Created by qiyun on 15/11/23.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNBarButtonItem.h"
#import <objc/runtime.h>
#import "YNButton.h"

static const int block_key;

@interface _YNUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _YNUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end


@implementation YNBarButtonItem


- (instancetype)initWithSystemItem:(UIBarButtonItemStyle)item withTitle:(NSString *)title{

    if (title)  self = [super initWithTitle:title style:item target:nil action:nil];
    else    self = [super initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];

    if (self) {

    }
    return self;
}


#define MYBUNDLE_NAME @ "resource.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

+ (void)addBackButtonItemInViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName responseAction:(void (^)(id sender))reponse{

    YNButton *button  =   [[YNButton alloc]initWithFrame:CGRectMake(0, 0, 14.5, 22)];

    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -9, 0, 9)];

    UIImage *image = [UIImage imageWithContentsOfFile:[MYBUNDLE.bundlePath stringByAppendingPathComponent:imageName]];
    if (!image) {

        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        image = [[UIImage alloc] initWithContentsOfFile:path];
    }


    [button setImage:image  forState:UIControlStateNormal];

    YNBarButtonItem *leftBtn    =  [[YNBarButtonItem alloc]initWithCustomView:button];

    viewController.navigationItem.leftBarButtonItem = leftBtn;

    [button setActionBlock:^(id sender) {

        reponse(sender);
    }];

}


- (void)setActionBlock:(void (^)(id sender))block {
    _YNUIBarButtonItemBlockTarget *target = [[_YNUIBarButtonItemBlockTarget alloc] initWithBlock:block];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void (^)(id sender)) actionBlock {
    _YNUIBarButtonItemBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}

@end
