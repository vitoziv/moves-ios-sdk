//
//  MVBaseDataModel.h
//  MovesSDKDemo
//
//  Created by Vito on 11/22/13.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

#define isNull(o) (!o || (NSNull *)o == [NSNull null])
#import "MVCalendarFactory.h"

@interface MVBaseDataModel : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
