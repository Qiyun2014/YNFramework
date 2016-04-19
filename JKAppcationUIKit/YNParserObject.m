//
//  YNParserObject.m
//  YNKit
//
//  Created by qiyun on 15/11/27.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import "YNParserObject.h"
#import "YNKitHeader.h"
#import <libkern/OSAtomic.h>

YNTypeEncodings YNEncodingType(const char *typeEncoding){

    char *type = (char *)typeEncoding;
    if (!type) return YNTypeEncodingsUnkown;
    size_t len = strlen(type);
    if (len == 0) return YNTypeEncodingsUnkown;

    if (strlen(type) <= 0 || !type)  return YNTypeEncodingsUnkown;

    YNTypeEncodings qualifier = 0;
    bool prefix = true;
    while (prefix) {

        switch (*type) {
            case _C_CONST:{
                qualifier |= YNEncodingTypeQualifierConst;
                type++;
            }
                break;

            case 'n':{
                qualifier |= YNEncodingTypeQualifierIn;
                type++;
            }
                break;

            case 'N': {
                qualifier |= YNEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YNEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YNEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YNEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YNEncodingTypeQualifierOneway;
                type++;
            } break;
                
            default:
                prefix = false;
                break;
        }
    }

    switch (*type) {
        case _C_ID:         return YNTypeEncodingsWithId | qualifier;
        case _C_CLASS:      return YNTypeEncodingsWithClass | qualifier;
        case _C_SEL:        return YNTypeEncodingsWithSEL | qualifier;
        case _C_CHR:        return YNTypeEncodingsWithChar | qualifier;
        case _C_UCHR:       return YNTypeEncodingsWithUnsignedChar | qualifier;
        case _C_SHT:        return YNTypeEncodingsWithShort | qualifier;
        case _C_USHT:       return YNTypeEncodingsWithUnsignedShort | qualifier;
        case _C_INT:        return YNTypeEncodingsWithInt | qualifier;
        case _C_UINT:       return YNTypeEncodingsWithUnsignedInt | qualifier;
        case _C_LNG:        return YNTypeEncodingsWithLong | qualifier;
        case _C_ULNG:       return YNTypeEncodingsWithUnsignedLong | qualifier;
        case _C_LNG_LNG:     return YNTypeEncodingsWithLongLong | qualifier;
        case _C_ULNG_LNG:    return YNTypeEncodingsWithUnsignedLongLong | qualifier;
        case _C_FLT:        return YNTypeEncodingsWithFloat | qualifier;
        case _C_DBL:        return YNTypeEncodingsWithDouble | qualifier;
        case _C_BOOL:        return YNTypeEncodingsWithBOOL | qualifier;
        case _C_VOID:        return YNTypeEncodingsWithVoid | qualifier;
        case _C_UNDEF:        return YNTypeEncodingsWithPoint | qualifier;
        case _C_CHARPTR:        return YNTypeEncodingsWithString | qualifier;

        case _C_ARY_B:        return YNTypeEncodingsWithArray | qualifier;
        case _C_ARY_E:        return YNTypeEncodingsWithArray | qualifier;
        case _C_UNION_B:        return YNTypeEncodingsWithUnion | qualifier;
        case _C_UNION_E:        return YNTypeEncodingsWithUnion | qualifier;
        case _C_STRUCT_B:        return YNTypeEncodingsWithStructure | qualifier;
        case _C_STRUCT_E:        return YNTypeEncodingsWithStructure | qualifier;

        default:
            return YNTypeEncodingsUnkown;
            break;
    }


    return YNTypeEncodingsUnkown;
}


@implementation YNParserObject{
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];

    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (instancetype)initWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self initWithClass:cls];
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;

    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            YNClassMethod *info = [[YNClassMethod alloc] initWithMethod:methods[i]];
            if (info.methodName) methodInfos[info.methodName] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            YNClassProperty_attribute *info = [[YNClassProperty_attribute alloc] initWithAttribute:properties[i]];
            if (info.propertyName) propertyInfos[info.propertyName] = info;
        }
        free(properties);
    }

    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            YNClassIvar *info = [[YNClassIvar alloc] initWithIvar:ivars[i]];
            if (info.ivarName) ivarInfos[info.ivarName] = info;
        }
        free(ivars);
    }
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static OSSpinLock lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = OS_SPINLOCK_INIT;
    });
    OSSpinLockLock(&lock);
    YNParserObject *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    OSSpinLockUnlock(&lock);
    if (!info) {
        info = [[YNParserObject alloc] initWithClass:cls];
        if (info) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            OSSpinLockUnlock(&lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end


@implementation YNClassMethod

- (instancetype)initWithMethod:(Method)method{

    if (!method)    return nil;

    self = [super init];

    _method = method;
    _methodDescription = method_getDescription(method);
    const char *name = sel_getName(method_getName(method));
    _methodName = [NSString stringWithUTF8String:name];// 获取方法名
    //_methodName = _methodDescription->name;
    _methodType = [NSString stringWithUTF8String:_methodDescription->types];
    _methodIMP = method_getImplementation(method); // 返回方法的实现
    _methodTypeEncoding = [NSString stringWithUTF8String:method_getTypeEncoding(method)]; // 获取描述方法参数和返回值类型的字符串
    _methodReturnType = [NSString stringWithUTF8String:method_copyReturnType(method)];  //返回参数的类型
    _numberOfArgument = method_getNumberOfArguments(method);    // 返回方法的参数的个数

    if (_numberOfArgument > 0) {

        NSMutableArray *argumentTypes = [NSMutableArray new];

        for (unsigned int i = 0; i < _numberOfArgument; i++) {

            char *argumentType = method_copyArgumentType(method, i);

            if (argumentType) {
                NSString *type = [NSString stringWithUTF8String:argumentType];
                [argumentTypes addObject:type ? type : @""];
                free(argumentType);
            } else  [argumentTypes addObject:@""];
        }
        _argumentTypeEncodings = argumentTypes;
    }
    
    _methodArgumentType = method_copyArgumentType(method, 0);   //默认取第一个

    int cmp_value = strcmp(_methodDescription->types, [_methodType UTF8String]);
    NSAssert(cmp_value, @"字符转换错误!");

    return self;
}

@end


@implementation YNClassProperty_attribute

- (instancetype)initWithAttribute:(objc_property_t)property{

    if (!property)  return nil;

    self = [super init];

    _property = property;
    _propertyName = [NSString stringWithUTF8String:property_getName(property)];

    YNTypeEncodings type = YNTypeEncodingsUnkown;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    _propertyValue = [NSString stringWithUTF8String:attrs[0].value];

    for (int i = 0; i < attrCount; i ++) {

        switch (attrs[i].name[0]) {
            case 'T':
            {
                if (attrs[i].value) {

                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = YNEncodingType(attrs[i].value);
                    if (type & YNTypeEncodingsWithId) {

                        size_t len = strlen(attrs[i].value);
                        if (len > 3) {

                            char name[len - 2];
                            name[len - 3] = '\0';
                            memcpy(name, attrs[i].value + 2, len - 3);
                            _cla = objc_getClass(name);
                        }
                    }
                }
            }
                break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= YNEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= YNEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= YNEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= YNEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= YNEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= YNEncodingTypePropertyWeak;
            } break;
            case 'P': {
                type |= YNEncodingTypePropertyGarbage;
            } break;
            case 'G': {
                type |= YNEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'S': {
                type |= YNEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;

            default:
                break;
        }
    }

    _type = type;
    if (_propertyName.length) {
        if (!_getter) {
            _getter = _propertyName;
        }
        if (!_setter) {
            _setter = [NSString stringWithFormat:@"set%@%@:", [_propertyName substringToIndex:1].uppercaseString, [_propertyName substringFromIndex:1]];
        }
    }
    _propertyAttribute = [NSString stringWithUTF8String:property_getAttributes(property)];

    return self;
}

@end


@implementation YNClassIvar

- (instancetype)initWithIvar:(Ivar)ivar{

    if (!ivar)  return nil;

    self = [super init];

    _ivar = ivar;
    _ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
    _ivarTypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    _ivarOffset = ivar_getOffset(ivar);
    _typeEncoding = YNEncodingType(ivar_getTypeEncoding(ivar));
    NSLog(@"type = %td",_ivarOffset);

    return self;
}

@end


@implementation YNClassCategory

- (instancetype)initWithCategory:(Category)category{

    if (!category)  return nil;

    self = [super init];

    _category = category;
    
    return self;
}

@end

