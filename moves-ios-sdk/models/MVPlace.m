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
    
    if (dic[@"id"]) {
        self.placeId = dic[@"id"];
    }
    if (dic[@"name"]) {
        self.name = dic[@"name"];
    }
    if (dic[@"type"]) {
        self.type = dic[@"type"];
    }
    if (dic[@"foursquareId"]) {
        self.foursquareId = dic[@"foursquareId"];
    }
    if (dic[@"location"]) {
        self.location = [[MVLocation alloc] initWithDictionary:dic[@"location"]];
    }
    
    return self;
}

@end
