//
//  IC_Model.m
//  iConsent
//
//  Created by Todd Gureckis on 10/30/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import "IC_Model.h"
#import "Reachability.h"
#import "SBJson.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <stdlib.h>
#include <time.h>

@interface IC_Model()
@property (nonatomic, strong) NSURLConnection *reserveConnection;
@property (nonatomic, strong) NSURLConnection *sendConnection;
- (void)internetUnreachable;
- (void)serverUnresponsive;
- (void)badInput;
- (NSString *)determineMacAddress;
- (NSString *)generateProcessIDWithLength:(int)len;
- (NSString *)generateRandomStringWithLength:(int)len;
- (NSMutableURLRequest *)makePOSTRequestWithURL:(NSString *)url andKeys:(NSDictionary *)keyValues;
- (NSMutableURLRequest *)makePOSTRequestWithURL:(NSString *)url andKeys:(NSDictionary *)keyValues andImage:(UIImage *)imgdata;
@end

@implementation IC_Model
@synthesize reserveConnection = _reserveConnection;
@synthesize sendConnection = _sendConnection;
@synthesize experimentOptions = _experimentOptions;
@synthesize locationOptions = _locationOptions;
@synthesize genderOptions = _genderOptions;
@synthesize ethnicOptions = _ethnicOptions;
@synthesize languageOptions = _languageOptions;
@synthesize siblingOptions = _siblingOptions;
@synthesize birthorderOptions = _birthorderOptions;
@synthesize deviceID = _deviceID;
@synthesize processID = _processID;
@synthesize subjectNumber = _subjectNumber;
@synthesize subjectID = _subjectID;
@synthesize organizationName = _organizationName;
@synthesize responseData = _responseData;
@synthesize childStudy = _childStudy;
@synthesize consent = _consent;
@synthesize delegate = _delegate;
@synthesize interfaceDelegate = _interfaceDelegate;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        srandom(time(NULL));
        self.deviceID = [self determineMacAddress];
        self.processID = [self generateProcessIDWithLength:10];
        self.subjectID = @"******";
        self.responseData = [NSMutableData data];
        NSLog(@"device id = %@", self.deviceID);
        NSLog(@"process id = %@", self.processID);
        self.currentExperiment = nil;
        self.currentLocation = nil;
        self.childStudy = NO;
        self.delegate = nil;
    }
    return self;
}

- (NSString *)getServerName {
    return @SERVERNAME;
}

- (NSString *)getConsentURL {
    return [[NSString alloc] initWithFormat:@"%@/consent", @SERVERNAME];
}

- (NSString *)getSubjectID {
    return self.subjectID;
}

- (NSString *)getOrganizationName {
    return self.organizationName;
}

- (NSString *)getCurrentLocation {
    if (self.currentLocation==nil) {
        NSLog(@"Error!  Current location hasn't been selected yet!");
    }
    return self.currentLocation;
}

- (NSString *)getCurrentExperiment {
    if (self.currentExperiment==nil) {
        NSLog(@"Error!  Current experiment hasn't been selected yet!");
    }
    return self.currentExperiment;
        
}

- (void)selectExperiment:(id)optionPicked {
    self.currentExperiment = optionPicked;
}

- (void)selectLocation:(id)optionPicked {
    self.currentLocation = optionPicked;
}

- (BOOL)loadServerInfo {
    if ([self connected]) {
        // parse the JSON string into an object - assuming json_string is a NSString of JSON data
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/GetServerInfo", @SERVERNAME]]];
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (response) {
            NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"resulting JSON: %@", json_string);
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            id jsonresult = [parser objectWithString:json_string error:nil];
            if ([jsonresult isKindOfClass:[NSDictionary class]]) {
                // get the results
                if ([[jsonresult objectForKey:@"status"] isEqualToString:@"error"]) {
                    NSString *errormsg = [jsonresult objectForKey:@"msg"];
                    [self.interfaceDelegate unrecoverableErrorWithMsg: errormsg];
                } else {
                    // get the results
                    self.organizationName = [jsonresult objectForKey:@"org_name"];
                    self.experimentOptions = [jsonresult objectForKey:@"experiments"];
                    self.locationOptions = [jsonresult objectForKey:@"locations"];
                    self.genderOptions = [jsonresult objectForKey:@"gender_options"];
                    self.ethnicOptions = [jsonresult objectForKey:@"race_ethnics_options"];
                    self.languageOptions = [jsonresult objectForKey:@"language_options"];
                    // primary language options is the same as languageOptions
                    self.siblingOptions = [jsonresult objectForKey:@"sibling_options"];
                    self.birthorderOptions = [jsonresult objectForKey:@"birth_order_options"];
                }
            } else {
                // send a bad response error
                [self badInput];
                return IC_MODEL_FAILURE;
            }
        } else {
            // connection failed
            [self serverUnresponsive];
            return IC_MODEL_FAILURE;
        }
    } else {
        [self internetUnreachable];
        return IC_MODEL_FAILURE;
    }
    return IC_MODEL_SUCCESS;
}




- (BOOL)makeAReservation {
    
    if([self connected]) {
        // first insert the form values
        NSString *url = [[NSString alloc] initWithFormat:@"%@/MakeReservation", @SERVERNAME];
        NSDictionary *keyValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.deviceID, @"deviceID",
                                   self.processID,@"processID",
                                   nil];
        NSMutableURLRequest *request = [self makePOSTRequestWithURL:url andKeys:keyValues];
        self.reserveConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSAssert(self.reserveConnection != nil, @"Failure to create URL connection.");
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    } else {
        [self internetUnreachable];
        return IC_MODEL_FAILURE;
    }
    return IC_MODEL_SUCCESS;
}

- (BOOL)studyFormFinished {
    if([self connected]) {
        NSString *url = [[NSString alloc] initWithFormat:@"%@/StudyInfoFinished", @SERVERNAME];
        NSDictionary *keyValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.deviceID, @"deviceID",
                                   self.processID,@"processID",
                                   self.subjectID, @"subjectID",
                                   [NSNumber numberWithBool:self.childStudy], @"childStudy",
                                   self.currentExperiment, @"currentExperiment",
                                   self.currentLocation, @"currentLocation",
                                   nil];
        NSMutableURLRequest *request = [self makePOSTRequestWithURL:url andKeys:keyValues];
        self.sendConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSAssert(self.sendConnection != nil, @"Failure to create URL connection.");
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    } else {
        [self internetUnreachable];
        return IC_MODEL_FAILURE;
    }
    return IC_MODEL_SUCCESS;
}

- (BOOL)provideConsentWithSignature:(UIImage *)signature {
    if([self connected]) {
        // first insert the form values
        NSString *url = [[NSString alloc] initWithFormat:@"%@/ProvideConsent", @SERVERNAME];
        NSDictionary *keyValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.deviceID, @"deviceID",
                                   self.processID,@"processID",
                                   nil];
        NSMutableURLRequest *request = [self makePOSTRequestWithURL:url andKeys:keyValues andImage:signature];
        self.sendConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSAssert(self.reserveConnection != nil, @"Failure to create URL connection.");
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    } else {
        [self internetUnreachable];
        return IC_MODEL_FAILURE;
    }
    return IC_MODEL_SUCCESS;
}

- (BOOL)submitParticipantInfo:(NSString *)jsonSummary {
    // there might be a couple actual database field we want to deal with here
    if([self connected]) {
        NSString *url = [[NSString alloc] initWithFormat:@"%@/ParticipantInfoFinished", @SERVERNAME];
        NSDictionary *keyValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.deviceID, @"deviceID",
                                   self.processID,@"processID",
                                   jsonSummary, @"participantInfo",
                                   nil];
        NSMutableURLRequest *request = [self makePOSTRequestWithURL:url andKeys:keyValues];
        self.sendConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSAssert(self.sendConnection != nil, @"Failure to create URL connection.");
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [self internetUnreachable];
        return IC_MODEL_FAILURE;
    }
    return IC_MODEL_SUCCESS;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"getting response");
	[self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"recieved some data");
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// this is the model here, so shouldn't be issuing views, but should pass them up perhaps?
    NSLog(@"Connection failed: %@", [error description]);
    //label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.reserveConnection) {
        // do something with the data
        NSLog(@"got the data");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *json_string = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"resulting JSON: %@", json_string);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonresult = [parser objectWithString:json_string error:nil];
        if ([jsonresult isKindOfClass:[NSDictionary class]]) {
            // get the results
            if ([[jsonresult objectForKey:@"status"] isEqualToString:@"error"]) {
                NSString *errormsg = [jsonresult objectForKey:@"msg"];
                [self.interfaceDelegate unrecoverableErrorWithMsg: errormsg];
            } else {
                // get the results
                self.subjectNumber = [[jsonresult objectForKey:@"subjid"] integerValue];
                self.subjectID = [[NSString alloc] initWithFormat:@"%05d", self.subjectNumber];
                NSLog(@"%@", self.subjectID);
                [self.delegate reservationComplete];
            }
        } else {
            // send a bad response error
            [self badInput];
        }
    } 
    else if (connection == self.sendConnection) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *json_string = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"resulting JSON: %@", json_string);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonresult = [parser objectWithString:json_string error:nil];
        if ([jsonresult isKindOfClass:[NSDictionary class]]) {
            // get the results
            if ([[jsonresult objectForKey:@"status"] isEqualToString:@"error"]) {
                NSString *errormsg = [jsonresult objectForKey:@"msg"];
                [self.interfaceDelegate unrecoverableErrorWithMsg: errormsg];
            }
        } else {
            // send a bad response error
            [self badInput];
        }

    }
}

- (void)updateSubjectID {
    if(self.childStudy) {
        // add a C to the end of the subject number
        self.subjectID = [[NSString alloc] initWithFormat:@"%05dC", self.subjectNumber];
    } else {
        self.subjectID = [[NSString alloc] initWithFormat:@"%05d", self.subjectNumber];
    }
}

#pragma mark - error handling
- (void)internetUnreachable {
    [self.interfaceDelegate unrecoverableErrorWithMsg:@"Sorry, this application requires a working Internet connection!  Please check your network settings and relaunch the app."];
}

- (void)serverUnresponsive {
    [self.interfaceDelegate unrecoverableErrorWithMsg:@"Sorry, unable to contact the server!  Please check your network settings and verify that a suitable iConsent server process is running at the location you expected."];
}

- (void)badInput {
    [self.interfaceDelegate unrecoverableErrorWithMsg:@"Sorry, server provided unexpected or poorly formed input.  This may be a bug.  Please quit and try again."];
}


- (NSString *)generateProcessIDWithLength: (int)len
{
    return [self generateRandomStringWithLength:len];
}

- (NSString *)generateRandomStringWithLength: (int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: random()%[letters length]]];
    }
    return randomString;
}


- (NSString *)determineMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
    
}

- (NSMutableURLRequest *)makePOSTRequestWithURL:(NSString *)url andKeys:(NSDictionary *)keyValues {
    
    // make response get subject number in response and update record
    NSURL *myURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    // this is necessary for the mulit-part request
    NSString *boundary = [self generateRandomStringWithLength:10];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // here is the form data
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in keyValues) {
        NSLog(@"%@", param);
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [keyValues objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *getLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
    
    return request;
}


- (NSMutableURLRequest *)makePOSTRequestWithURL:(NSString *)url andKeys:(NSDictionary *)keyValues andImage:(UIImage *)imgdata {
    
    // make response get subject number in response and update record
    NSURL *myURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:myURL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    // this is necessary for the mulit-part request
    NSString *boundary = [self generateRandomStringWithLength:10];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // here is the form data
    NSMutableData *body = [NSMutableData data];
    
    // add key values pairs
    for (NSString *param in keyValues) {
        NSLog(@"%@", param);
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [keyValues objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(imgdata, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"signature\"; filename=\"signature.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *getLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
    
    return request;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (BOOL)verifyConnected
{
    BOOL connectQ = [self connected];
    if (!connectQ) {
        [self internetUnreachable];
    }
    return connectQ;
}


@end
