//
//  UIActionButtonViewDelegate.h
//  consoleme
//
//  Created by Neil Loknath on 12-05-10.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIActionButtonViewDelegate <NSObject>

-(void)didTapHistoryButton:(UIButton*)button;
-(void)didTapRefreshButton:(UIButton*)button;
-(void)didTapEmailButton:(UIButton *)button;

@end
