//
//  YNBarButtonItem.h
//  YNKit
//
//  Created by qiyun on 15/11/23.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNBarButtonItem : UIBarButtonItem


- (instancetype)initWithSystemItem:(UIBarButtonItemStyle)item withTitle:(NSString *)title;


/*!
 *  custom barButtonItem
 *  @param viewController
 *  @param selctor                
 */
+ (void)addBackButtonItemInViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName responseAction:(void (^)(id sender))reponse;


/**
 The block that invoked when the item is selected. The objects captured by block
 will retained by the ButtonItem.

 @discussion This param is conflict with `target` and `action` property.
 Set this will set `target` and `action` property to some internal objects.
 */
@property (nonatomic, copy) void (^actionBlock)(id sender);




@end
