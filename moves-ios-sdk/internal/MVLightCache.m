//
//  MVLightCache.m
//  MovesSDKDemo
//
//  Created by Vito on 5/19/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVLightCache.h"

@interface MVLightCache()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation MVLightCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static id instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSCache *)cache
{
    if (!_cache) {
        _cache = [[NSCache alloc] init];
    }
    
    return _cache;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self.cache setObject:object forKey:key];
}

- (id)objectForKey:(id)key
{
    return [self.cache objectForKey:key];
}

@end
