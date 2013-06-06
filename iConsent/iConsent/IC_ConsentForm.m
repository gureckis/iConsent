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
-(void)loadConsent;
- (void)emailConsent;
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
        self.model.consent = YES;
        // change the size of the consentView to mini size
        self.consentView.alpha = 0.2;
        self.orgname.alpha = 0.2;
        self.subjectnumber.alpha = 0.2;
        self.experiment_location.alpha = 0.2;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
            self.interactionSubview.frame = CGRectMake(81, 300, 625, 450);
        } completion:^(BOOL finished) {
            [self.consentView setUserInteractionEnabled:NO];
        }];
        
    } else {
        self.model.consent = NO;
        // change the size of the consentView to full size
        self.consentView.alpha = 1.0;
        self.orgname.alpha = 1.0;
        self.subjectnumber.alpha = 1.0;
        self.experiment_location.alpha = 1.0;
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
    self.model.delegate = self;

    self.experiment_location.adjustsFontSizeToFitWidth = YES;
    self.orgname.adjustsFontSizeToFitWidth = YES;
    self.subjectnumber.adjustsFontSizeToFitWidth = YES;
    
    // check for internet connection
    self.subjectnumber.text = self.model.subjectID;
    self.orgname.text = self.model.organizationName;
    self.experiment_location.text = [[NSString alloc] initWithFormat:@"%@ (%@)", self.model.currentExperiment, self.model.currentLocation];
    
    // load yes/no switch
    self.yesNoSwitch.onText = @"YES";
    self.yesNoSwitch.offText = @"NO";
    [self.yesNoSwitch addTarget:self action:@selector(yesNoToggled:) forControlEvents:UIControlEventValueChanged];
    self.yesNoSwitch.on = NO;

    self.emailSubview.autoresizesSubviews = YES;
    self.emailSubview.autoresizingMask = resizeMask;
    [self.view addSubview:self.emailSubview];
    self.emailSubview.frame = CGRectMake(1024+625, 300, 625, 450);


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
    self.signedComplete = NO;
        
    
}


- (void)viewDidUnload
{
    [self setConsentView:nil];
    [self setSignatureBox:nil];
    [self setSignatureLabel:nil];
    [self setClearButton:nil];
    [self setNextButton:nil];
    [self setYesNoSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation==UIInterfaceOrientationPortrait;

}

- (IBAction)getEmail:(id)sender {
    // first check if all the fields are ok.
    [self.autograph done:self];
    [self.autograph reset:self];
    if(self.yesNoSwitch.on && self.signedComplete) {
        // tell model to update database
        // upload signature and provide consesnt
        // check for internet connection
        if ([self.model provideConsentWithSignature:self.signatureImage]) {
            [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
                self.interactionSubview.frame = CGRectMake(-625, 300, 625, 450);
                self.emailSubview.frame = CGRectMake(81, 300, 625, 450);
            } completion:^(BOOL finished) {
                [self.interactionSubview setUserInteractionEnabled:NO];
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, you must agree and sign your name before we move further!" delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles: nil];
        [alert show];
    }
    
}



- (void)emailConsent {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSString *subject = [[NSString alloc] initWithFormat:@"[%@]: Informed consent from experiment today at %@", [self.model getOrganizationName], [self.model getCurrentLocation], nil];
        [mailer setSubject:subject];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:self.model.emailAddress, nil];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = [self.consentView
                               stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        [mailer setMessageBody:emailBody isHTML:YES];
        
        mailer.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                            message:@"Your device doesn't support email!"
                                            delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }
    // email data here
    // when button is pressed pop-up email modal view pre-populated with model datafile stuff.
    // set email address to the one by default.
    
}


- (IBAction)goToSubjInfo:(id)sender {
    // via http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
    // first check if all the fields are ok.
    NSLog(@"%@",self.emailAddress.text);
    if(self.emailAddress.text == nil || [self.emailAddress.text isEqualToString: @""] || [self.emailAddress.text isEqualToString: @"*********************"]) {
        // return to control to main controller
        IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.viewController getConsentIsFinished];
    } else {
        if([self.model isValidEmail:self.emailAddress.text]) {
            NSLog(@"got a valid email");
            self.model.emailAddress = self.emailAddress.text;
            [self emailConsent];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, the provided email address appears invalid.  Please double check." delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles: nil];
            [alert show];
        }

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, was unable to load the consent form.  Either the device has lost Internet connection or the server you are trying to contact is down." delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: @"Quit", nil];
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

#pragma mark - IC_ModelDelegate Functions

#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, was unable send email.  Please check that this device is able to send and receive email, re-enter your address, and try again." delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles: nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            // empty email field
            [self.emailAddress setText:nil];
            self.model.emailAddress = nil;
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            // return to control to main controller
            [appDelegate.viewController getConsentIsFinished];
            break;
        case MFMailComposeResultSent:
            // wait until the message send to move on.
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            // return to control to main controller
            [appDelegate.viewController getConsentIsFinished];
            break;
        case MFMailComposeResultFailed:
            [alert show];
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
