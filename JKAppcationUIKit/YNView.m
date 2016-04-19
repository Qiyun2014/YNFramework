//
//  YNView.m
//  YNKit
//
//  Created by qiyun on 15/11/17.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNView.h"
#import <CoreGraphics/CoreGraphics.h>

// location of layer to start
static CGFloat kXSlices = 9.0f;
static CGFloat kYSlices = 12.0f;

@implementation YNView


- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if (self) {

        self.frame = frame;
    }
    return self;
}

/*!
 *  绘制一条直线
 *  @param sPoint 起点
 *  @param ePoint 终点
 *  @param color 颜色
 */
- (void)drawLineWithStartPoint:(CGPoint)sPoint toEndPoint:(CGPoint)ePoint withLineColor:(UIColor *)color lineHeight:(CGFloat)height{

    CGContextRef    context = UIGraphicsGetCurrentContext();        //get the current context

    CGMutablePathRef path = CGPathCreateMutable();                  //create path object
    CGPathMoveToPoint(path, NULL, ePoint.x, ePoint.y);
    CGPathCloseSubpath(path);

    CGContextSetLineWidth(context, height);                        //line height
    CGContextSetStrokeColorWithColor(context, [color CGColor]);     //set stroke color
    CGContextSetLineJoin(context, kCGLineJoinRound);                //set the line round , miter , bevel

    CGContextDrawPath(context, kCGPathStroke);

    CGPathRelease(path);
    CGContextRelease(context);
}


/*!
 *  绘制矩形
 *  @param frame 位置
 *  @param color 边框颜色
 *  @param width 边框宽度
 *  @param bgColor 填充颜色
 */
- (void)drawRectangleWithFrame:(CGRect)frame strokeColor:(UIColor *)color strokeWidth:(CGFloat)width fillBackgroundColor:(UIColor *)bgColor{

    CGContextRef    content = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(content, [color CGColor]);     //  set stroke color
    CGContextSetFillColorWithColor(content, [bgColor CGColor]);     //  background color

    CGContextSetLineWidth(content, width);
    CGContextStrokeRect(content, frame);

    CGContextRelease(content);
}


/*!
 *  绘制渐变矩形
 *  @param frame 位置
 *  @param sColor 开始颜色
 *  @param tColor 结束颜色
 */
- (void)drawGradientWithFrame:(CGRect)frame startColor:(UIColor *)sColor toColor:(UIColor *)tColor{

    CGContextRef content = UIGraphicsGetCurrentContext();

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();                     //color mode
    NSArray *colors = @[(__bridge id)sColor.CGColor,(__bridge id)tColor.CGColor];   //colors
    CGFloat location[2] = {0,1};

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, location);
    CGContextSaveGState(content);
    CGContextAddRect(content, frame);       //rectangle
    CGContextClip(content);

    CGContextDrawLinearGradient(content, gradient, CGPointZero, CGPointMake(frame.size.width, frame.size.height), kCGGradientDrawsAfterEndLocation); //end point
    CGContextRestoreGState(content);

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextRelease(content);
}



- (UIImage *)snapshotImage{

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return snap;
}


- (NSData *)snapshotPDF {
    
    CGRect bounds = self.bounds;
    NSMutableData* data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}


- (void)removeCurrentLayer{

    self.backgroundColor = [UIColor clearColor];

    [self layer].contentsGravity = kCAGravityResizeAspectFill;
    [self layer].masksToBounds = YES;

    [self layer].contents = (__bridge id _Nullable)([self scaleAndCropImage:self.snapshotImage]);


    if(nil != [self layer].contents) {

        CGSize imageSize = CGSizeMake(CGImageGetWidth([self scaleAndCropImage:self.snapshotImage]),
                                      CGImageGetHeight([self scaleAndCropImage:self.snapshotImage]));

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
                CGImageRef subimage = CGImageCreateWithImageInRect([self scaleAndCropImage:self.snapshotImage], frame);
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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation YNPickerView
{
    NSMutableArray  *_yearArray, *_mouthArray;

    NSString        *year,*month;
}

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if (self) {

        _mouthArray = [NSMutableArray arrayWithObjects:
                       @"01月",@"02月",@"03月",
                       @"04月",@"05月",@"06月",
                       @"07月",@"08月",@"09月",
                       @"10月",@"11月",@"12月", nil];

        _yearArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)configurePickView{

    if (_yearArray.count <= 0) return;

    [_pickerView removeFromSuperview];

    // 选择框
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];

    // 显示选中框
    _pickerView.showsSelectionIndicator=YES;

    _pickerView.dataSource = self;
    _pickerView.delegate = self;

    [self addSubview:_pickerView];
}


#pragma mark    -   set/get method

- (void)setMinYear:(NSInteger)minYear{

    _minYear = minYear;

    for (int i = MAX(2000, (int)_minYear); i <= 2015 - _minYear; i ++) {

        [_yearArray addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    [self configurePickView];
}


- (void)setMaxYear:(NSInteger)maxYear{

    _maxYear = maxYear;

    for (int i = MAX(2000, (int)_minYear); i <= _maxYear; i ++) {

        //NSLog(@"object = %@",[NSString stringWithFormat:@"%d年",i]);
        [_yearArray addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    [self configurePickView];
}

- (void)setShowDateCurrent:(BOOL)showDateCurrent{

    _showDateCurrent = showDateCurrent;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        year = _yearArray.firstObject;

        month = _mouthArray[MAX(0, _mouthValue-1)];

        [_pickerView selectRow:0 inComponent:0 animated:YES];

        [_pickerView selectRow:_mouthValue-1 inComponent:1 animated:YES];

        if (year && month) {

            if ([self.pDelegate respondsToSelector:@selector(getCurrentPickerWithDateString:)]) {

                [self.pDelegate getCurrentPickerWithDateString:[year stringByAppendingString:month]];
            }
        }
    });
}

#pragma mark    -   UIPickerDelegate    datasource

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 2;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (component == 0) {

        return [_yearArray count];
    }
    return [_mouthArray count];
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    return [UIScreen mainScreen].bounds.size.width/3;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) year = _yearArray[row];
    else                month = _mouthArray[row];

    if (year && month) {

        if ([self.pDelegate respondsToSelector:@selector(getCurrentPickerWithDateString:)]) {

            [self.pDelegate getCurrentPickerWithDateString:[year stringByAppendingString:month]];
        }
    }
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0 && row < _yearArray.count){

        return _yearArray[row];
    }
    else if(row < _mouthArray.count){
        
        return _mouthArray[row];
    }else
        return @"";
}


- (void)dealloc{
    
    [_pickerView removeFromSuperview];
}

@end

