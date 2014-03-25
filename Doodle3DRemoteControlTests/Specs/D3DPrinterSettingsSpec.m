//
//  D3DPrinterSettingsSpec.m
//  Doodle3DRemoteControl
//
//  Created by Marijn Schilling on 25/03/14.
//  Copyright 2014 Doodle3D Hackathon. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "D3DPrinterSettings.h"

SPEC_BEGIN(D3DPrinterSettingsSpec)

        describe(@"D3DPrinterSettings", ^{

            __block D3DPrinterSettings *sut;

            beforeEach(^{

                sut = [[D3DPrinterSettings alloc] init];
            });

            it(@"calculate's extrusion for movement on x axis", ^{
                CGFloat extrusion = [sut calculateExtrusionForRelativeX:50 y:0];

                [[theValue(extrusion) should] equal:1.524 withDelta:0.001];
            });

            it(@"calculate's extrusion for movement on y axis", ^{
                CGFloat extrusion = [sut calculateExtrusionForRelativeX:0 y:50];
                [[theValue(extrusion) should] equal:1.524 withDelta:0.001];
            });

            it(@"calculate's extrusion for double movement on x axis", ^{
                CGFloat extrusion = [sut calculateExtrusionForRelativeX:100 y:0];
                [[theValue(extrusion) should] equal:3.048 withDelta:0.001];
            });

            describe(@"generating move code", ^{

                context(@"start code", ^{

                    __block NSString *startCode;

                    beforeEach(^{
                        startCode = [D3DPrinterSettings startCode];
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
                        stopCode = [D3DPrinterSettings stopCode];
                    });

                    it(@"starts with turning the fan off", ^{
                        [[stopCode should] startWithString:@"M107"];
                    });

                    it(@"contains code to return to 0,0", ^{
                        [[stopCode should] containString:@"G28 X0 Y0"];
                    });
                });

                it(@"generates the code to move the z-axis", ^{
                    [[[sut codeToMoveZ] should] startWithString:@"G1 Z0.200"];
                });

                it(@"generates the code to move on the x/y plane", ^{
                    NSString *gCode = [sut codeToMoveRelativeX:50 y:0 speed:2000];
                    [[gCode should] equal:@"G1 X50.000 Y0.000 F2000.000, E1.524"];
                });
            });
        });

        SPEC_END
