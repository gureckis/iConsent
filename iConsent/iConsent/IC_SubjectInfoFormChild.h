//
//  IC_SubjectInfoFormChild.h
//  iConsent
//
//  Created by Todd Gureckis on 11/17/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_FormViewController.h"
#import "IC_Model.h"
#import "IC_AppDelegate.h"
#import "IC_OptionSelect.h"
#import "IC_MultiOptionSelect.h"
#import "IC_Model.h"

@interface IC_SubjectInfoFormChild : UIViewController <UIPopoverControllerDelegate, IC_ModelDelegate, IC_OptionSelectDelegate, IC_MultiOptionSelectDelegate>

@property (strong, nonatomic) IC_Model *model;
@property (strong, nonatomic) IBOutlet UITextField *firstName;
@property (strong, nonatomic) IBOutlet UITextField *lastName;
@property (strong, nonatomic) IBOutlet UIButton *gender;
@property (strong, nonatomic) IBOutlet UIButton *birthDate;
@property (strong, nonatomic) IBOutlet UIButton *ethnicBackground;

@property (strong, nonatomic) IBOutlet UIButton *primaryLanguage;
@property (strong, nonatomic) IBOutlet UIButton *languagesAtHome;

@property (strong, nonatomic) IBOutlet UIButton *numberOfSiblings;
@property (strong, nonatomic) IBOutlet UIButton *birthOrder;

@end
