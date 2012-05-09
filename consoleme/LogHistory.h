//
//  LogHistory.h
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kLogNameKey;
extern NSString * const kLogKey;

@interface LogHistory : NSObject {
 @private
    NSMutableArray* _logs;
}

-(void)addLog:(NSArray*)log withName:(NSString*)name;
-(NSDictionary*)logEntryAtIndex:(int)index;
-(int)count;

@end
