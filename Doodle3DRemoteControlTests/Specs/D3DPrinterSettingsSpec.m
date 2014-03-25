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
                CGFloat extrusion = [sut calculateExtrusionWithTargetX:50 targetY:0 currentX:0 currentY:0];
                [[theValue(extrusion) should] equal:1.524 withDelta:0.001];
            });

            it(@"calculate's extrusion for movement on y axis", ^{
                CGFloat extrusion = [sut calculateExtrusionWithTargetX:0 targetY:50 currentX:0 currentY:0];
                [[theValue(extrusion) should] equal:1.524 withDelta:0.001];
            });

            it(@"calculate's extrusion for double movement  on x axis", ^{
                CGFloat extrusion = [sut calculateExtrusionWithTargetX:100 targetY:0 currentX:0 currentY:0];
                [[theValue(extrusion) should] equal:3.048 withDelta:0.001];
            });
        });

        SPEC_END
