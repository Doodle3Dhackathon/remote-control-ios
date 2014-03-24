#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterSettings.h"
#import "D3DPrinterProxy.h"
#import "D3DPrinterSettings.h"
#import "D3DGCodeGenerator.h"

@interface D3DPrinterProxy ()
@property(nonatomic) CGFloat xPos;
@property(nonatomic) CGFloat yPos;
@property(nonatomic) CGFloat zPos;
@property(nonatomic) CGFloat extrusion;
@property(nonatomic, strong) NSString *ipAddress;
@property(nonatomic, strong) D3DPrinterSettings *gCodeStandards;
@property(nonatomic) NSInteger stepDistance;
@end

@implementation D3DPrinterProxy

- (id)initWithIPAddress:(NSString *)ipAddress
{
    self = [self init];

    if (self)
    {
        self.gCodeStandards = [[D3DPrinterSettings alloc] init];
        self.ipAddress = ipAddress;
        self.stepDistance = 50;
    }

    return self;
}

- (void)start
{
    NSString *gCode = [D3DGCodeGenerator startCode];
    [self postAPIRequest:gCode isStartCode:YES ];
}

- (void)stop
{
    NSString *gCode = [D3DGCodeGenerator stopCode];
    [self postAPIRequest:gCode];
}

- (void)moveZ
{
    self.zPos += self.gCodeStandards.layerHeight;
    NSString *gCode = [D3DGCodeGenerator moveCodeWithZ:self.zPos];
    [self postAPIRequest:gCode];
}

- (void)moveYUp
{
   self.yPos += self.stepDistance;
    NSString *gCode = [D3DGCodeGenerator generateMoveCodeForX:self.xPos y:self.yPos speed:0 extrusion:0];

}

- (void)moveYDown
{
}

- (void)reset
{
    self.xPos = 0.0;
    self.yPos = 0.0;
    self.zPos = 0.0;
    self.extrusion = 0.0;
}

- (CGFloat)calculateExtrusionWithtargetX:(NSInteger)targetX targetY:(NSInteger)targetY currentX:(NSInteger)x currentY:(NSInteger)y
{
    NSInteger dx = targetX - x;
    NSInteger dy = targetY - y;
    CGFloat dist = (CGFloat) sqrt(dx * dx + dy * dy);

    CGFloat extruder;
    extruder = (CGFloat) (dist * self.gCodeStandards.wallthickness * self.gCodeStandards.layerHeight / (pow((self.gCodeStandards.filamentThickness * 0.5), 2) * M_PI) * self.gCodeStandards.bottomFlowRate);
    return extruder;
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

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *URLString = [NSString stringWithFormat:@"http://%@/d3dapi/printer/print", self.ipAddress];
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        apiResponse = [NSString stringWithFormat:@"JSON: %@", responseObject];
        NSLog(@"response succes is %@", apiResponse);
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        apiResponse = [NSString stringWithFormat:@"Error: %@", error];
        NSLog(@"response failure is %@", apiResponse);
    }];
}

@end