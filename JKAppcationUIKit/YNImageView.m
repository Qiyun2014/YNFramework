
//
//  YNImageView.m
//  YNKit
//
//  Created by qiyun on 15/11/16.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNImageView.h"
#import <objc/runtime.h>

static const int block_key;
static void *imageCache_key = @"cache";
static void *imageSelect_key = @"select";

// location of layer to start
static CGFloat kXSlices = 9.0f;
static CGFloat kYSlices = 12.0f;

@interface YNImageViewActionWithEventBlockTarget : NSObject

@property (nonatomic,copy) void (^block) (id sender);

- (id)initWithBlock:(void (^)(id sender))block;

- (void)invoke:(id)sender;

@end

@implementation YNImageViewActionWithEventBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);

    YNImageView *image = (YNImageView *)[(UITapGestureRecognizer *)sender view];
    BOOL select = !image.selected;
    objc_setAssociatedObject(self, imageSelect_key, @(select), OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation YNImageView

{
    YNImageViewActionWithEventBlockTarget *target;
}
/*!
 *  init 初始化
 *  @param frame UIImageView相对于父视图的位置
 *  @param image 图片
 */
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image{

    self = [super initWithFrame:frame];

    if (self) {

        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.image = image;
    }
    return self;
}

#pragma mark    -   get

- (UIImage *)currentImage{

    return [self image];
}


- (UIImage *)snapshotImage{

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return snap;
}

- (BOOL)selected{

    NSString *value = objc_getAssociatedObject(target, imageSelect_key);
    BOOL select = value.boolValue;
    return select;
}

- (void)setSelected:(BOOL)selected{

    self.selected = !selected;
}

#pragma mark    -   set/get

- (void (^)(id))imageActionBlock {

    target = objc_getAssociatedObject(self, &block_key);

    return target.block;
}

- (void)setImageActionBlock:(void (^)(id))imageActionBlock{

    target = [[YNImageViewActionWithEventBlockTarget alloc] initWithBlock:imageActionBlock];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(invoke:)];
    [self addGestureRecognizer:tap];
}

- (void)setImageCache:(BOOL)imageCache{

    if (imageCache) {

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            //save the image
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr = [formatter stringFromDate:date];

            NSString * namePath = [path stringByAppendingPathComponent:[currentDateStr stringByAppendingString:@".png"]];

            [UIImagePNGRepresentation(self.image) writeToFile:namePath atomically:YES];

            objc_setAssociatedObject(self, imageCache_key, namePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    }
}

- (UIImage *)locationImage{

    NSString *imagePath = objc_getAssociatedObject(self, imageCache_key);

    return [UIImage imageWithContentsOfFile:imagePath];
}


- (void)removeCurrentLayer{

    self.backgroundColor = [UIColor clearColor];

    [self layer].contentsGravity = kCAGravityResizeAspectFill;
    [self layer].masksToBounds = YES;

    [self layer].contents = (__bridge id _Nullable)([self scaleAndCropImage:self.image]);


    if(nil != [self layer].contents) {

        CGSize imageSize = CGSizeMake(CGImageGetWidth([self scaleAndCropImage:self.image]),
                                      CGImageGetHeight([self scaleAndCropImage:self.image]));

        NSMutableArray *layers = [NSMutableArray array];

        for(int x = 0;x < kXSlices;x++) {

            for(int y = 0;y < kYSlices;y++) {

                CGRect frame = CGRectMake((imageSize.width / kXSlices) * x,
                                          (imageSize.height / kYSlices) * y,
                                          imageSize.width / kXSlices,
                                          imageSize.height / kYSlices);

                CALayer *layer = [CALayer layer];
                layer.frame = frame;

                layer.actions = [NSDictionary dictionaryWithObject:
                                 [self animationForX:x Y:y imageSize:imageSize]
                                                            forKey:@"opacity"];
                CGImageRef subimage = CGImageCreateWithImageInRect([self scaleAndCropImage:self.image], frame);
                layer.contents = (__bridge id)subimage;
                CFRelease(subimage);
                [layers addObject:layer];
            }
        }
        for(CALayer *layer in layers) {
            [[self layer] addSublayer:layer];
            layer.opacity = 0.0f;
        }
        [self layer].contents = nil;
    }
}


- (CGPoint)randomDestinationX:(CGFloat)x Y:(CGFloat)y imageSize:(CGSize)size {
    CGPoint destination;

    if((x <= (kXSlices / 2.0f)) && (y <= (kYSlices / 2.0f))) { // top left quadrant
        destination.x = -50.0f * ((CGFloat)(random() % 10000)) / 2000.0f;
        destination.y = -50.0f * ((CGFloat)(random() % 10000)) / 2000.0f;
    } else if((x > (kXSlices / 2.0f)) && (y <= (kYSlices / 2.0f))) { // top right quadrant
        destination.x = size.width + (50.0f * ((CGFloat)(random() % 10000)) / 2000.0f);
        destination.y = -50.0f * ((CGFloat)(random() % 10000)) / 2000.0f;
    } else if((x > (kXSlices / 2.0f)) && (y > (kYSlices / 2.0f))) { // bottom right quadrant
        destination.x = size.width + (50.0f * ((CGFloat)(random() % 10000)) / 2000.0f);
        destination.y = size.height + (50.0f * ((CGFloat)(random() % 10000)) / 2000.0f);
    } else if((x <= (kXSlices / 2.0f)) && (y > (kYSlices / 2.0f))) { // bottom right quadrant
        destination.x = -50.0f * ((CGFloat)(random() % 10000)) / 2000.0f;
        destination.y = size.height + (50.0f * ((CGFloat)(random() % 10000)) / 2000.0f);
    }
    return destination;
}


- (CAAnimation *)animationForX:(NSInteger)x Y:(NSInteger)y
                     imageSize:(CGSize)size {

    // return a group animation, one for opacity from 1 to zero and a keyframe
    // with a path appropriate for the x and y coords
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = 2.0f;

    CABasicAnimation *opacity = [CABasicAnimation
                                 animationWithKeyPath:@"opacity"];
    opacity.fromValue = [NSNumber numberWithDouble:1.0f];
    opacity.toValue = [NSNumber numberWithDouble:0.0f];

    CABasicAnimation *position = [CABasicAnimation
                                  animationWithKeyPath:@"position"];
    position.timingFunction = [CAMediaTimingFunction
                               functionWithName:kCAMediaTimingFunctionEaseIn];

    CGPoint dest = [self randomDestinationX:x Y:y imageSize:size];
    position.toValue = [NSValue valueWithCGPoint:dest];

    group.animations = [NSArray arrayWithObjects:opacity, position, nil];
    return group;
}


/*!
 *  animation did stop
 *  @param theAnimation current animation
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {

    //[self layer].contents = (__bridge id _Nullable)([self scaleAndCropImage:self.image]);

    // remove all sublayers from imageLayer
    NSArray *sublayers = [NSArray arrayWithArray:[self.layer sublayers]];

    for(CALayer *layer in sublayers) {

        [layer removeFromSuperlayer];
    }

    [self removeFromSuperview];
}


- (CGImageRef)scaleAndCropImage:(UIImage *)fullImage {

    CGSize imageSize = fullImage.size;
    CGFloat scale = 1.0f;
    CGImageRef subimage = NULL;

    CGFloat kMaxHeight = self.frame.size.height;
    CGFloat kMaxWidth = self.frame.size.width;

    if(imageSize.width > imageSize.height) {
        // image height is smallest
        scale = kMaxHeight / imageSize.height;
        CGFloat offsetX = ((scale * imageSize.width - kMaxWidth) / 2.0f) / scale;
        CGRect subRect = CGRectMake(offsetX, 0.0f,
                                    imageSize.width - (2.0f * offsetX),
                                    imageSize.height);
        subimage = CGImageCreateWithImageInRect([fullImage CGImage], subRect);
    } else {
        // image width is smallest
        scale = kMaxWidth / imageSize.width;
        CGFloat offsetY = ((scale * imageSize.height - kMaxHeight) / 2.0f) / scale;
        CGRect subRect = CGRectMake(0.0f, offsetY, imageSize.width,
                                    imageSize.height - (2.0f * offsetY));
        subimage = CGImageCreateWithImageInRect([fullImage CGImage], subRect);
    }
    // scale the image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, kMaxWidth,
                                                 kMaxHeight, 8, 0, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGRect rect = CGRectMake(0.0f, 0.0f, kMaxWidth, kMaxHeight);
    CGContextDrawImage(context, rect, subimage);
    CGContextFlush(context);
    // get the scaled image
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGContextRelease (context);
    CGImageRelease(subimage);
    subimage = NULL;
    subimage = scaledImage;
    return subimage;
}


- (void)dealloc{

    target = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
