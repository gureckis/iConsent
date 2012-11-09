//
//  IC_StudyInfoForm.h
//  iConsent
//
//  Created by Todd Gureckis on 11/8/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_Model.h"
#import "IC_OptionSelect.h"
#import "IC_AppDelegate.h"
#import "IC_FormViewController.h"

@interface IC_StudyInfoForm : UIViewController <UIPopoverControllerDelegate, IC_OptionSelectDelegate>

@property (strong, nonatomic) IC_Model *model;
@property (strong, nonatomic) IBOutlet UILabel *subjectnumber;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIButton *experiment;
@property (strong, nonatomic) IBOutlet UIButton *location;
@property (strong, nonatomic) IBOutlet UIButton *next;

- (IBAction)showExperiments:(id)sender;
- (IBAction)showLocations:(id)sender;
//- (IBAction)backgroundTap:(id)sender;
- (IBAction)nextForm:(id)sender;
@end
