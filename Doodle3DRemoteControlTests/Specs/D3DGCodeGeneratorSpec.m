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

                __block NSString *sut;

                beforeEach(^{
                    sut = [D3DGCodeGenerator startCode];
                });

                it(@"starts with heat-up code", ^{
                    [[sut should] startWithString:@"M109"];
                });

                it(@"contains console message", ^{
                    [[sut should] containString:@"M117"];
                });
            });
        });

        SPEC_END
