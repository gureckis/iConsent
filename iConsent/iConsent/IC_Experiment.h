//
//  IC_Experiment.h
//  iConsent
//
//  Created by Todd Gureckis on 4/1/13.
//  Copyright (c) 2013 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IC_Experiment : UIViewController {
    bool running;
    NSTimeInterval startTime;
}

@property (strong, nonatomic) IBOutlet UILabel *timer;
- (IBAction)goToFinalNotes:(id)sender;

@end
