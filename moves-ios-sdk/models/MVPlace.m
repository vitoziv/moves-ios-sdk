//
//  MVPlace.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVPlace.h"
#import "MVJsonValueParser.h"

@implementation MVPlace

- (MVPlace *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"id"]) {
            _placeId = [MVJsonValueParser stringValueFromObject:dic[@"id"]];
        }
        if (dic[@"name"]) {
            _name = [MVJsonValueParser stringValueFromObject:dic[@"name"]];
        }
        if (dic[@"type"]) {
            _type = [MVJsonValueParser stringValueFromObject:dic[@"type"]];
        }
        if (dic[@"foursquareId"]) {
            _foursquareId = [MVJsonValueParser stringValueFromObject:dic[@"foursquareId"]];
        }
        if (dic[@"location"]) {
            _location = [[MVLocation alloc] initWithDictionary:dic[@"location"]];
        }
    }
    
    return self;
}

@end
