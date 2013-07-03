//
//  IC_Experiment.m
//  iConsent
//
//  Created by Todd Gureckis on 4/1/13.
//  Copyright (c) 2013 Todd Gureckis. All rights reserved.
//

#import "IC_Experiment.h"

@interface IC_Experiment ()
@end

@implementation IC_Experiment
@synthesize timer = _timer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)goToFinalNotes:(id)sender {
    // save total time taken to database
    // go to final notes screen
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.timer.text = @"0:00.0";
    running = true;
    startTime = [NSDate timeIntervalSinceReferenceDate];
    [self updateTime];
}

- (void)updateTime {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - startTime;
    
    int mins = (int) (elapsed / 60.0);
    elapsed -= mins * 60;
    int secs = (int) elapsed;
    elapsed -= secs;
    int fraction = elapsed *10.0;
    
    self.timer.text = [NSString stringWithFormat:@"%u:%02u.%u", mins, secs, fraction];
    
    [self performSelector:@selector(updateTime) withObject:self afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
