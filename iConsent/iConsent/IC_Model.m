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
@property (nonatomic, strong) NSArray *experiments;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *deviceID; // mac address
@property (nonatomic, strong) NSString *processID; // processID
@property (nonatomic, strong) NSString *subjectNumber;
@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *currentExperiment;
@property (nonatomic, strong) NSString *currentLocation;


- (NSString *)determineMacAddress;
- (NSString *)generateProcessIDWithLength:(int)len;
- (NSString *)generateRandomStringWithLength:(int)len;
- (void)loadOrganizationName;
- (void)loadExperiments;
- (void)loadLocations;
- (void)reserveSubjectNumber;
@end

@implementation IC_Model
@synthesize experiments = _experiments;
@synthesize locations = _locations;
@synthesize deviceID = _deviceID;
@synthesize processID = _processID;
@synthesize subjectNumber = _subjectNumber;
@synthesize organizationName = _organizationName;
@synthesize responseData = _responseData;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        srandom(time(NULL));
        self.deviceID = [self determineMacAddress];
        self.processID = [self generateProcessIDWithLength:10];
        self.responseData = [NSMutableData data];
        NSLog(@"device id = %@", self.deviceID);
        NSLog(@"process id = %@", self.processID);
        self.currentExperiment = nil;
        self.currentLocation = nil;
        
        [self loadExperiments];
        [self loadLocations];
        [self loadOrganizationName];
        [self reserveSubjectNumber];
    }
    return self;
}

- (NSString *)getServerName {
    return @SERVERNAME;
}

- (NSString *)getConsentURL {
    return [[NSString alloc] initWithFormat:@"%@/consent", @SERVERNAME];
}

- (NSArray *)getExperimentOptions {
    return self.experiments;
}

- (NSArray *)getLocationOptions {
    return self.locations;
}

- (NSString *)getSubjectNumber {
    return self.subjectNumber;
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

- (void)reserveSubjectNumber {
    self.subjectNumber = @"05463";
}

- (void)loadOrganizationName {
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/GetOrganizationName", @SERVERNAME]]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"%@", json_string);
    // Create SBJSON object to parse JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id jsonresult = [parser objectWithString:json_string error:nil];
    if ([jsonresult isKindOfClass:[NSDictionary class]]) {
        NSLog(@"got a dictionary");
        self.organizationName = [jsonresult objectForKey:@"org_name"];
        NSLog(@"%@", self.organizationName);
    } else if ([jsonresult isKindOfClass:[NSArray class]]) {
        NSLog(@"got an array");
        self.organizationName = [NSArray arrayWithObjects:
                            @"Entomologist",
                            @"Tree Search",
                            @"Causal Learning",
                            nil];
    }
}

- (void)loadExperiments {
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/GetExperimentNames", @SERVERNAME]]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

    // Create SBJSON object to parse JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id jsonresult = [parser objectWithString:json_string error:nil];
    if ([jsonresult isKindOfClass:[NSDictionary class]]) {
        NSLog(@"got a dictionary");
        self.experiments = [jsonresult objectForKey:@"json_result"];
    } else if ([jsonresult isKindOfClass:[NSArray class]]) {
        NSLog(@"got an array");
        self.experiments = [NSArray arrayWithObjects:
                                @"Entomologist",
                                @"Tree Search",
                                @"Causal Learning",
                            nil];
    }
}

- (void)loadLocations {

    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/GetLocationNames", @SERVERNAME]]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // Create SBJSON object to parse JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id jsonresult = [parser objectWithString:json_string error:nil];
    if ([jsonresult isKindOfClass:[NSDictionary class]]) {
        NSLog(@"got a dictionary");
        self.locations = [jsonresult objectForKey:@"json_result"];
    } else if ([jsonresult isKindOfClass:[NSArray class]]) {
        NSLog(@"got an array");
        self.locations = [NSArray arrayWithObjects:
                          @"AMNH",
                          @"CMOM",
                          @"NYU - Gureckislab",
                          @"NYU - Rhodeslab",
                          nil];
    }
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

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
