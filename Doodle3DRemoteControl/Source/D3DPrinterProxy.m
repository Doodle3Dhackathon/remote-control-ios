#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterSettings.h"
#import "D3DPrinterProxy.h"
#import "D3DPrinterSettings.h"

@interface D3DPrinterProxy ()
@property(nonatomic) CGFloat xPos;
@property(nonatomic) CGFloat yPos;
@property(nonatomic) CGFloat zPos;
@property(nonatomic) CGFloat extrusion;
@property(nonatomic, strong) NSString *ipAddress;
@property(nonatomic, strong) D3DPrinterSettings *printerSettings;
@property(nonatomic) NSInteger stepDistance;
@property(nonatomic) CGFloat speed;
@property(nonatomic) CGFloat currentX;
@property(nonatomic) CGFloat currentY;
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
    self.zPos += self.printerSettings.layerHeight;
    NSString *gCode = [self.printerSettings codeToMoveZ:self.zPos];
    [self postAPIRequest:gCode];
}

- (void)moveYUp
{
    self.currentY = self.yPos;
    self.yPos += self.stepDistance;
    NSString *gCode = [self.printerSettings codeToMoveToX:self.xPos
                                                        y:self.yPos
                                                    fromX:self.currentX
                                                        y:self.currentY
                                                    speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveYDown
{
    self.currentY = self.yPos;
    self.yPos -= self.stepDistance;
    NSString *gCode = [self.printerSettings codeToMoveToX:self.xPos
                                                        y:self.yPos
                                                    fromX:self.currentX
                                                        y:self.currentY
                                                    speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveXRight
{
    self.currentX = self.xPos;
    self.xPos += self.stepDistance;
    NSString *gCode = [self.printerSettings codeToMoveToX:self.xPos
                                                        y:self.yPos
                                                    fromX:self.currentX
                                                        y:self.currentY
                                                    speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)moveXLeft
{
    self.currentX = self.xPos;
    self.xPos -= self.stepDistance;

    NSString *gCode = [self.printerSettings codeToMoveToX:self.xPos
                                                        y:self.yPos
                                                    fromX:self.currentX
                                                        y:self.currentY
                                                    speed:self.speed];
    [self postAPIRequest:gCode];
}

- (void)postAPIRequest:(NSString *)gcode
{
    [self postAPIRequest:gcode isStartCode:NO];
}

- (void)postAPIRequest:(NSString *)gcode isStartCode:(BOOL)isStartCode
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

@end