//
//  IC_Notes.h
//  iConsent
//
//  Created by Todd Gureckis on 6/5/13.
//  Copyright (c) 2013 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_Model.h"
#import "IC_AppDelegate.h"
#import "IC_FormViewController.h"

#define HIDDEN 0
#define VISIBLE 1

@interface IC_Notes : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IC_Model *model;
@property (strong, nonatomic) IBOutlet UILabel *orgname;
@property (strong, nonatomic) IBOutlet UILabel *subjectnumber;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UITextView *summary;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UIButton *experiment;
@property (strong, nonatomic) IBOutlet UIButton *location;
@property (strong, nonatomic) IBOutlet UIView *notesSubview;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property BOOL state;

- (IBAction)goToExperiment:(id)sender;
@end
