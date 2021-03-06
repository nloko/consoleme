//
//  ConsoleMeViewController.m
//
//  Created by Neil Loknath on 12-03-13.
//  Copyright (c) 2012 Neil Loknath <neil.loknath@gmail.com>. All rights reserved.
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

#import <QuartzCore/QuartzCore.h>

static const int kButtonHeight = 40;

@interface ConsoleMeViewController ()

-(void)toggleButtons;
-(void)hideButtons;
-(void)showLoading;
-(void)hideLoading;
-(void)setLogViewText:(NSString*)text;
-(void)sizeLogView;
-(void)updateLog;
-(void)processLog:(NSArray*)log;
-(NSString *)timestampForLogEntry;

-(void)didTapLog:(UITapGestureRecognizer*)recognizer;

-(NSString*)email;
-(void)displayComposerSheet;

-(void)willEnterForeground:(NSNotification*)notification;

@end

static const int kMaxMinutes = 120;  // default to 2 hours
static const int kMaxLines = INT32_MAX;   

@implementation ConsoleMeViewController

-(void)dealloc {
    [_logHistory release];
    [super dealloc];
}

#pragma mark
#pragma mark UIViewController Overrides

-(void)loadView {    
    if (!_logHistory) {
        _logHistory = [[LogHistory alloc] init];
        [_logHistory loadPersistedLog];
    }
    
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
        
    _logView= [[UITextView alloc] initWithFrame:CGRectMake(0, 
                                                           0, 
                                                           frame.size.width, 
                                                           frame.size.height)];
    _logView.backgroundColor = [UIColor blackColor];
    _logView.textColor = [UIColor lightGrayColor];
    _logView.editable = NO;
    
    _logView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleHeight;
    
    _logView.font = [UIFont fontWithName:@"Courier" size:12];
    _logView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                             action:@selector(didTapLog:)];
    [_logView addGestureRecognizer:tapper];
    [tapper release];
    
    [self.view addSubview:_logView];
    [_logView release];
    
    [self updateLog];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(willEnterForeground:) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
}

-(void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _logView = nil;
    _loadingView = nil;
    _buttons = nil;
    _historyView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                               duration:(NSTimeInterval)duration {
    _buttons.alpha = 0;

    [UIView animateWithDuration:duration animations:^(void) {
        _logView.alpha = 0; 
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {    
    [_buttons adjustButtonImages];
    
    [UIView animateWithDuration:0.25 animations:^(void) {
        _logView.alpha = 1; 
        _buttons.alpha = 1;
    }];
}

#pragma mark
#pragma mark Application Observers

-(void)willEnterForeground:(NSNotification *)notification {
    [self hideButtons];
    [self updateLog];
}

#pragma mark
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toggleButtons];
    [self processLog:[[_logHistory logEntryAtIndex:indexPath.row] objectForKey:kLogKey]];
}

#pragma mark 
#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_logHistory count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell 
                                        forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kCellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:kCellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"ArialRoundedMT" size:12];
    }
    
    NSDictionary* item = [_logHistory logEntryAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:kLogNameKey];
    
    return cell;
}

#pragma mark
#pragma mark Gestures

-(void)didTapLog:(UITapGestureRecognizer *)recognizer {
    [self toggleButtons];
}

#pragma mark
#pragma mark Buttons

-(void)toggleButtons {
    if (_buttons) {
        [self hideButtons];
        return;
    }
    
    [self showButtons];
}

-(void)showButtons {
    _buttons = [[UIActionButtonView alloc] initWithFrame:CGRectMake(0, 
                                                        -kButtonHeight, 
                                                        self.view.bounds.size.width, 
                                                        kButtonHeight)];
    
    _buttons.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _buttons.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _buttons.autoresizesSubviews = YES;
    _buttons.delegate = self;
    
    [self.view addSubview:_buttons];
    [_buttons release];
    
    [self.view bringSubviewToFront:_buttons];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect frame = _buttons.frame;
        frame.origin.y = 0;
        _buttons.frame = frame;
    }];
}

-(void)hideButtons {
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect buttonframe = _buttons.frame;
        buttonframe.origin.y = -buttonframe.size.height;
        _buttons.frame = buttonframe;
        
        CGRect historyframe = _historyView.frame;
        historyframe.origin.y = -historyframe.size.height;
        _historyView.frame = historyframe;
        _historyView.alpha = 0;
    } completion:^(BOOL finished) {
        [_buttons removeFromSuperview];
        _buttons = nil;
        _historyView = nil;
    }]; 
}

-(void)didTapHistoryButton:(UIButton*)button {
    if (_historyView) return;
    
    const CGFloat rowHeight = 40;
    const CGFloat height = MIN(rowHeight * [_logHistory count], self.view.bounds.size.height / 2);
    _historyView = [[UITableView alloc] initWithFrame:CGRectMake(0, 
                                                                 kButtonHeight, 
                                                                 self.view.bounds.size.width / 2, 
                                                                 height) 
                                                style:UITableViewStylePlain];
    
    _historyView.delegate = self;
    _historyView.dataSource = self;
    _historyView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _historyView.separatorColor = [UIColor clearColor];
    _historyView.rowHeight = rowHeight;
    _historyView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _historyView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [_buttons addSubview:_historyView];
    [_buttons bringSubviewToFront:_historyView];
    [_historyView release];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        _historyView.transform = CGAffineTransformIdentity;
    }];
}

-(void)didTapRefreshButton:(UIButton*)button {
    [self toggleButtons];
    [self updateLog];
}

-(void)didTapEmailButton:(UIButton *)button {
    [self toggleButtons];
    [self displayComposerSheet];
}

#pragma mark
#pragma mark Log

-(NSString *)timestampForLogEntry {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(void)updateLog {
    [self showLoading];

    [[[NLOSyslog syslog] 
      filterSecondsFromNow:60 * kMaxMinutes] 
     sendFormattedLogToBlock:^(NSArray* log) {
         [_logHistory addLog:log withName:[self timestampForLogEntry]];
         [self processLog:log];
     }];    
}

-(void)processLog:(NSArray *)log {
    NSMutableString* logString = [[NSMutableString alloc] init];
    
    const int numberOfEntries = [log count];
    int start = MAX(0, numberOfEntries - kMaxLines);
    
    for (int i = start; i < numberOfEntries; i++) {
        id entry = [log objectAtIndex:i];
        [logString appendString:entry];
        [logString appendString:@"\r\n"];
    }
    
    NSLog(@"Processed %i messages", numberOfEntries - start);
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
    [UIView animateWithDuration:0.2 animations:^(void) {
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
    
    NSArray *toRecipients = [NSArray arrayWithObjects:[self email],
                             nil];
    
    [picker setToRecipients:toRecipients];
    
    NSData *logData = [_logView.text dataUsingEncoding:NSUTF8StringEncoding];
    [picker addAttachmentData:logData mimeType:@"text/plain"
                     fileName:@"log"];
    
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
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
