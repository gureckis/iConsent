//
//  IC_ConsentForm.m
//  iConsent
//
//  Created by Todd Gureckis on 3/12/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import "IC_ConsentForm.h"

@interface IC_ConsentForm()
@property (strong, nonatomic) UIImage *signatureImage;
@property BOOL signedComplete;
-(BOOL)connected;
-(void)loadConsent;
@end

@implementation IC_ConsentForm
@synthesize model = _model;
@synthesize orgname = _orgname;
@synthesize subjectnumber = _subjectnumber;
@synthesize experiment_location = _experiment_location;

@synthesize consentView = _consentView;
@synthesize interactionSubview = _interactionSubview;

@synthesize signatureBox = _signatureBox;
@synthesize yesNoSwitch = _yesNoSwitch;
@synthesize autographView = _autographView;
@synthesize signatureLabel = _signatureLabel;
@synthesize clearButton = _clearButton;
@synthesize nextButton = _nextButton;

@synthesize autograph = _autograph;
@synthesize outputImage = _outputImage;
@synthesize signatureImage = _signatureImage;
@synthesize signedComplete = _signedComplete;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)yesNoToggled:(id)sender
{
    NSLog(@"toggling yes/no");
    if(self.yesNoSwitch.on == YES) {
        // change the size of the consentView to mini size
        self.consentView.alpha = 0.3;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
            self.interactionSubview.frame = CGRectMake(81, 300, 625, 450);
        } completion:^(BOOL finished) {
            
            [self.consentView setUserInteractionEnabled:NO];
        }];
        
    } else {
        // change the size of the consentView to full size
        self.consentView.alpha = 1.0;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
            self.interactionSubview.frame = CGRectMake(81, 904, 625, 450);
        } completion:^(BOOL finished) {
            [self.consentView setUserInteractionEnabled:YES];
        }];
    }
}

- (IBAction)clearSignature:(id)sender {
    [self.autograph reset:self];
}

- (BOOL)connected 
{
    /*Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
     */
    return TRUE;
}

- (void)loadConsent {
    NSURL *url = [NSURL URLWithString:[self.model getConsentURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.consentView loadRequest: request];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUInteger resizeMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // set up model
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.model = appDelegate.model;
    
    self.experiment_location.adjustsFontSizeToFitWidth = YES;
    self.orgname.adjustsFontSizeToFitWidth = YES;

    // check for internet connection
    if(![self.model connected]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, this application requires a working Internet connection!  Please check your network settings and relaunch the app." delegate:nil cancelButtonTitle:@"Quit" otherButtonTitles: nil];
        [alert setDelegate:self];
        [alert show];
    } else {
        self.subjectnumber.text = [self.model getSubjectNumber];
        self.orgname.text = [self.model getOrganizationName];
        self.experiment_location.text = [[NSString alloc] initWithFormat:@"%@ (%@)", [self.model getCurrentExperiment],[self.model getCurrentLocation]];
        //self.experiment_location.text = [self.model getCurrentExperiment];

    }
    
    // load yes/no switch
    self.yesNoSwitch.onText = @"YES";
    self.yesNoSwitch.offText = @"NO";
    [self.yesNoSwitch addTarget:self action:@selector(yesNoToggled:) forControlEvents:UIControlEventValueChanged];
    self.yesNoSwitch.on = NO;

    self.interactionSubview.autoresizesSubviews = YES;
    self.interactionSubview.autoresizingMask = resizeMask;
    [self.view addSubview:self.interactionSubview];
    self.interactionSubview.frame = CGRectMake(81, 904, 625, 450);
    // Do any additional setup after loading the view from its nib.
    // first load URL with consent form
    [self.consentView setDelegate:self];
    [self loadConsent];
    
    // next, place autograph capture view ontop of the current signature field
	// Make a view for the signature
	self.autographView = [[UIView alloc] initWithFrame:self.signatureBox.frame];
	//autographView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	//autographView.layer.borderWidth = 0;
	//autographView.layer.cornerRadius = 10;
	[self.autographView setBackgroundColor:[UIColor clearColor]];
	[self.interactionSubview addSubview:self.autographView];
	
	// Initialize Autograph library
	self.autograph = [T1Autograph autographWithView:self.autographView delegate:self];
	
	// to remove the watermark, get a license code from Ten One, and enter it here	
	//[autograph setLicenseCode:@"4fabb271f7d93f07346bd02cec7a1ebe10ab7bec"];
	
	
	// **Optional Configuration**
	
	// show signature guideline.  Default is YES
	[self.autograph setShowGuideline:NO];
	
	// set export size.  Default scale is 0.5
	//	[autograph setExportScale:.8];
	
	// set export color.  Default is blackColor
	[self.autograph setStrokeColor:[UIColor whiteColor]];
	
	// set stroke width.  Default is 3
	//	[autograph setStrokeWidth:6];
	
	// set amount of stroke width reduction from velocity.  Default is 0.85
	//	[autograph setVelocityReduction:0.5];
	
	// show current date.  Default is NO
	[self.autograph setShowDate:NO];
	
	// show unique signature identifier.  Default is NO
	[self.autograph setShowHash:NO];
    
	
	// customize signature identifier.  Default is nil.  Use no more than 10 characters.
	//	[autograph setCustomHash:@"DocumentID"];
	
	// enable 3-finger swipe to undo.  Default is YES
	//	[autograph setSwipeToUndoEnabled:NO];

    // hide the stuff by default
    /*
    self.signatureBox.hidden = YES;
    self.autographView.hidden = YES;
    self.signatureLabel.hidden = YES;
    self.clearButton.hidden = YES;
    self.nextButton.hidden = YES;
    */
    
    self.signedComplete = NO;
    
    // check for internet connection
    if(![self connected]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rectangle Game" message:@"Sorry, this application requires a working Internet connection!  Please check your settings and try again." delegate:nil cancelButtonTitle:@"Quit" otherButtonTitles: nil];
        [alert setDelegate:self];
        
    }
    
    
}


- (void)viewDidUnload
{
    [self setConsentView:nil];
    [self setSignatureBox:nil];
    [self setSignatureLabel:nil];
    [self setClearButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation==UIInterfaceOrientationPortrait;

}


- (IBAction)goToSubjInfo:(id)sender {
    // first check if all the fields are ok.
    [self.autograph done:self];
    [self.autograph reset:self];
    if(self.yesNoSwitch.on && self.signedComplete) {
        // check for internet connection
        if(![self connected]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rectangle Game" message:@"Sorry, this application requires a working Internet connection!  Please check your network settings and relaunch the app." delegate:nil cancelButtonTitle:@"Quit" otherButtonTitles: nil];
            [alert setDelegate:self];
        } else {
            //reserve subject id
            //[self.model reserveSubjIDWithSignature:self.signatureImage];
            // go to next form
            //RGSubjectInfo *vs = [[RGSubjectInfo alloc] initWithNibName:@"RGSubjectInfo" bundle:nil];
            //RGAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            //[appDelegate.transitionController transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
        }
        
    } else {
        // go on
        NSLog(@"error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rectangle Game" message:@"Sorry, you must agree and sign your name before we start!" delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles: nil];
        [alert show];        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Quit"]) {
        exit(0);
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Try again"]) {
        [self loadConsent];
    }
}

- (void)webView:(UIWebView *) webView didFailLoadWithError:(NSError *)error 
{ 
    NSLog(@"DID FAIL");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rectangle Game" message:@"Sorry, this experiment requires a working Internet connection!  Check your internet connection and that the server is working." delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: @"Quit", nil];
    [alert setDelegate:self];
    [alert show];        

}


-(void)autographDidCompleteWithNoData {
	NSLog(@"User pressed the done button without signing");
    self.signedComplete = NO;
}

-(void)autograph:(T1Autograph *)autograph didCompleteWithSignature:(T1Signature *)signature {
	
	// Log information about the signature
	NSLog(@"Autograph signature completed.");
    self.signedComplete = YES;
	// you can access the raw image data like this:
	self.signatureImage = [UIImage imageWithData:signature.imageData];
    
    UIGraphicsBeginImageContext(self.signatureImage.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [self.signatureImage drawInRect:CGRectMake(0, 0, self.signatureImage.size.width, self.signatureImage.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor blackColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.signatureImage.size.width, self.signatureImage.size.height));
    self.signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
}

@end
