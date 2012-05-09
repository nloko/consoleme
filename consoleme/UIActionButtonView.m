//
//  UIActionButtonView.m
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import "UIActionButtonView.h"

@implementation UIActionButtonView
    
#pragma mark
#pragma mark UIView Overrides

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* result = [super hitTest:point withEvent:event];
    if (result) return result;
    
    // Return hits for subviews outside of the superview bounds
    //
    for (UIView* subview in [self.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [self convertPoint:point toView:subview];
        result = [subview hitTest:convertedPoint withEvent:event];
        if (result) return result;
    }
    
    return nil;
}

@end
