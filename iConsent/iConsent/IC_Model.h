//
//  IC_Model.h
//  iConsent
//
//  Created by Todd Gureckis on 10/30/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSURLConnection.h>

#define SERVERNAME "http://192.168.1.2:5003"

#define IC_MODEL_SUCCESS TRUE
#define IC_MODEL_FAILURE FALSE

#define MALE 0
#define FEMALE 1

#define CONSENTED 1
#define STARTED 2
#define COMPLETED 3
#define DEBRIEFED 4
#define QUITEARLY 5

@protocol IC_ModelDelegate
@optional -(void)reservationComplete;
@end

@protocol IC_ModelInterfaceDelegate
@optional -(void)unrecoverableErrorWithMsg:(NSString *)msg;
@end

@interface IC_Model : NSObject <NSURLConnectionDelegate>
@property (nonatomic, assign) id <IC_ModelDelegate> delegate;
@property (nonatomic, assign) id <IC_ModelInterfaceDelegate> interfaceDelegate;
@property (nonatomic, strong) NSArray *experimentOptions;
@property (nonatomic, strong) NSArray *locationOptions;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *deviceID; // mac address
@property (nonatomic, strong) NSString *processID; // processID
@property int subjectNumber; // raw subject number
@property (nonatomic, strong) NSString *subjectID; // pretty version of subject number
@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *currentExperiment;
@property (nonatomic, strong) NSString *currentLocation;
@property BOOL childStudy;

- (BOOL)loadServerInfo;
- (NSString *)getServerName;
- (NSString *)getConsentURL;
- (NSString *)getSubjectID;
- (NSString *)getOrganizationName;
- (NSString *)getCurrentLocation;
- (NSString *)getCurrentExperiment;
- (BOOL)makeAReservation;
- (void)updateSubjectID;
- (void)selectExperiment:(id)optionPicked;
- (void)selectLocation:(id)optionPicked;
- (void)studyFormFinished;
- (BOOL)connected;
@end
