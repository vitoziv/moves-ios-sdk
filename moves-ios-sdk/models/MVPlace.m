//
//  MVPlace.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVPlace.h"

@implementation MVPlace

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (MVPlace *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.placeId = dic[@"id"];
    self.name = dic[@"name"];
    self.type = dic[@"type"];
    self.foursquareId = dic[@"foursquareId"];
    self.location = [[MVLocation alloc] initWithDictionary:dic[@"location"]];
    
    return self;
}

@end
