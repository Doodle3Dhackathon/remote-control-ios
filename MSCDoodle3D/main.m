//
//  main.m
//  MSCDoodle3D
//
//  Created by Marijn Schilling on 22/03/14.
//  Copyright (c) 2014 Marijn Schilling. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "D3DAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {

        BOOL runningTests = (NSClassFromString(@"D3DTestsAppDelegate") != nil);
        if (runningTests)
        {
            return UIApplicationMain(argc, argv, nil, @"D3DTestsAppDelegate");
        }

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([D3DAppDelegate class]));
    }
}
