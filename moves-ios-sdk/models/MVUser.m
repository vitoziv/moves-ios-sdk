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
    
    if (dic[@"userId"]) {
        self.userId = [dic[@"userId"] stringValue];
    }
    if (dic[@"profile"]) {
        if (dic[@"profile"][@"firstDate"]) {
            self.firstDate = dic[@"profile"][@"firstDate"];
        }
        if (dic[@"profile"][@"caloriesAvailable"]) {
            self.caloriesAvailable = (BOOL)dic[@"profile"][@"caloriesAvailable"];
        }
        if (dic[@"profile"][@"currentTimeZone"]) {
            if (dic[@"profile"][@"currentTimeZone"][@"id"]) {
                self.currentTimeZoneId = dic[@"profile"][@"currentTimeZone"][@"id"];
            }
            if (dic[@"profile"][@"currentTimeZone"][@"offset"]) {
                self.currentTimeZoneOffset = [(NSNumber *)dic[@"profile"][@"currentTimeZone"][@"offset"] intValue];
            }
        }
    }
    
    return self;
}

@end
