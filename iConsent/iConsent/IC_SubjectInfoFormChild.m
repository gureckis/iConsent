//
//  IC_SubjectInfoFormChild.m
//  iConsent
//
//  Created by Todd Gureckis on 11/17/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import "IC_SubjectInfoFormChild.h"
#import "SBJsonWriter.h"

@interface IC_SubjectInfoFormChild ()
@property (strong, nonatomic) IBOutlet UIPopoverController *genderPopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *datePopoverController;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIPopoverController *ethnicPopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *languagesPopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *primaryLanguagePopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *numChildrenPopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *birthOrderPopoverController;
@property (strong, nonatomic) NSMutableArray *selectedEthnicities;
@property (strong, nonatomic) NSMutableArray *selectedLanguages;
@property (strong, nonatomic) IBOutlet UILabel *experiment_location;
@property (strong, nonatomic) IBOutlet UILabel *orgname;
@property (strong, nonatomic) IBOutlet UILabel *subjectnumber;

- (IBAction)goToLastName:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)showGenders:(id)sender;
- (void)dateChange:(id)sender;
- (IBAction)showDates:(id)sender;
- (IBAction)showEthnicBackground:(id)sender;
- (IBAction)showPrimaryLangage:(id)sender;
- (IBAction)showLangages:(id)sender;
- (IBAction)showNumberOfChildren:(id)sender;
- (IBAction)showBirthOrder:(id)sender;
- (IBAction)goToGetACopy:(id)sender;
- (NSString *)getArraySummary:(NSMutableArray *)array;
@end

@implementation IC_SubjectInfoFormChild
@synthesize model = _model;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize gender = _gender;
@synthesize birthDate = _birthDate;
@synthesize ethnicBackground = _ethnicBackground;
@synthesize primaryLanguage = _primaryLanguage;
@synthesize languagesAtHome = _languagesAtHome;
@synthesize numberOfSiblings = _numberOfSiblings;
@synthesize birthOrder = _birthOrder;
@synthesize selectedEthnicities = _selectedEthnicities;
@synthesize selectedLanguages = _selectedLanguages;

@synthesize genderPopoverController = _genderPopoverController;
@synthesize datePopoverController = _datePopoverController;
@synthesize datePicker = _datePicker;
@synthesize ethnicPopoverController = _ethnicPopoverController;
@synthesize languagesPopoverController = _languagesPopoverController;
@synthesize primaryLanguagePopoverController = _primaryLanguagePopoverController;
@synthesize numChildrenPopoverController = _numChildrenPopoverController;
@synthesize birthOrderPopoverController = _birthOrderPopoverController;

- (IBAction)goToLastName:(id)sender{
    [self.lastName becomeFirstResponder];
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}


- (IBAction)backgroundTap:(id)sender {
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // set up model
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.model = appDelegate.model;
    self.model.delegate = self;
    
    // load options from the server
    /*
    if ([self.model loadServerInfo]) {
        NSLog(@"couldn't load server");
        // make reservation on server
        //[self.model makeAReservation];
    }
    */
    
    self.experiment_location.adjustsFontSizeToFitWidth = YES;
    self.orgname.adjustsFontSizeToFitWidth = YES;
    self.subjectnumber.adjustsFontSizeToFitWidth = YES;
    
    // check for internet connection
    self.subjectnumber.text = self.model.subjectID;
    self.orgname.text = self.model.organizationName;
    self.experiment_location.text = [[NSString alloc] initWithFormat:@"%@ (%@)", self.model.currentExperiment, self.model.currentLocation];

    
    NSLog(@"view did load");
    self.firstName.adjustsFontSizeToFitWidth = YES;
    self.lastName.adjustsFontSizeToFitWidth = YES;
    self.gender.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.birthDate.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.ethnicBackground.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.ethnicBackground.titleLabel.minimumScaleFactor = 0.5;
    self.primaryLanguage.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.primaryLanguage.titleLabel.minimumScaleFactor = 0.6;
    self.languagesAtHome.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.languagesAtHome.titleLabel.minimumScaleFactor = 0.6;
    self.birthOrder.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.birthOrder.titleLabel.minimumScaleFactor = 0.75;
    
    self.selectedEthnicities = [[NSMutableArray alloc] init];
    self.selectedLanguages = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverController Delegate and Supporting Functions
- (IBAction)showGenders:(id)sender {
    NSLog(@"trying to show genders!");
    [self backgroundTap:sender];
    if(self.genderPopoverController == nil) {
        IC_OptionSelect *genders = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.genderPopoverController = [[UIPopoverController alloc] initWithContentViewController:genders];
        self.genderPopoverController.delegate = self;
        genders.options = self.model.genderOptions;
        genders.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.genderPopoverController.popoverContentSize= CGSizeMake(200, 44*[self.model.genderOptions count]);
    [self.genderPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void) dateChange:(id)sender {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //df.dateStyle = NSDateFormatterShortStyle;
    [df setDateFormat:@"MM/dd/yyyy"];
    
    NSString *newdate = [NSString stringWithFormat:@"%@", [df stringFromDate:self.datePicker.date]];
    NSLog(@"%@",newdate);
    [self.birthDate setTitle:newdate forState:UIControlStateNormal];
    [self.birthDate setTitleColor:[UIColor colorWithRed:166.0f/255.0f green:71.0f/255.0f blue:219.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    //[self.datePopoverController dismissPopoverAnimated: YES];
}


- (IBAction)showDates:(id)sender {
    NSLog(@"trying to show date picker!");
    
    [self backgroundTap:sender];
    if(self.datePopoverController == nil) {
        // first get view controller
        UIViewController *popoverContent = [[UIViewController alloc] init];
        UIView *popoverView = [[UIView alloc] init];
        popoverView.backgroundColor = [UIColor blackColor];
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,-2, 325, 300)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        //dates.hidden = NO;
        self.datePicker.date = [NSDate date];
        // can add action here for when the date changes
        [self.datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
        [popoverView addSubview:self.datePicker];
        popoverContent.view = popoverView;
        
        self.datePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.datePopoverController.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.datePopoverController.popoverContentSize= CGSizeMake(325, 215);
    [self.datePopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (IBAction)showEthnicBackground:(id)sender {
    NSLog(@"trying to show race-ethnic options!");
    [self backgroundTap:sender];
    if(self.ethnicPopoverController == nil) {
        IC_MultiOptionSelect *ethnicities = [[IC_MultiOptionSelect alloc] initWithNibName:@"IC_MultiOptionSelect" bundle:[NSBundle mainBundle]];
        self.ethnicPopoverController = [[UIPopoverController alloc] initWithContentViewController:ethnicities];
        self.ethnicPopoverController.delegate = self;
        ethnicities.options = self.model.ethnicOptions;
        ethnicities.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.ethnicPopoverController.popoverContentSize= CGSizeMake(500, 44*[self.model.ethnicOptions count]);
    [self.ethnicPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showPrimaryLangage:(id)sender {
    NSLog(@"trying to show  primary langauges!");
    [self backgroundTap:sender];
    if(self.primaryLanguagePopoverController == nil) {
        IC_OptionSelect *languages = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.primaryLanguagePopoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
        self.primaryLanguagePopoverController.delegate = self;
        languages.options = self.model.languageOptions;
        languages.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.primaryLanguagePopoverController.popoverContentSize= CGSizeMake(250, 44*[self.model.languageOptions count]);
    [self.primaryLanguagePopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showLangages:(id)sender {
    NSLog(@"trying to show language options!");
    [self backgroundTap:sender];
    if(self.languagesPopoverController == nil) {
        IC_MultiOptionSelect *languages = [[IC_MultiOptionSelect alloc] initWithNibName:@"IC_MultiOptionSelect" bundle:[NSBundle mainBundle]];
        self.languagesPopoverController= [[UIPopoverController alloc] initWithContentViewController:languages];
        self.languagesPopoverController.delegate = self;
        languages.options = self.model.languageOptions;
        languages.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.languagesPopoverController.popoverContentSize= CGSizeMake(300, 44*[self.model.languageOptions count]);
    [self.languagesPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showNumberOfChildren:(id)sender {
    NSLog(@"trying to show number of children");
    [self backgroundTap:sender];
    if(self.numChildrenPopoverController == nil) {
        IC_OptionSelect *siblings = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.numChildrenPopoverController = [[UIPopoverController alloc] initWithContentViewController:siblings];
        self.numChildrenPopoverController.delegate = self;
        siblings.options = self.model.siblingOptions;
        siblings.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.numChildrenPopoverController.popoverContentSize= CGSizeMake(250, 44*[self.model.siblingOptions count]);
    [self.numChildrenPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (IBAction)showBirthOrder:(id)sender {
    NSLog(@"trying to show birth order");
    [self backgroundTap:sender];
    if(self.birthOrderPopoverController == nil) {
        IC_OptionSelect *birthorder = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.birthOrderPopoverController= [[UIPopoverController alloc] initWithContentViewController:birthorder];
        self.birthOrderPopoverController.delegate = self;
        birthorder.options = self.model.birthorderOptions;
        birthorder.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.birthOrderPopoverController.popoverContentSize= CGSizeMake(250, 44*[self.model.birthorderOptions count]);
    [self.birthOrderPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (NSString *)computeJSONSummary {
    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  self.firstName.text, @"firstname",
                                  self.lastName.text,@"lastname",
                                  self.gender.titleLabel.text, @"gender",
                                  self.birthDate.titleLabel.text, @"birthdate",
                                  self.ethnicBackground.titleLabel.text, @"race-ethnic",
                                  self.primaryLanguage.titleLabel.text, @"primary-language",
                                  self.languagesAtHome.titleLabel.text, @"language-at-home",
                                  self.numberOfSiblings.titleLabel.text, @"num-siblings",
                                  self.birthOrder.titleLabel.text, @"birth-order",
                                  nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonSummary = [jsonWriter stringWithObject:myDictionary];
    NSLog(@"%@", jsonSummary);
    return jsonSummary;
}

- (IBAction)goToGetACopy:(id)sender {
    // first check if all the fields are ok.
    NSString *jsonSummary = [self computeJSONSummary];
    if ([self.model submitParticipantInfo:jsonSummary]) {
        // return to control to main controller
        IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.viewController getParticipantInfoIsFinished];
    }
}

- (NSString *)getArraySummary:(NSMutableArray *)array {
    NSMutableString *shortVersion = [[NSMutableString alloc] init];
    if ([array count]==0) {
        [shortVersion appendString:@"************"];
    } else {
        for (int i=0; i<[array count]; i++) {
            [shortVersion appendString:[array objectAtIndex:i]];
            if (i < [array count]-1) {
                [shortVersion appendString:@", "];
            }
        }
    }
    NSLog(@"%@", shortVersion);
    return shortVersion;
}

- (void)addOption:(id)optionPicked from:(IC_MultiOptionSelect *)picker {
    if (picker == self.ethnicPopoverController.contentViewController) {
        [self.selectedEthnicities addObject:(NSString *)optionPicked];
        [self.ethnicBackground setTitle:[self getArraySummary:self.selectedEthnicities] forState:UIControlStateNormal];
        if ([self.ethnicBackground.titleLabel.text isEqualToString:@"************"]) {
            [self.ethnicBackground setTitleColor:[UIColor colorWithWhite:0.760 alpha:1.000] forState:UIControlStateNormal];
            
        } else {
            [self.ethnicBackground setTitleColor:[UIColor colorWithRed:208.0f/255.0f green:219.0f/255.0f blue:41.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }
        NSLog(@"%@", self.selectedEthnicities);
    } else {
        [self.selectedLanguages addObject:(NSString *)optionPicked];
        [self.languagesAtHome setTitle:[self getArraySummary:self.selectedLanguages] forState:UIControlStateNormal];
        if ([self.languagesAtHome.titleLabel.text isEqualToString:@"************"]) {
            [self.languagesAtHome setTitleColor:[UIColor colorWithWhite:0.760 alpha:1.000] forState:UIControlStateNormal];
            
        } else {
            [self.languagesAtHome setTitleColor:[UIColor colorWithRed:0.634 green:0.459 blue:0.760 alpha:1.000] forState:UIControlStateNormal];
        }

        NSLog(@"%@", self.selectedLanguages);
    }
}

- (void)deleteOption:(id)optionPicked from:(IC_MultiOptionSelect *)picker {
    if (picker == self.ethnicPopoverController.contentViewController) {
        [self.selectedEthnicities removeObject:(NSString *)optionPicked];
        [self.ethnicBackground setTitle:[self getArraySummary:self.selectedEthnicities] forState:UIControlStateNormal];
        if ([self.ethnicBackground.titleLabel.text isEqualToString:@"************"]) {
            [self.ethnicBackground setTitleColor:[UIColor colorWithWhite:0.760 alpha:1.000] forState:UIControlStateNormal];
            
        } else {
            [self.ethnicBackground setTitleColor:[UIColor colorWithRed:208.0f/255.0f green:219.0f/255.0f blue:41.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }
        NSLog(@"%@", self.selectedEthnicities);
    } else {
        [self.selectedLanguages removeObject:(NSString *)optionPicked];
        [self.languagesAtHome setTitle:[self getArraySummary:self.selectedLanguages] forState:UIControlStateNormal];
        if ([self.languagesAtHome.titleLabel.text isEqualToString:@"************"]) {
            [self.languagesAtHome setTitleColor:[UIColor colorWithWhite:0.760 alpha:1.000] forState:UIControlStateNormal];
            
        } else {
            [self.languagesAtHome setTitleColor:[UIColor colorWithRed:0.634 green:0.459 blue:0.760 alpha:1.000] forState:UIControlStateNormal];
        }
        NSLog(@"%@", self.selectedLanguages);
    }
}

- (void)updateOption:(id)optionPicked
{
    NSLog(@"called the delegate!");
    if ([self.model.genderOptions containsObject:optionPicked]) {
        [self.gender setTitle:optionPicked forState:UIControlStateNormal];
        [self.gender setTitleColor:[UIColor colorWithRed:208.0f/255.0f green:219.0f/255.0f blue:41.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.genderPopoverController dismissPopoverAnimated: YES];
    } else if ([self.model.ethnicOptions containsObject:optionPicked]) {
        [self.ethnicBackground setTitle:optionPicked forState:UIControlStateNormal];
        [self.ethnicBackground setTitleColor:[UIColor colorWithRed:219.0f/255.0f green:74.0f/255.0f blue:59.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.ethnicPopoverController dismissPopoverAnimated: YES];
    } else if ([self.model.languageOptions containsObject:optionPicked]) {
        [self.primaryLanguage setTitle:optionPicked forState:UIControlStateNormal];
        [self.primaryLanguage setTitleColor:[UIColor colorWithRed:0.223 green:0.754 blue:0.095 alpha:1.000] forState:UIControlStateNormal];
        [self.primaryLanguagePopoverController dismissPopoverAnimated: YES];
    } else if ([self.model.siblingOptions containsObject:optionPicked]) {
        [self.numberOfSiblings setTitle:optionPicked forState:UIControlStateNormal];
        [self.numberOfSiblings setTitleColor:[UIColor colorWithRed:219.0f/255.0f green:74.0f/255.0f blue:59.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.numChildrenPopoverController dismissPopoverAnimated: YES];
    } else if ([self.model.birthorderOptions containsObject:optionPicked]) {
        [self.birthOrder setTitle:optionPicked forState:UIControlStateNormal];
        [self.birthOrder setTitleColor:[UIColor colorWithRed:0.329 green:0.597 blue:0.884 alpha:1.000] forState:UIControlStateNormal];
        [self.birthOrderPopoverController dismissPopoverAnimated: YES];
    }
    // dismiss popover
}


//---called when the user clicks outside the popover view---
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover about to be dismissed");
    return YES;
}

//---called when the popover view is dismissed---
- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {    
    NSLog(@"popover dismissed");
}

#pragma mark - IC_ModelDelegate Functions


@end
