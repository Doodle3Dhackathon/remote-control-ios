#import "D3DRemoteControlViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "D3DCodeStandards.h"
#import "D3DRemoteControlView.h"

NSInteger xPos;
NSInteger yPos;
CGFloat zPos;
int speed = 2000;
CGFloat extrusion = 0;

NSString *ipAddress = @"10.1.3.47";
NSInteger stepDistance = 50;
BOOL firstCode;

typedef NS_ENUM(NSInteger, D3DButtonTag)
{
    D3DButtonTagStart,
    D3DButtonTagStop,
    D3DButtonTagZ,
    D3DButtonTagUp,
    D3DButtonTagLeft,
    D3DButtonTagDown,
    D3DButtonTagRight
};

@interface D3DRemoteControlViewController ()

@property(nonatomic, strong) D3DCodeStandards *gCodeStandards;
@property(nonatomic, strong) id buttons;
@end

@implementation D3DRemoteControlViewController

- (void)loadView
{

    self.gCodeStandards = [[D3DCodeStandards alloc] init];
    self.view = [[D3DRemoteControlView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];

    CGRect startButtonFrame = CGRectMake((320 - 100) * 0.5, 100, 100, 47);
    [self createButtonWithTitle:@"Start" frame:startButtonFrame tag:D3DButtonTagStart];

    CGRect stopButtonFrame = CGRectMake((320 - 100) * 0.5, 500, 100, 47);
    [self createButtonWithTitle:@"Stop" frame:stopButtonFrame tag:D3DButtonTagStop];

    CGRect zButtonFrame = CGRectMake((320 - 100) * 0.5, 300, 100, 47);
    [self createButtonWithTitle:@"Z" frame:zButtonFrame tag:D3DButtonTagZ];

    CGRect upButtonFrame = CGRectMake((320 - 100) * 0.5, 200, 100, 47);
    [self createButtonWithTitle:@"^" frame:upButtonFrame tag:D3DButtonTagUp];

    CGRect leftButtonFrame = CGRectMake(0, 300, 100, 47);
    [self createButtonWithTitle:@"<" frame:leftButtonFrame tag:D3DButtonTagLeft];

    CGRect downButtonFrame = CGRectMake((320 - 100) * 0.5, 400, 100, 47);
    [self createButtonWithTitle:@"v" frame:downButtonFrame tag:D3DButtonTagDown];

    CGRect rightButtonFrame = CGRectMake(220, 300, 100, 47);
    [self createButtonWithTitle:@">" frame:rightButtonFrame tag:D3DButtonTagRight];
}

- (UIButton *)createButtonWithTitle:(NSString *)string frame:(CGRect)frame tag:(D3DButtonTag)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:string forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    return button;
}

- (void)didTapButton:(id)sender
{
    NSString *gCode;
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;

    NSLog(@"sender tag %d", [sender tag]);

    D3DButtonTag buttonTag = (D3DButtonTag) [sender tag];

    switch (buttonTag)
    {
        case D3DButtonTagStart:
            gCode = self.gCodeStandards.startCode;
            break;
        case D3DButtonTagStop:
            gCode = self.gCodeStandards.stopCode;
            [self reset];
            break;
        case D3DButtonTagZ:
            zPos += self.gCodeStandards.layerHeight;
            gCode = [NSString stringWithFormat:@"G%d Z%f", 1, zPos];
            break;
        case D3DButtonTagUp:
            yPos += stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case D3DButtonTagLeft:
            xPos -= stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case D3DButtonTagDown:
            yPos -= stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case D3DButtonTagRight:
            xPos += stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
    }

    if (xPos >= 0 && xPos <= 200 && yPos >= 0 && xPos <= 200)
    {
        [self apiPostRequest:gCode isFirst:firstCode];
    }
}

- (void)reset
{
    xPos = 0;
    yPos = 0;
    zPos = 0;
    extrusion = 0;
    firstCode = YES;
}

- (void)apiPostRequest:(NSString *)gcode isFirst:(BOOL)first
{
    NSLog(gcode);
    NSString *firstString = first ? @"true" : @"false";
    NSDictionary *parameters = @{@"start" : @"true", @"first" : firstString, @"gcode" : gcode};

    __block NSString *apiResponse;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *URLString = [NSString stringWithFormat:@"http://%@/d3dapi/printer/print", ipAddress];
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        apiResponse = [NSString stringWithFormat:@"JSON: %@", responseObject];
        NSLog(@"response succes is %@", apiResponse);
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        apiResponse = [NSString stringWithFormat:@"Error: %@", error];
        NSLog(@"response failure is %@", apiResponse);
    }];

    firstCode = NO;
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

@end
