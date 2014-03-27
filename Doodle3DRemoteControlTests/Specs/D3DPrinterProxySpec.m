//
//  D3DPrinterProxySpec.m
//  Doodle3DRemoteControl
//
//  Created by Marijn Schilling on 24/03/14.
//  Copyright 2014 Doodle3D Hackathon. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterProxy.h"
#import "D3DPrinterService.h"

SPEC_BEGIN(D3DPrinterProxySpec)

        describe(@"D3DPrinterProxy", ^{

            context(@"with a printer proxy instance", ^{

                __block D3DPrinterProxy *proxy;

                beforeEach(^{
                    proxy = [[D3DPrinterProxy alloc] init];
                });

                it(@"posts the request with the expected parameters", ^{
                    NSDictionary *expectParams = @{
                            @"start" : @"true",
                            @"first" : @"false",
                            @"gcode" : @"G1 X50.000 Y0.000 F2000.000, E1.524"
                    };

                    proxy.printerService = [D3DPrinterService mock];
                    [[proxy.printerService should] receive:@selector(queuePostParameters:) withArguments:expectParams];

                    [proxy moveXRight];
                });

                describe(@"consecutive moves", ^{
                    it(@"adds up the parameters with multiple requests", ^{
                        proxy.printerService = [D3DPrinterService mock];
                        {
                            NSDictionary *expectParams = @{
                                    @"start" : @"true",
                                    @"first" : @"false",
                                    @"gcode" : @"G1 X50.000 Y0.000 F2000.000, E1.524"
                            };

                            [[proxy.printerService should] receive:@selector(queuePostParameters:) withArguments:expectParams];

                            [proxy moveXRight];
                        }

                        {
                            NSDictionary *expectParams = @{
                                    @"start" : @"true",
                                    @"first" : @"false",
                                    @"gcode" : @"G1 X50.000 Y50.000 F2000.000, E3.049"
                            };

                            [[proxy.printerService should] receive:@selector(queuePostParameters:) withArguments:expectParams];

                            [proxy moveYUp];
                        }
                    });
                });

                describe(@"no requests when out of bounds", ^{
                    beforeEach(^{
                        proxy.printerService = [D3DPrinterService mock];
                    });

                    it(@"can't move down", ^{
                        // Rely on mock
                        [proxy moveYDown];
                    });

                    it(@"can't move left", ^{
                        // Rely on mock
                        [proxy moveXLeft];
                    });

                    it(@"can't move right", ^{
                        [[proxy.printerService should] receive:@selector(queuePostParameters:) withCount:4 arguments:any(), any(), any(), any()];

                        [proxy moveXRight];
                        [proxy moveXRight];
                        [proxy moveXRight];
                        [proxy moveXRight];
                        [proxy moveXRight];
                    });

                    it(@"can't move up", ^{

                        [[proxy.printerService should] receive:@selector(queuePostParameters:) withCount:4 arguments:any(), any(), any(), any()];

                        [proxy moveYUp];
                        [proxy moveYUp];
                        [proxy moveYUp];
                        [proxy moveYUp];
                        [proxy moveYUp];
                    });
                });
            });
        });

        SPEC_END
