//
//  IC_FormViewController.h
//  iConsent
//
//  Created by Todd Gureckis on 10/17/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_Model.h"
#import "IC_AppDelegate.h"
#import "IC_Model.h"
#import "IC_StudyInfoForm.h"
#import "IC_ConsentForm.h"
#import "IC_SubjectInfoFormChild.h"
#import "IC_Experiment.h"
#import "IC_Notes.h"

@interface IC_FormViewController : UIViewController <IC_ModelInterfaceDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) IC_Model *model;

// handle transitions between views
- (void)transitionToViewController:(UIViewController *)viewController withOptions:(UIViewAnimationOptions)options;


- (void)updateState;

// first screen
#define STUDY_INFO 0
- (void)getStudyInfo;
- (void)getStudyInfoIsFinished;

// informed consent
#define CONSENT 1
- (void)getConsent;
- (void)getConsentIsFinished;

// participant info
#define PARTICIPANT_INFO 2
- (void)getParticipantInfo;
- (void)getParticipantInfoIsFinished;

// do notes
#define DO_NOTES 3
- (void)doNotes;
- (void)doNotesIsFinished;

// do experiment
#define DO_EXPERIMENT 4
- (void)doExperiment;
- (void)doExperimentIsFinished;

// do final notes
#define DO_FINAL_NOTES 5
- (void)doFinalNotes;
- (void)doFinalNotesIsFinished;

// thank you
#define THANK_YOU 6
- (void)getThankYou;
- (void)getThankYouIsFinished;

@end
