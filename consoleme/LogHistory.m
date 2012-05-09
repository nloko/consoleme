//
//  LogHistory.m
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import "LogHistory.h"

NSString * const kLogNameKey = @"LogNameKey";
NSString * const kLogKey = @"LogKey";

NSString * const kPersistKey = @"LogHistoryPersistKey";

const int kMaxEntries = 3;

@interface LogHistory()

-(void)persist;
-(void)load;

@end

@implementation LogHistory

-(id)init {
    if ((self = [super init])) {
        // TODO do something better with this, as it may not be a great idea to load the logs
        // in init if they're big
        //
        [self load];
        if (!_logs) {
            _logs = [[NSMutableArray alloc] initWithCapacity:3];
        }
    }
    
    return self;
}

-(void)dealloc {
    [_logs release];
    [super dealloc];
}

-(void)load {
    NSArray* logs = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistKey];
    if (!logs) return;
    
    _logs = [[NSMutableArray alloc] initWithArray:logs];
}

-(void)persist {
    // Quick and easy disk storage
    //
    [[NSUserDefaults standardUserDefaults] setValue:_logs forKey:kPersistKey];
}

-(void)addLog:(NSArray *)log withName:(NSString *)name {
    if ([_logs count] == 3) {
        [_logs removeObjectAtIndex:0];
    }
    
    NSMutableDictionary* entry = [NSMutableDictionary dictionary];
    [entry setObject:name forKey:kLogNameKey];
    [entry setObject:log forKey:kLogKey];
    
    [_logs addObject:entry];
    [self persist];
}

-(NSDictionary *)logEntryAtIndex:(int)index {
    return [_logs objectAtIndex:index];
}

-(int)count {
    return [_logs count];
}

@end
