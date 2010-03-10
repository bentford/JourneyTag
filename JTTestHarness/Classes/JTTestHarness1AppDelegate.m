//
//  JTTestHarness1AppDelegate.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "JTTestHarness1AppDelegate.h"


@implementation JTTestHarness1AppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

