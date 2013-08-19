//
//  MVUser.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVUser.h"

@implementation MVUser

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVUser *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.userId = [dic[@"userId"] stringValue];
    self.firstDate = dic[@"profile"][@"firstDate"];
    self.caloriesAvailable = (BOOL)dic[@"profile"][@"caloriesAvailable"];
    self.currentTimeZoneId = dic[@"profile"][@"currentTimeZone"][@"id"];
    self.currentTimeZoneOffset = [(NSNumber *)dic[@"profile"][@"currentTimeZone"][@"offset"] intValue];
    
    return self;
}

@end
