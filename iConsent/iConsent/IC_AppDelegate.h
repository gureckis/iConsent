//
//  IC_AppDelegate.h
//  iConsent
//
//  Created by Todd Gureckis on 10/17/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IC_Model.h"

@class IC_ViewController;

@interface IC_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IC_ViewController *viewController;
@property (strong, nonatomic) IC_Model *model;
@end
