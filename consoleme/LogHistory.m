//
//  LogHistory.m
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath. All rights reserved.
//

#import "LogHistory.h"

NSString * const kLogNameKey = @"LogNameKey";
NSString * const kLogKey = @"LogKey";

const int kMaxEntries = 3;

@implementation LogHistory

-(id)init {
    if ((self = [super init])) {
        _logs = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

-(void)dealloc {
    [_logs release];
    [super dealloc];
}

-(void)addLog:(NSArray *)log withName:(NSString *)name {
    if ([_logs count] == 3) {
        [_logs removeObjectAtIndex:0];
    }
    
    NSMutableDictionary* entry = [NSMutableDictionary dictionary];
    [entry setObject:name forKey:kLogNameKey];
    [entry setObject:log forKey:kLogKey];
    
    [_logs addObject:entry];
}

-(NSDictionary *)logEntryAtIndex:(int)index {
    return [_logs objectAtIndex:index];
}

-(int)count {
    return [_logs count];
}

@end
