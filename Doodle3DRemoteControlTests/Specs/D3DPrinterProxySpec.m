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

    it(@"posts requests", ^{
        D3DPrinterProxy *proxy = [[D3DPrinterProxy alloc] initWithIPAddress:@"1.2.3.4"];

        NSDictionary *expectParams = @{
                @"start" : @"true",
                @"first" : @"false",
                @"gcode" : @"G1 X50.0 Y0.0 F2000, E1.5244542"
        };
        proxy.requestOperationManager = [AFHTTPRequestOperationManager mock];

        [[proxy.requestOperationManager should] receive:@selector(POST:parameters:success:failure:)
                                          withArguments:any(), expectParams, any(), any()];

        [proxy moveXRight];
    });
});

SPEC_END
