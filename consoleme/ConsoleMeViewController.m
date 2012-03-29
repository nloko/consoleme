//
//  ConsoleMeViewController.m
//
//  Created by Neil Loknath on 12-03-13.
//  Copyright (c) 2012 Neil Loknath. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ConsoleMeViewController.h"
#import "NLOSyslog.h"

@interface ConsoleMeViewController ()

-(NSString*)email;

-(void)showLoading;
-(void)hideLoading;
-(void)setLogViewText:(NSString*)text;
-(void)sizeLogView;
-(void)updateLog;
-(void)processLog:(NSArray*)log;

-(void)didTapLog:(UITapGestureRecognizer*)recognizer;

-(void)toggleButtons;
-(UIButton*)addActionButtonWithFrame:(CGRect)frame;

-(void)didTapEmailButton:(UIButton*)button;
-(void)showEmailButton;
-(void)hideEmailButton;
-(void)toggleEmailButton;

-(void)didTapRefreshButton:(UIButton*)button;
-(void)showRefreshButton;
-(void)hideRefreshButton;
-(void)toggleRefreshButton;

-(void)displayComposerSheet;

@end

static const int kMaxMinutes = 30;  // default to 30 min
static const int kMaxLines = 125;

@implementation ConsoleMeViewController

#pragma mark
#pragma mark UIViewController Overrides

-(void)loadView {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];

    UIView* baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor blackColor];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleHeight | 
        UIViewAutoresizingFlexibleBottomMargin | 
        UIViewAutoresizingFlexibleTopMargin | 
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
    
    self.view = baseView;
    [baseView release];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _contentView.contentSize = frame.size;
    _contentView.backgroundColor = [UIColor blackColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleHeight | 
        UIViewAutoresizingFlexibleBottomMargin | 
        UIViewAutoresizingFlexibleTopMargin | 
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
    
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.autoresizesSubviews = YES;

    [self.view addSubview:_contentView];
    [_contentView release];
        
    _logView= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _logView.backgroundColor = [UIColor blackColor];
    _logView.textColor = [UIColor lightGrayColor];
    _logView.lineBreakMode = UILineBreakModeWordWrap;
    _logView.numberOfLines = 0;
    _logView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _logView.font = [UIFont fontWithName:@"Courier" size:12];
    _logView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLog:)];
    [_logView addGestureRecognizer:tapper];
    [tapper release];
    
    [_contentView addSubview:_logView];
    [_logView release];
    
    [self updateLog];
}

-(void)viewDidUnload {
    _contentView = nil;
    _logView = nil;
    _loadingView = nil;
    _email = nil;
    _refresh = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^(void) {
        _logView.alpha = 0; 
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self sizeLogView];
    [UIView animateWithDuration:0.25 animations:^(void) {
        _logView.alpha = 1; 
    }];
}

#pragma mark
#pragma mark Gestures

-(void)didTapLog:(UITapGestureRecognizer *)recognizer {
    [self toggleButtons];
}

#pragma mark
#pragma mark Buttons

-(void)toggleButtons {
    [self toggleEmailButton];
    [self toggleRefreshButton]; 
}

-(void)toggleEmailButton {
    if (_email) {
        [self hideEmailButton];
        return;
    }
    
    [self showEmailButton];
}

-(void)toggleRefreshButton {
    if (_refresh) {
        [self hideRefreshButton];
        return;
    }
    
    [self showRefreshButton];
}

-(UIButton *)addActionButtonWithFrame:(CGRect)frame {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    button.showsTouchWhenHighlighted = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Courier-Bold" size:18];
    button.frame = frame;
    
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect frame = button.frame;
        frame.origin.y = 0;
        button.frame = frame;
    }];
    
    return button;
}

-(void)didTapRefreshButton:(UIButton*)button {
    [self toggleButtons];
    [self updateLog];
}

-(void)showRefreshButton {
    float width = self.view.bounds.size.width / 2;
    _refresh = [self addActionButtonWithFrame:CGRectMake(width + 1, -40, width - 1, 40)];
    _refresh.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [_refresh setTitle:@"Refresh" forState:UIControlStateNormal];
    [_refresh addTarget:self action:@selector(didTapRefreshButton:) forControlEvents:UIControlEventTouchUpInside];    
}

-(void)hideRefreshButton {
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect frame = _refresh.frame;
        frame.origin.y = -frame.size.height;
        _refresh.frame = frame;
    } completion:^(BOOL finished) {
        [_refresh removeFromSuperview];
        _refresh = nil;
    }];
}

-(void)didTapEmailButton:(UIButton *)button {
    [self toggleButtons];
    [self displayComposerSheet];
}

-(void)showEmailButton {
    _email = [self addActionButtonWithFrame:CGRectMake(0, -40, self.view.bounds.size.width / 2 - 1, 40)];
    
    _email.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [_email setTitle:@"Email" forState:UIControlStateNormal];
    [_email addTarget:self action:@selector(didTapEmailButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)hideEmailButton {
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect frame = _email.frame;
        frame.origin.y = -frame.size.height;
        _email.frame = frame;
    } completion:^(BOOL finished) {
        [_email removeFromSuperview];
        _email = nil;
    }];
}

#pragma mark
#pragma mark Log

-(void)updateLog {
    [self showLoading];

    [[[NLOSyslog syslog] 
      filterSecondsFromNow:60 * kMaxMinutes] 
     sendFormattedLogToBlock:^(NSArray* log) {
         [self processLog:log];
     }];    
}

-(void)processLog:(NSArray *)log {
    NSMutableString* logString = [[NSMutableString alloc] init];
    
    int lines = 0;
    
    for (id entry in log) {
        [logString appendString:entry];
        [logString appendString:@"\r\n"];
        lines++;
        
        // Simulator goes bonkers if we add too many lines to the view
        //
        if (lines == kMaxLines) break;
    }
    
    NSLog(@"Processed %i messages", [log count]);
    
    [self setLogViewText:logString];
    [self hideLoading];
    
    [logString release];
}

-(void)setLogViewText:(NSString *)text {
    _logView.text = text;
    [self sizeLogView];
}

-(void)sizeLogView {
    [_logView sizeToFit];
    CGRect frame = _logView.frame;
    frame.size.width = self.view.bounds.size.width;
    _logView.frame = frame;
    
    _contentView.contentSize = _logView.bounds.size;
}

-(void)showLoading {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
            UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin | 
            UIViewAutoresizingFlexibleBottomMargin;
    }
    
	_loadingView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    _loadingView.alpha = 0;
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
    [_loadingView startAnimating];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        _loadingView.alpha = 1;
        _logView.alpha = 0;
    }];
}

-(void)hideLoading {
    [UIView animateWithDuration:0.15 animations:^(void) {
        _loadingView.alpha = 0;
        _logView.alpha = 1;
    } completion:^(BOOL finished) {
        [_loadingView removeFromSuperview];
        _loadingView =  nil; 
    }];
}

#pragma mark
#pragma mark Email

-(NSString *)email {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NLOEMail"];
}

-(void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];    
    [picker setSubject:[NSString stringWithFormat:@"E-mail from %@", appName]];
    
    // Set up the recipients.
    NSArray *toRecipients = [NSArray arrayWithObjects:[self email],
                             nil];
    
    [picker setToRecipients:toRecipients];
    
    NSData *myData = [_logView.text dataUsingEncoding:NSUTF8StringEncoding];
    [picker addAttachmentData:myData mimeType:@"text/plain"
                     fileName:@"log"];
    
    // Fill out the email body text.
    NSString *emailBody = @"Please see attached for a snapshot of the system log from my device.\r\n \
    \r\n \
    Here's some more info: \r\n \
    Device Name: %@ \r\n \
    Device Model: %@ \r\n \
    System Name: %@ \r\n \
    System Version: %@ \r\n \
    ";
    
    [picker setMessageBody:[NSString stringWithFormat:emailBody, 
                            [[UIDevice currentDevice] name],
                            [[UIDevice currentDevice] model],
                            [[UIDevice currentDevice] systemName], 
                            [[UIDevice currentDevice] systemVersion]]
                                               isHTML:NO];
    
    // Present the mail composition interface.
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
