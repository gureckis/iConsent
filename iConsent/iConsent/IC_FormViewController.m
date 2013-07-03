//
//  IC_ViewController.m
//  iConsent
//
//  Created by Todd Gureckis on 10/17/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import "IC_FormViewController.h"

@interface IC_FormViewController ()
@property (nonatomic) UIInterfaceOrientation orientations;
@property int state;
@end

@implementation IC_FormViewController
@synthesize containerView = _containerView;
@synthesize viewController = _viewController;
@synthesize model = _model;
@synthesize orientations = _orientations;
@synthesize state = _state;

#pragma mark - Experiment Functions

- (void)updateState {
    switch (self.state) {
        case STUDY_INFO:
            [self getStudyInfo];
            break;
        case CONSENT:
            [self getConsent];
            break;
        case PARTICIPANT_INFO:
            [self getParticipantInfo];
            break;
        case DO_NOTES:
            [self doNotes];
            break;
        case DO_EXPERIMENT:
            [self doExperiment];
            break;
        case DO_FINAL_NOTES:
            [self doFinalNotes];
            break;

        case THANK_YOU:
            [self getThankYou];
            break;
        default:
            NSLog(@"Error, unknown state!");
            break;
    }
}

- (void)getStudyInfo {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_StudyInfoForm *vs = [[IC_StudyInfoForm alloc] initWithNibName:@"IC_StudyInfoForm" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (void)getStudyInfoIsFinished {
    NSLog(@"done with study info");
    self.state = CONSENT;
    [self updateState];
}

- (void)getConsent {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_ConsentForm *vs = [[IC_ConsentForm alloc] initWithNibName:@"IC_ConsentForm" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (void)getConsentIsFinished {
    NSLog(@"done with consent");
    self.state = PARTICIPANT_INFO;
    [self updateState];
}

- (void)getParticipantInfo {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    if (self.model.childStudy) {
        // this is a child study, show appropriate form
        IC_SubjectInfoFormChild *vs = [[IC_SubjectInfoFormChild alloc] initWithNibName:@"IC_SubjectInfoFormChild" bundle:nil];
        [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
    } else {
        // this is and adult study (coming soon)
        NSLog(@"Adult study not implemented yet, using child study form.");
        IC_SubjectInfoFormChild *vs = [[IC_SubjectInfoFormChild alloc] initWithNibName:@"IC_SubjectInfoFormChild" bundle:nil];
        [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
    }
}

- (void)getParticipantInfoIsFinished {
    NSLog(@"done with participant info");
    self.state = DO_NOTES;
    [self updateState];
}

- (void)doNotes {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_Notes *vs = [[IC_Notes alloc] initWithNibName:@"IC_Notes" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (void)doNotesIsFinished {
    // this should "end" this sequence of views
    self.state = DO_EXPERIMENT;
    [self updateState];
}


- (void)doExperiment {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_Experiment *vs = [[IC_Experiment alloc] initWithNibName:@"IC_Experiment" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];    
}

- (void)doExperimentIsFinished {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_Notes *vs = [[IC_Notes alloc] initWithNibName:@"IC_Notes" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
}



- (void)doFinalNotes {
    // first set allowable orientations
    self.orientations = UIInterfaceOrientationPortrait;
    
    IC_Notes *vs = [[IC_Notes alloc] initWithNibName:@"IC_Notes" bundle:nil];
    [self transitionToViewController:vs withOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (void)doFinalNotesIsFinished {
    // this should "end" this sequence of views
    self.state = THANK_YOU;
    [self updateState];
}

- (void)getThankYou {
    
}

- (void)getThankYouIsFinished {
    // this should "end" this sequence of views
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        // first set allowable orientations
        self.orientations = UIInterfaceOrientationPortrait;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.wantsFullScreenLayout = YES;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    self.containerView = [[UIView alloc] initWithFrame:view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.viewController.view];
    
    // find the location of the model
    IC_AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.model = appDelegate.model;
    
    self.state = STUDY_INFO; // PARTICIPANT_INFO; //
    [self updateState];
    NSLog(@"loaded up FormVC");
    // self.state = INSTRUCTIONS_1;
    // [self doInstructions];
    // [self doTestPhase];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation==self.orientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)transitionToViewController:(UIViewController *)aviewController withOptions:(UIViewAnimationOptions)options
{
    aviewController.view.frame = self.containerView.bounds;
    [UIView transitionWithView:self.containerView duration:0.65f options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:aviewController.view];
                    }
                    completion:^(BOOL finished){
                        self.viewController = aviewController;
                    }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IC_Model Delegates
-(void)unrecoverableErrorWithMsg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iConsent" message:msg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Alert view delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Quit"]) {
        exit(0);
    }
}

@end
