//
//  IC_ConsentForm.h
//  iConsent
//
//  Created by Todd Gureckis on 3/12/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_AppDelegate.h"
#import "IC_Model.h"

#import "T1Autograph.h"
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "DCRoundSwitch.h"


@interface IC_ConsentForm : UIViewController <T1AutographDelegate, UIAlertViewDelegate, UIWebViewDelegate>
@property (strong, nonatomic) IC_Model *model;

@property (strong, nonatomic) IBOutlet UILabel *orgname;
@property (strong, nonatomic) IBOutlet UILabel *subjectnumber;
@property (strong, nonatomic) IBOutlet UILabel *experiment_location;

@property (strong, nonatomic) IBOutlet UIWebView *consentView;

@property (strong, nonatomic) IBOutlet UIView *interactionSubview;
@property (strong, nonatomic) IBOutlet UIImageView *signatureBox;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *yesNoSwitch;

@property (strong, nonatomic) UIView *autographView;
@property (strong, nonatomic) IBOutlet UILabel *signatureLabel;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) T1Autograph *autograph;
@property (strong, nonatomic) UIImageView *outputImage;


- (IBAction)goToSubjInfo:(id)sender;
- (IBAction)yesNoToggled:(id)sender;
- (IBAction)clearSignature:(id)sender;
@end

