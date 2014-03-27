//
//  D3DPrinterServiceSpec.m
//  Doodle3DRemoteControl
//
//  Created by Marijn Schilling on 27/03/14.
//  Copyright 2014 Doodle3D Hackathon. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterService.h"

SPEC_BEGIN(D3DPrinterServiceSpec)

        describe(@"D3DPrinterService", ^{
            __block D3DPrinterService *sut;

            beforeEach(^{
                sut = [[D3DPrinterService alloc] initWithIPAddress:@"1.2.3.4"];
            });

            it(@"sends post requests to the printer", ^{
                sut.requestOperationManager = [AFHTTPRequestOperationManager mock];

                NSDictionary *expectParams = @{
                        @"start" : @"true",
                        @"first" : @"false",
                        @"gcode" : @"G1 X50.000 Y0.000 F2000.000, E1.524"
                };

                [[sut.requestOperationManager should] receive:@selector(POST:parameters:success:failure:) withArguments:any(), expectParams, any(), any()];

                [sut queuePostParameters:expectParams];
            });

            context(@"sequential postings", ^{
                __block void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);

                beforeEach(^{
                    sut.requestOperationManager = [AFHTTPRequestOperationManager nullMock];
                    {
                        KWCaptureSpy *successSpy = [sut.requestOperationManager captureArgument:@selector(POST:parameters:success:failure:) atIndex:2];
                        [sut queuePostParameters:@{@"first" : @YES}];
                        successBlock = successSpy.argument;
                    }
                });

                it(@"posts the next request after successfully finishing the former", ^{
                    NSDictionary *secondParams = @{
                            @"second" : @YES
                    };

                    [sut queuePostParameters:secondParams];

                    [[sut.requestOperationManager should] receive:@selector(POST:parameters:success:failure:)
                                                    withArguments:any(), secondParams, any(), any()];

                    successBlock(nil, nil);
                });
            });
        });

        SPEC_END
