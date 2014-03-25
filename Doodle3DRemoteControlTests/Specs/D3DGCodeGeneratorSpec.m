//
//  D3DGCodeGeneratorSpec.m
//  MSCDoodle3D
//
//  Created by Marijn Schilling on 24/03/14.
//  Copyright 2014 Marijn Schilling. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "D3DGCodeGenerator.h"

SPEC_BEGIN(D3DGCodeGeneratorSpec)

        describe(@"D3DGCodeGenerator", ^{

            context(@"start code", ^{

                __block NSString *startCode;

                beforeEach(^{
                    startCode = [D3DGCodeGenerator startCode];
                });

                it(@"starts with heat-up code", ^{
                    [[startCode should] startWithString:@"M109"];
                });

                it(@"contains console message", ^{
                    [[startCode should] containString:@"M117"];
                });
            });

            context(@"stop code", ^{

                __block NSString *stopCode;

                beforeEach(^{
                    stopCode = [D3DGCodeGenerator stopCode];
                });

                it(@"starts with turning the fan off", ^{
                    [[stopCode should] startWithString:@"M107"];
                });

                it(@"contains code to return to 0,0", ^{
                    [[stopCode should] containString:@"G28 X0 Y0"];
                });

            });

            context(@"move z-axis", ^{
               
                it(@"starts with moving the z axis with 0.2", ^{
                    [[[D3DGCodeGenerator moveCodeWithZ:0.2] should] startWithString:@"G1 Z0.200"];
                });
            });

            context(@"move on x/y plane", ^{

                it(@"generates move code", ^{
                    NSString *gCode = [D3DGCodeGenerator generateMoveCodeForX:10 y:11.5 speed:12 extrusion:13.5];
                    [[gCode should] equal:@"G1 X10.000 Y11.500 F12.000, E13.500"];
                });
            });
        });

        SPEC_END
