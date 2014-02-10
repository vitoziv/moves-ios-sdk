//
//  NSObject+LogProperties.m
//  MovesSDKDemo
//
//  Created by Vito on 2/8/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "NSObject+LogProperties.h"
#import <objc/runtime.h>
#import "MVBaseDataModel.h"

@implementation NSObject (LogProperties)

- (NSString *)logProperties {
    NSMutableString *logString = [NSMutableString string];
    
    [logString appendString:@"\n"];
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            id value = [self valueForKey:name];
            if ([value isKindOfClass:[MVBaseDataModel class]]) {
                [logString appendFormat:@"\n%@: %@", name, [value logProperties]];
            } else if ([value isKindOfClass:[NSArray class]]) {
                for (id obj in value) {
                    [logString appendFormat:@"\n%@: %@", name, [obj logProperties]];
                }
            }
            else {
                [logString appendFormat:@"%@: %@\n", name, [self valueForKey:name]];
            }
        }
        free(propertyArray);
    }
    [logString appendString:@"\n"];
    
    return logString;
}

@end
