//
//  AppDelegate.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/21.
//

#import "AppDelegate.h"

#import "BaseNavigationController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[BaseNavigationController alloc] initWithRootViewController:[ViewController new]];
    
    return YES;
}

@end
