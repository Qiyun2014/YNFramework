//
//  YNModel.m
//  YNKit
//
//  Created by qiyun on 15/11/27.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNModel.h"
#import <objc/runtime.h>
#define force_inline __inline__ __attribute__((always_inline))  //强制内联

@implementation YNModel:NSObject

static force_inline YNObject_Type YNDistinguishFromClass(Class cls){

    if ([cls isKindOfClass:[NSString class]])           return YNObject_TypeClassNSString;
    if ([cls isKindOfClass:[NSMutableString class]])    return YNObject_TypeClassNSMutableString;
    if ([cls isKindOfClass:[NSArray class]])            return YNObject_TypeClassNSArray;
    if ([cls isKindOfClass:[NSMutableArray class]])     return YNObject_TypeClassNSMutableArray;
    if ([cls isKindOfClass:[NSDictionary class]])       return YNObject_TypeClassNSDictionary;
    if ([cls isKindOfClass:[NSMutableDictionary class]]) return YNObject_TypeClassNSMutableDictionary;
    if ([cls isKindOfClass:[NSData class]])             return YNObject_TypeClassNSData;
    if ([cls isKindOfClass:[NSMutableData class]])      return YNObject_TypeClassNSMutableData;
    if ([cls isKindOfClass:[NSSet class]])              return YNObject_TypeClassNSSet;
    if ([cls isKindOfClass:[NSMutableSet class]])       return YNObject_TypeClassNSMutableSet;

    return YNObject_TypeClassUnknown;
}


NSString * YNIsNullString(NSString *aString){

    if (!aString || aString == (id)kCFNull) return nil;

    aString = [NSString stringWithFormat:@"%@",aString];

    NSDictionary *dict = @{@"null":@true,
                           @"NULL":@true,
                           @"<null>":@true,
                           @"<NULL>":@true,
                           @"<nULL>":@true,
                           @"<Null>":@true,
                           @"NUll":@true,
                           @"Null":@true,
                           @"<nuLL":@true,
                           @"nUll":@true,
                           @"<nuLL>":@true,
                           @"(null)":@true,
                           @"(NULL)":@true};
    if (dict[aString])  aString = @"";

    return aString;
}

- (void)setEncodingType:(YNObject_Type)encodingType{

    self.encodingType = encodingType;

    if (self.encodingType == YNObject_TypeClassUnknown) [YNModel initWithObject:nil withClassName:nil];
}




+ (NSDictionary *)dictionaryWithModel:(id)model {
    if (model == nil) {
        return nil;
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    // 获取类名/根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);

    // 获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);

    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];

        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }

        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}


+ (NSArray *)propertiesInModel:(id)model {
    if (model == nil) {
        return nil;
    }

    NSMutableArray *propertiesArray = [[NSMutableArray alloc] init];

    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);

    for (int i = 0; i < count; i++) {
        // 取得属性名
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        [propertiesArray addObject:propertyName];
    }

    return [propertiesArray copy];
}

/*!
 *  @discussion 	document literature
 *  <http://www.ecma-international.org/publications/files/ecma-st/ECMA-262.pdf>.
 *  @param object a json object
 *  @param className model classname
 */

+ (instancetype)initWithObject:(id)object withClassName:(NSString *)className{

    if (YNDistinguishFromClass(object) == YNObject_TypeClassUnknown)    return nil;
    else if (YNDistinguishFromClass(object) == YNObject_TypeClassNSString)   object = [NSDictionary dictionaryWithJsonString:object];
    else if (YNDistinguishFromClass(object) == YNObject_TypeClassNSData){

     id  jsonData = [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingMutableContainers
                                          error:nil];
        [YNModel initWithObject:jsonData withClassName:className];
        return nil;
    }
    else if(![object isKindOfClass:[NSDictionary class]])   object = [YNModel dictionaryWithModel:object];
    else   NSAssert1(object, @"model can't is nil", @"model不可以传入一个空的对象！");

    if (!object || object == (id)kCFNull) return nil;

    id model = [[NSClassFromString(className) alloc] init];
    id classObject = objc_getClass([className UTF8String]);

    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    Ivar *ivars = class_copyIvarList(classObject, nil);

    for (int i = 0; i < count; i ++) {

        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
        const char *type = ivar_getTypeEncoding(ivars[i]);

        //NSString *dataType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        //NSLog(@"ivarName : %@, ivarTypeEncoding : %@",ivarName,dataType);

        YNTypeEncodings ivarType = YNEncodingType(type);

        for (int j = 0; j < count; j ++) {

            objc_property_t property = properties[j];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            NSRange range = [ivarName rangeOfString:propertyName];

            if (range.location == NSNotFound)   continue;
            else{

                id propertyValue = [object objectForKey:propertyName];

                switch (ivarType) {
                    case YNTypeEncodingsWithBOOL:{
                        propertyValue = [NSNumber numberWithBool:[[NSString stringWithFormat:@"%@",propertyValue] boolValue]];
                    }
                        break;

                    case YNTypeEncodingsWithChar:{
                        propertyValue = [NSNumber numberWithChar:(char)propertyValue];
                    }
                        break;

                    case YNTypeEncodingsWithFloat:{
                        propertyValue = [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@",propertyValue] floatValue]];
                    }
                        break;

                    case YNTypeEncodingsWithUnsignedLongLong:{
                        propertyValue = [NSNumber numberWithLongLong:[[NSString stringWithFormat:@"%@",propertyValue] longLongValue]];
                    }
                        break;

                    case YNTypeEncodingsWithId:{
                        propertyValue = (id)propertyValue;
                    }
                        break;

                    default:
                        break;
                }

                [model setValue:YNIsNullString(propertyValue) forKey:ivarName];
            }
        }
    }

    return model;
}


+ (instancetype)initWithObject:(id)object withClass:(Class)cls{

    NSString *className = NSStringFromClass([cls class]);
    return [YNModel initWithObject:object withClassName:className];
}


@end



@implementation NSDictionary (YNDictionary)

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {

    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end



@implementation NSString (YNString)

+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    if (!dic)
        return nil;

    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end