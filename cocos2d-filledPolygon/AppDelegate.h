//
//  AppDelegate.h
//  ArchiStar
//
//  Created by Goffredo Marocchi on 7/10/12.
//  Copyright IGGS 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*__weak director_;							// weak ref
    
}

@property (nonatomic, strong) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (weak, readonly) CCDirectorIOS *director;

@property (nonatomic, assign) BOOL levelLoaded;

@end
