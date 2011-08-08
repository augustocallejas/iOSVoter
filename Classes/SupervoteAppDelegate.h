//
//  SupervoteAppDelegate.h
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SupervoteViewController;

@interface SupervoteAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SupervoteViewController *viewController;
	UITabBarController *mainAppController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SupervoteViewController *viewController;
@property (nonatomic, retain) IBOutlet UITabBarController *mainAppController;

- (IBAction)doJoinButtonSendZip;

@end

