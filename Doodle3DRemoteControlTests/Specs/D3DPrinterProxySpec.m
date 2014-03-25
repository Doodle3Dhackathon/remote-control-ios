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

SPEC_BEGIN(D3DPrinterProxySpec)

        describe(@"D3DPrinterProxy", ^{

            context(@"with a printer proxy instance", ^{

                __block D3DPrinterProxy *proxy;

                beforeEach(^{
                    proxy = [[D3DPrinterProxy alloc] initWithIPAddress:@"1.2.3.4"];
                });

                it(@"posts the request with the expected parameters",^{
                    NSDictionary *expectParams = @{
                            @"start" : @"true",
                            @"first" : @"false",
                            @"gcode" : @"G1 X50.000 Y0.000 F2000.000, E1.524"
                    };

                    proxy.requestOperationManager = [AFHTTPRequestOperationManager mock];
                    [[proxy.requestOperationManager should] receive:@selector(POST:parameters:success:failure:)
                                                      withArguments:any(), expectParams, any(), any()];

                    [proxy moveXRight];
                });

                describe(@"consecutive moves", ^{
                    beforeEach(^{
                        NSDictionary *expectParams = @{
                                @"start" : @"true",
                                @"first" : @"false",
                                @"gcode" : @"G1 X50.000 Y0.000 F2000.000, E1.524"
                        };

                        proxy.requestOperationManager = [AFHTTPRequestOperationManager mock];
                        [[proxy.requestOperationManager should] receive:@selector(POST:parameters:success:failure:)
                                                          withArguments:any(), expectParams, any(), any()];

                        [proxy moveXRight];
                    });

                    it(@"adds up the parameters with multiple requests", ^{
                        NSDictionary *expectParams = @{
                                @"start" : @"true",
                                @"first" : @"false",
                                @"gcode" : @"G1 X50.000 Y50.000 F2000.000, E3.049"
                        };

                        [[proxy.requestOperationManager should] receive:@selector(POST:parameters:success:failure:)
                                                          withArguments:any(), expectParams, any(), any()];
                        [proxy moveYUp];
                    });
                });
            });
        });

        SPEC_END
