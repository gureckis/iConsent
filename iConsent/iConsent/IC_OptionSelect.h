//
//  IC_OptionSelect.h
//  iConsent
//
//  Created by Todd Gureckis on 11/9/12.
//  Copyright (c) 2012 Todd Gureckis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IC_OptionSelectDelegate
-(void)updateOption:(id)optionPicked;
@end

@interface IC_OptionSelect : UITableViewController
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) id <IC_OptionSelectDelegate> delegate;
@end