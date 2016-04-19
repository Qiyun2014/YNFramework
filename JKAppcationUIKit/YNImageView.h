//
//  YNImageView.h
//  YNKit
//
//  Created by qiyun on 15/11/16.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNImageView : UIImageView

/*!
 *  init 初始化
 *  @param frame UIImageView相对于父视图的位置
 *  @param image 图片
 */
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image;


//the image
@property (nonatomic,readonly) UIImage  *currentImage;


//image response from click
@property (nonatomic,copy) void(^imageActionBlock)(id);


//if cache current image , default is no
@property (nonatomic,assign) BOOL   imageCache;


//snapshot
@property (nonatomic,readonly) UIImage *snapshotImage;


//select or didSelect , default is yes
@property (nonatomic,getter=selected) BOOL  selected;


//store image, if cache a image, locationImage will return the image
- (UIImage *)locationImage;


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
