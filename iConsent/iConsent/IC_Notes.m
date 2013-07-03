//
//  IC_Notes.m
//  iConsent
//
//  Created by Todd Gureckis on 6/5/13.
//  Copyright (c) 2013 Todd Gureckis. All rights reserved.
//

#import "IC_Notes.h"
#import "SBJsonWriter.h"

@interface IC_Notes ()


- (IBAction)textFieldDoneEditing:(id)sender;
- (void)backgroundTap;
- (IBAction)goToExperiment:(id)sender;

@end


@implementation IC_Notes

CGRect keyboardBounds;


- (NSString *)computeJSONSummary {
    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  self.notes.text, @"notes",
                                  nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonSummary = [jsonWriter stringWithObject:myDictionary];
    NSLog(@"%@", jsonSummary);
    return jsonSummary;
}


- (IBAction)goToExperiment:(id)sender {
    NSString *jsonSummary = [self computeJSONSummary];
    if ([self.model updateNotes:jsonSummary]) {
        NSLog(@"%@",jsonSummary);
        // return to control to main controller
        IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.viewController doNotesIsFinished];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self scrollViewToCenterOfScreen:textField];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollViewToCenterOfScreen:textView];
}


- (void)scrollViewToCenterOfScreen:(UIView *)theView {
    CGFloat viewCenterY = theView.center.y;
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat availableHeight = applicationFrame.size.height - keyboardBounds.size.height;    // Remove area covered by keyboard
    
    CGFloat y = viewCenterY - availableHeight / 2.0;
    if (y < 0) {
        y = 0;
    }
    self.scrollView.contentSize = CGSizeMake(applicationFrame.size.width, applicationFrame.size.height + keyboardBounds.size.height);
    [self.scrollView setContentOffset:CGPointMake(0, y) animated:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)backgroundTap {
    [self.notes resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)gotSwipeUp:(id)sender {
    if (self.state != VISIBLE) {
        self.state = VISIBLE;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
            self.notesSubview.frame = CGRectMake(35, 30, 698, 1001);
        } completion:^(BOOL finished) {
            [self.view setUserInteractionEnabled:YES];
        }];
    }
}

- (IBAction)gotSwipeDown:(id)sender {
    NSLog(@"got swipe down");
    if (self.state != HIDDEN) {
        self.state = HIDDEN;
        [self.notes resignFirstResponder];
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
            self.notesSubview.frame = CGRectMake(35, 967, 698, 1001);
        } completion:^(BOOL finished) {
            [self.view setUserInteractionEnabled:YES];
        }];
    }
    
}

- (void)keyboardNotification:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    [keyboardBoundsValue getValue:&keyboardBounds];
    // see http://stackoverflow.com/questions/2807339/uikeyboardboundsuserinfokey-is-deprecated-what-to-use-instead
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUInteger resizeMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // Do any additional setup after loading the view from its nib.
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.model = appDelegate.model;

    self.orgname.adjustsFontSizeToFitWidth = YES;
    self.subjectnumber.adjustsFontSizeToFitWidth = YES;

    // get organization name
    self.orgname.text = self.model.organizationName;
    //reserve subject id
    self.subjectnumber.text = self.model.subjectID;

    // add gesture recognizer for swipe up
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotSwipeUp:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUpGesture];

    // add gesture recognizer for swipe down
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotSwipeDown:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGesture];


    self.notesSubview.autoresizesSubviews = YES;
    self.notesSubview.autoresizingMask = resizeMask;
    [self.view addSubview:self.notesSubview];
    self.notesSubview.frame = CGRectMake(35, 948, 698, 1001);
    self.state = HIDDEN;
    
    [self.notes setDelegate:self];
    [self.notes setNeedsDisplay];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(backgroundTap)];
    
    [self.scrollView addGestureRecognizer:tap];
    [self.scrollView setNeedsDisplay];
    // get text summary of subject info from model
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
