//
//  IC_MultiOptionSelect.h
//  iConsent
//
//  Created by Todd Gureckis on 11/25/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IC_MultiOptionSelect;

@protocol IC_MultiOptionSelectDelegate
-(void)addOption:(id)optionPicked from:(IC_MultiOptionSelect *)picker;
-(void)deleteOption:(id)optionPicked from:(IC_MultiOptionSelect *)picker;
@end

@interface IC_MultiOptionSelect : UITableViewController
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) id <IC_MultiOptionSelectDelegate> delegate;
@end
