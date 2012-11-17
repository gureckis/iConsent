//
//  IC_Model.h
//  iConsent
//
//  Created by Todd Gureckis on 10/30/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SERVERNAME "http://localhost:5003"

#define MALE 0
#define FEMALE 1

#define CONSENTED 1
#define STARTED 2
#define COMPLETED 3
#define DEBRIEFED 4
#define QUITEARLY 5

@interface IC_Model : NSObject
- (NSString *)getServerName;
- (NSString *)getConsentURL;
- (NSArray *)getExperimentOptions;
- (NSArray *)getLocationOptions;
- (NSString *)getSubjectNumber;
- (NSString *)getOrganizationName;
- (NSString *)getCurrentLocation;
- (NSString *)getCurrentExperiment;
- (void)selectExperiment:(id)optionPicked;
- (void)selectLocation:(id)optionPicked;
- (BOOL)connected;
@end
