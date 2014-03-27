#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterSettings.h"
#import "D3DPrinterProxy.h"
#import "D3DPrinterSettings.h"

@interface D3DPrinterProxy ()

@property(nonatomic) CGFloat extrusion;
@property(nonatomic, strong) NSString *ipAddress;
@property(nonatomic, strong) D3DPrinterSettings *printerSettings;
@property(nonatomic) NSInteger stepDistance;
@property(nonatomic) CGFloat speed;
@end

@implementation D3DPrinterProxy

- (id)initWithIPAddress:(NSString *)ipAddress
{
    self = [self init];

    if (self)
    {
        self.printerSettings = [[D3DPrinterSettings alloc] init];
        self.ipAddress = ipAddress;
        self.stepDistance = 50;
        self.speed = 2000;
    }

    return self;
}

- (AFHTTPRequestOperationManager *)requestOperationManager
{
    if(!_requestOperationManager)
    {
        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
    }
    return _requestOperationManager;
}

- (void)start
{
    NSString *gCode = [D3DPrinterSettings startCode];
    [self postAPIRequest:gCode isStartCode:YES ];
}

- (void)stop
{
    NSString *gCode = [D3DPrinterSettings stopCode];
    [self postAPIRequest:gCode];
}

- (void)moveZ
{
    NSString *gCode = [self.printerSettings codeToMoveZ];
    [self postAPIRequest:gCode];
}

- (void)moveYUp
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:0 y:self.stepDistance speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveYDown
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:0 y:-self.stepDistance speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveXRight
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:self.stepDistance y:0 speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveXLeft
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:-self.stepDistance y:0 speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)postAPIRequest:(NSString *)gcode
{
    [self postAPIRequest:gcode isStartCode:NO];
}

- (void)postAPIRequest:(NSString *)gcode isStartCode:(BOOL)isStartCode
{
    if(gcode)
    {
        NSDictionary *parameters = @{
                @"start" : @"true",
                @"first" : isStartCode ? @"true" : @"false",
                @"gcode" : gcode
        };

        __block NSString *apiResponse;

        NSString *URLString = [NSString stringWithFormat:@"http://%@/d3dapi/printer/print", self.ipAddress];
        [self.requestOperationManager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            apiResponse = [NSString stringWithFormat:@"JSON: %@", responseObject];
            NSLog(@"response succes is %@", apiResponse);
        }                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            apiResponse = [NSString stringWithFormat:@"Error: %@", error];
            NSLog(@"response failure is %@", apiResponse);
        }];
    }
}

@end