//
//  YNModel.h
//  YNKit
//
//  Created by qiyun on 15/11/27.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YNParserObject.h"

typedef NS_OPTIONS(NSInteger , YNObject_Type){

    YNObject_TypeClassUnknown = 0,
    YNObject_TypeClassNSString,
    YNObject_TypeClassNSMutableString,
    YNObject_TypeClassNSArray,
    YNObject_TypeClassNSMutableArray,
    YNObject_TypeClassNSDictionary,
    YNObject_TypeClassNSMutableDictionary,
    YNObject_TypeClassNSData,
    YNObject_TypeClassNSMutableData,
    YNObject_TypeClassNSSet,
    YNObject_TypeClassNSMutableSet
};

@interface YNModel:NSObject

extern NSString * YNIsNullString(NSString *aString);

/**
 Creates and returns a new instance of the receiver from a json.
 This method is thread-safe.

 @param json  A json object in `NSDictionary`, `NSString` or `NSData`.

 @return A new instance created from the json, or nil if an error occurs.
 */
+ (instancetype)initWithObject:(id)object withClassName:(NSString *)className;
+ (instancetype)initWithObject:(id)object withClass:(Class)cls;


/*!
 * @brief model to dictionary
 */
+ (NSDictionary *)dictionaryWithModel:(id)model;


/*!
 * @brief model to array
 */
+ (NSArray *)propertiesInModel:(id)model;

//set object type
@property (nonatomic,readonly) YNObject_Type encodingType;


@end


@interface NSDictionary (YNDictionary)

/*!
 *  json string to dictionary
 *
 *  @discussion
    A class for converting JSON to Foundation objects and converting Foundation objects to JSON.

    An object that may be converted to JSON must have the following properties:
    - Top level object is an NSArray or NSDictionary
    - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
    - All dictionary keys are NSStrings
    - NSNumbers are not NaN or infinity
 *  @param jsonString
 *  @return dictionary
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString ;

@end


@interface NSString (YNString)

/*!
 *  a json dictionary to string
 *
 *  @discussion 
    Generate JSON data from a Foundation object. If the object will not produce valid JSON then an exception will be thrown. Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting data is a encoded in UTF-8.
 *  @param json dictionary
 *  @return a json string
 */
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

@end
