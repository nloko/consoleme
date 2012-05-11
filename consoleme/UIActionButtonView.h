//
//  UIActionButtonView.h
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIActionButtonViewDelegate;

@interface UIActionButtonView : UIView {
 @private
    id<UIActionButtonViewDelegate> _delegate;
}

-(void)adjustButtonImages;

@property (nonatomic, assign) id<UIActionButtonViewDelegate> delegate;

@end
