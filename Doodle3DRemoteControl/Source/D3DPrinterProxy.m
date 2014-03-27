#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterService.h"
#import "D3DPrinterSettings.h"
#import "D3DPrinterProxy.h"
#import "D3DPrinterSettings.h"
#import "D3DPrinterService.h"

@interface D3DPrinterProxy ()

@property(nonatomic) CGFloat extrusion;
@property(nonatomic, strong) D3DPrinterSettings *printerSettings;
@property(nonatomic) NSInteger stepDistance;
@property(nonatomic) CGFloat speed;
@end

@implementation D3DPrinterProxy

- (id)init
{
    self = [super init];

    if (self)
    {
        self.stepDistance = 50;
        self.speed = 2000;
    }

    return self;
}

- (D3DPrinterSettings *)printerSettings
{
    if(! _printerSettings)
    {
        self.printerSettings = [[D3DPrinterSettings alloc] init];
    }

    return _printerSettings;
}

- (D3DPrinterService *)printerService
{
    if(! _printerService)
    {
        self.printerService = [[D3DPrinterService alloc] initWithIPAddress:@"10.1.3.47"];
    }
    return _printerService;
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

    [self.printerService queuePostParameters:parameters];
}


@end