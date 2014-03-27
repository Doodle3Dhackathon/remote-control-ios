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
@property(nonatomic, strong) NSMutableArray *gCodeQueue;
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

        self.gCodeQueue = [NSMutableArray array];
    }

    return self;
}

- (AFHTTPRequestOperationManager *)requestOperationManager
{
    if (!_requestOperationManager)
    {
        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
    }
    return _requestOperationManager;
}

- (void)start
{
    NSString *gCode = [D3DPrinterSettings startCode];
    [self queueGCode:gCode isStartCode:YES ];
}

- (void)stop
{
    NSString *gCode = [D3DPrinterSettings stopCode];
    [self queueGCode:gCode];
}

- (void)moveZ
{
    NSString *gCode = [self.printerSettings codeToMoveZ];
    [self queueGCode:gCode];
}

- (void)moveYUp
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:0 y:self.stepDistance speed:self.speed];
    [self queueGCode:gCode];
}

- (void)moveYDown
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:0 y:-self.stepDistance speed:self.speed];
    [self queueGCode:gCode];
}

- (void)moveXRight
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:self.stepDistance y:0 speed:self.speed];
    [self queueGCode:gCode];
}

- (void)moveXLeft
{
    NSString *gCode = [self.printerSettings codeToMoveRelativeX:-self.stepDistance y:0 speed:self.speed];
    [self queueGCode:gCode];
}

- (void)queueGCode:(NSString *)gCode
{
    [self queueGCode:gCode isStartCode:NO];
}

- (void)queueGCode:(NSString *)gCode isStartCode:(BOOL)isStartCode
{
    if (!gCode) return;

    NSDictionary *parameters = @{
            @"start" : @"true",
            @"first" : isStartCode ? @"true" : @"false",
            @"gcode" : gCode
    };

    [self.gCodeQueue addObject:parameters];
    [self postNextInQueue];
}

- (void)postNextInQueue
{
    if ([self.gCodeQueue count])
    {
        id gCodeParameters = [self.gCodeQueue objectAtIndex:0];
        [self.gCodeQueue removeObjectAtIndex:0];
        [self postAPIRequestWithGCodeParameters:gCodeParameters];
    }
}

- (void)postAPIRequestWithGCodeParameters:(NSDictionary *)parameters
{
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

@end