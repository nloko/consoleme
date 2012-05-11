//
//  UIActionButtonView.m
//  consoleme
//
//  Created by Neil Loknath on 12-03-31.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
//

#import "UIActionButtonView.h"
#import "UIActionButtonViewDelegate.h"

@interface UIActionButtonView()

-(CGFloat)buttonWidth;
-(UIButton*)addActionButtonWithFrame:(CGRect)frame;
-(void)setImageInsetsForButton:(UIButton*)button;
-(void)showButtons;
-(void)showRefreshButton;
-(void)showEmailButton;
-(void)showHistoryButton;
-(void)didTapEmailButton:(UIButton*)button;
-(void)didTapRefreshButton:(UIButton*)button;
-(void)didTapHistoryButton:(UIButton*)button;

@end

@implementation UIActionButtonView
    
@synthesize delegate = _delegate;

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self showButtons];
    }
    
    return self;
}

#pragma mark
#pragma mark Buttons

-(void)setImageInsetsForButton:(UIButton *)button {
    CGFloat hmargin = button.bounds.size.height * 0.1;
    CGFloat vmargin = (button.bounds.size.width - button.bounds.size.height * 0.8) / 2;
    button.imageEdgeInsets = UIEdgeInsetsMake(hmargin,vmargin,hmargin,vmargin);
}

-(CGFloat)buttonWidth {
    return self.bounds.size.width / 3;
}

-(void)showButtons {
    [self showEmailButton];
    [self showRefreshButton];
    [self showHistoryButton];    
}

-(UIButton *)addActionButtonWithFrame:(CGRect)frame {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.backgroundColor = [UIColor clearColor];
    button.showsTouchWhenHighlighted = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:18];
    button.frame = frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
    UIViewAutoresizingFlexibleRightMargin | 
    UIViewAutoresizingFlexibleLeftMargin;
    
    
    [self addSubview:button];
    
    return button;
}

-(void)showHistoryButton {
    UIButton* history = [self addActionButtonWithFrame:CGRectMake(1, 
                                                                  0, 
                                                                  [self buttonWidth] - 2, 
                                                                  self.bounds.size.height)];
    
    UIImage* icon = [UIImage imageNamed:@"history_icon"];
    [history setImage:icon forState:UIControlStateNormal];
    [self setImageInsetsForButton:history];
    
    [history addTarget:self action:@selector(didTapHistoryButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showEmailButton {
    const CGFloat width = [self buttonWidth];
    UIButton* email = [self addActionButtonWithFrame:CGRectMake(width + 1,
                                                                0, 
                                                                width - 2, 
                                                                self.bounds.size.height)];
    
    UIImage* icon = [UIImage imageNamed:@"email_icon"];
    [email setImage:icon forState:UIControlStateNormal];
    [self setImageInsetsForButton:email];
    
    [email addTarget:self action:@selector(didTapEmailButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showRefreshButton {
    const CGFloat width = [self buttonWidth];
    UIButton* refresh = [self addActionButtonWithFrame:CGRectMake(width * 2 + 1, 
                                                                  0, 
                                                                  width - 2, 
                                                                  self.bounds.size.height)];
    
    UIImage* icon = [UIImage imageNamed:@"refresh_icon"];
    [refresh setImage:icon forState:UIControlStateNormal];
    [self setImageInsetsForButton:refresh];
    
    [refresh addTarget:self action:@selector(didTapRefreshButton:) forControlEvents:UIControlEventTouchUpInside];    
}

-(void)adjustButtonImages {
    for (id button in self.subviews) {
        if (![button isKindOfClass:[UIButton class]]) continue;
        [self setImageInsetsForButton:button];
    }
}

-(void)didTapEmailButton:(UIButton*)button {
    [self.delegate didTapEmailButton:button];
}

-(void)didTapRefreshButton:(UIButton*)button {
    [self.delegate didTapRefreshButton:button];
}

-(void)didTapHistoryButton:(UIButton*)button {
    [self.delegate didTapHistoryButton:button];
}

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
