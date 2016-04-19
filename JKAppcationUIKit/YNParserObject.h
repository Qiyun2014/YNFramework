//
//  YNParserObject.h
//  YNKit
//
//  Created by qiyun on 15/11/27.
//  Copyright © 2015年 com.application.qiyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//all object have include class struct
/*
 class:
 typedef struct objc_method *Method;
 typedef struct objc_ivar *Ivar;
 typedef struct objc_category *Category;
 typedef struct objc_property *objc_property_t;
 */

/*!
 *  The table below lists the type codes. Note that many of them overlap with the codes you use when encoding an object for purposes of archiving or distribution. However, there are codes listed here that you can’t use when writing a coder, and there are codes that you may want to use when writing a coder that aren’t generated by @encode(). (See the NSCoder class specification in the Foundation Framework reference for more information on encoding objects for archiving or distribution.)
 */
typedef NS_ENUM(NSInteger,YNTypeEncodings) {

    //An unknown type (among other things, this code is used for function pointers)
    YNTypeEncodingsUnkown               = 0,
    /*!
     *  A char
     */
    YNTypeEncodingsWithChar,
    /*!
     *  An int
     */
    YNTypeEncodingsWithInt,
    /*!
     *  A short
     */
    YNTypeEncodingsWithShort,
    /*!
     *   l is treated as a 32-bit quantity on 64-bit programs.
     */
    YNTypeEncodingsWithLong,
    /*!
     *  A long long
     */
    YNTypeEncodingsWithLongLong,
    /*!
     *  An unsigned char
     */
    YNTypeEncodingsWithUnsignedChar,
    /*!
     *  An unsigned int
     */
    YNTypeEncodingsWithUnsignedInt,
    /*!
     *  An unsigned short
     */
    YNTypeEncodingsWithUnsignedShort,
    /*!
     *  An unsigned long
     */
    YNTypeEncodingsWithUnsignedLong,
    /*!
     *  An unsigned long long
     */
    YNTypeEncodingsWithUnsignedLongLong,
    /*!
     *  A float
     */
    YNTypeEncodingsWithFloat,
    /*!
     *  A double
     */
    YNTypeEncodingsWithDouble,


    
    /*!
     *  A C++ bool or a C99 _Bool
     */
    YNTypeEncodingsWithBOOL,
    /*!
     *  A void
     */
    YNTypeEncodingsWithVoid,
    /*!
     *  A character string (char *)
     */
    YNTypeEncodingsWithString,
    /*!
     *  An object (whether statically typed or typed id)
     */
    YNTypeEncodingsWithId,
    /*!
     *  A class object (Class)
     */
    YNTypeEncodingsWithClass,
    /*!
     *  A method selector (SEL)
     */
    YNTypeEncodingsWithSEL,
    /*!
     *  An array
     */
    YNTypeEncodingsWithArray,
    /*!
     *  A structure
     */
    YNTypeEncodingsWithStructure,
    /*!
     *  A union
     */
    YNTypeEncodingsWithUnion,
    /*!
     *  A bit field of num bits
     */
    YNTypeEncodingsWithBit,
    /*!
     *  A pointer to type
     */
    YNTypeEncodingsWithPoint,


    YNEncodingTypeQualifierMask   = 0xFE0,  ///< mask of qualifier
    YNEncodingTypeQualifierConst  = 1 << 5, ///< const
    YNEncodingTypeQualifierIn     = 1 << 6, ///< in
    YNEncodingTypeQualifierInout  = 1 << 7, ///< inout
    YNEncodingTypeQualifierOut    = 1 << 8, ///< out
    YNEncodingTypeQualifierBycopy = 1 << 9, ///< bycopy
    YNEncodingTypeQualifierByref  = 1 << 10, ///< byref
    YNEncodingTypeQualifierOneway = 1 << 11, ///< oneway


    YNEncodingTypePropertyMask         = 0x1FF000, ///< mask of property
    YNEncodingTypePropertyReadonly     = 1 << 12, ///< readonly
    YNEncodingTypePropertyCopy         = 1 << 13, ///< copy
    YNEncodingTypePropertyRetain       = 1 << 14, ///< retain
    YNEncodingTypePropertyNonatomic    = 1 << 15, ///< nonatomic
    YNEncodingTypePropertyWeak         = 1 << 16, ///< weak
    YNEncodingTypePropertyCustomGetter = 1 << 17, ///< getter=
    YNEncodingTypePropertyCustomSetter = 1 << 18, ///< setter=
    YNEncodingTypePropertyDynamic      = 1 << 19, ///< @dynamic
    YNEncodingTypePropertyGarbage      = 1 << 20,
};

YNTypeEncodings YNEncodingType(const char *typeEncoding);


@interface YNParserObject : NSObject


@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) Class superCls;
@property (nonatomic, assign, readonly) Class metaCls;
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) YNParserObject *superClassInfo;

@property (nonatomic, strong, readonly) NSDictionary *ivarInfos;     ///< key:NSString(ivar),     value:YYClassIvarInfo
@property (nonatomic, strong, readonly) NSDictionary *methodInfos;   ///< key:NSString(selector), value:YYClassMethodInfo
@property (nonatomic, strong, readonly) NSDictionary *propertyInfos; ///< key:NSString(property), value:YYClassPropertyInfo

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.

 After called this method, you may call 'classInfoWithClass' or
 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 Get the class info of a specified Class.

 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.

 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.

 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.

 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (instancetype)classInfoWithClassName:(NSString *)className;

@end


/*
 Defines a method
    struct objc_method_description {
        SEL name;                   The name of the method
        char *types;                The types of the method arguments
    };
*/

@interface YNClassMethod : NSObject

@property (nonatomic,readonly) Method   method;
@property (nonatomic,readonly,copy) NSString  *methodName;             //The name of the method
@property (nonatomic,readonly,copy) NSString *methodType;   //The types of the method arguments
@property (nonatomic,readonly) struct objc_method_description *methodDescription;    //Returns by reference a string describing a single parameter type of a method.
@property (nonatomic,readonly) IMP  methodIMP;
@property (nonatomic,readonly,copy) NSString *methodTypeEncoding;   //A C string. The string may be \c NULL.
@property (nonatomic,readonly,copy) NSString *methodReturnType;
@property (nonatomic,readonly) unsigned int numberOfArgument;   //An integer containing the number of arguments accepted by the given method.
@property (nonatomic,readonly) char *methodArgumentType;
@property (nonatomic, strong, readonly) NSArray *argumentTypeEncodings; ///< array of arguments' type

- (instancetype)initWithMethod:(Method)method;

@end

/*!
 *  Defines a property attribute

    typedef struct {
        const char *name;           < The name of the attribute
        const char *value;          < The value of the attribute (usually empty)
    } objc_property_attribute_t;
 */

@interface YNClassProperty_attribute : NSObject

@property (nonatomic,readonly) objc_property_t  property;
@property (nonatomic,readonly,copy) NSString *propertyName;    //The property of the name
@property (nonatomic,readonly,copy) NSString *propertyValue;   //The property of the value
@property (nonatomic,readonly,copy) NSString *propertyAttribute; //the attribute string of a property
@property (nonatomic,readonly) YNTypeEncodings  type;
@property (nonatomic,readonly,copy) NSString *typeEncoding;
@property (nonatomic,readonly,copy) NSString *ivarName;
@property (nonatomic,readonly) Class    cla;
@property (nonatomic,readonly,copy) NSString *getter;
@property (nonatomic,readonly,copy) NSString *setter;

- (instancetype)initWithAttribute:(objc_property_t)property;

@end




@interface YNClassIvar : NSObject

@property (nonatomic,readonly) Ivar ivar;   /// An opaque type that represents an instance variable.

@property (nonatomic,readonly,copy) NSString    *ivarName;
@property (nonatomic,readonly,copy) NSString    *ivarTypeEncoding;
@property (nonatomic,readonly) ptrdiff_t    ivarOffset;
@property (nonatomic,readonly) YNTypeEncodings  typeEncoding;

- (instancetype)initWithIvar:(Ivar)ivar;

@end



@interface YNClassCategory : NSObject

@property (nonatomic,readonly) Category     category;   /// An opaque type that represents a category.

- (instancetype)initWithCategory:(Category)category;

@end
