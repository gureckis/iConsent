//
//  IC_StudyInfoForm.m
//  iConsent
//
//  Created by Todd Gureckis on 11/8/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import "IC_StudyInfoForm.h"

@interface IC_StudyInfoForm ()
@property (strong, nonatomic) IBOutlet UIPopoverController *experimentPopoverController;
@property (strong, nonatomic) IBOutlet UIPopoverController *locationPopoverController;
@property (strong, nonatomic) NSArray *experimentOptions;
@property (strong, nonatomic) NSArray *locationOptions;
@end

@implementation IC_StudyInfoForm
@synthesize model = _model;
@synthesize subjectnumber = _subjectnumber;
@synthesize date = _date;
@synthesize time = _time;
@synthesize experiment = _experiment;
@synthesize location = _location;
@synthesize experimentPopoverController = _experimentPopoverController;
@synthesize locationPopoverController = _locationPopoverController;
@synthesize experimentOptions = _experimentOptions;
@synthesize locationOptions = _locationOptions;

#pragma mark - Interaction Elements

- (IBAction)nextForm:(id)sender {
    if(![self.experiment.titleLabel.text isEqualToString:@"********************"] &&
       ![self.location.titleLabel.text isEqualToString:@"********************"]
       ) {
        // return to experiment
        IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.viewController getStudyInfoIsFinished];
    } else {
        // go on
        NSLog(@"error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:@"Sorry, some necessary information is missing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }

}

- (IBAction)showExperiments:(id)sender {
    NSLog(@"trying to show experiments!");
    if(self.experimentPopoverController == nil) {
        IC_OptionSelect *experiments = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.experimentPopoverController = [[UIPopoverController alloc] initWithContentViewController:experiments];
        self.experimentPopoverController.delegate = self;
        experiments.options = self.experimentOptions;
        experiments.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.experimentPopoverController.popoverContentSize= CGSizeMake(350, 44*[self.experimentOptions count]);
    [self.experimentPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (IBAction)showLocations:(id)sender {
    NSLog(@"trying to show locations!");
    if(self.locationPopoverController == nil) {
        IC_OptionSelect *locations = [[IC_OptionSelect alloc] initWithNibName:@"IC_OptionSelect" bundle:[NSBundle mainBundle]];
        self.locationPopoverController = [[UIPopoverController alloc] initWithContentViewController:locations];
        self.locationPopoverController.delegate = self;
        locations.options = self.locationOptions;
        locations.delegate = self;
    }
    
    CGRect popoverRect = [self.view convertRect:[sender frame] toView:[sender superview]];
    self.locationPopoverController.popoverContentSize= CGSizeMake(350, 44*[self.locationOptions count]);
    [self.locationPopoverController presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


-(void)updateOption:(id)optionPicked
{
    NSLog(@"called the delegate!");
    if ([self.experimentOptions containsObject:optionPicked]) {
        self.experiment.titleLabel.text = optionPicked;
        self.experiment.titleLabel.textColor = [UIColor colorWithRed:166.0f/255.0f green:71.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        [self.experimentPopoverController dismissPopoverAnimated: YES];
    } else if ([self.locationOptions containsObject:optionPicked]) {
        self.location.titleLabel.text = optionPicked;
        self.location.titleLabel.textColor = [UIColor colorWithRed:219.0f/255.0f green:74.0f/255.0f blue:59.0f/255.0f alpha:1.0f];
        [self.locationPopoverController dismissPopoverAnimated: YES];
    }
    // dismiss popover
    [self showNextButton];
}

-(void)showNextButton {
    if(![self.experiment.titleLabel.text isEqualToString:@"********************"] &&
       ![self.location.titleLabel.text isEqualToString:@"********************"]
       ) {
        // set next button properties to not be hidden and disabled
        NSLog(@"show the button!");
        self.next.enabled = YES;
    }
}

#pragma mark - Popup stuff

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

#pragma mark - View lifecycle


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
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.model = appDelegate.model;

    self.next.enabled = NO;
    self.experiment.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.location.titleLabel.adjustsFontSizeToFitWidth = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
