#import "MSCViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MSCGCodeStandards.h"

NSInteger xPos;
NSInteger yPos;
CGFloat zPos;
int speed = 2000;
int buttonTag = 1;
CGFloat extrusion = 0;

NSString * ipAddress = @"10.1.3.47";
NSInteger stepDistance = 50;
bool firstCode;


@interface MSCViewController ()

@property(nonatomic, strong) MSCGCodeStandards *gCodeStandards;
@end

@implementation MSCViewController

- (void)loadView
{
    
    self.gCodeStandards = [[MSCGCodeStandards alloc] init];
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];

    CGRect startButtonFrame = CGRectMake((320 - 100) * 0.5, 100, 100, 47);
    [self createButtonWithTitle:@"Start" withFrame:startButtonFrame];

    CGRect stopButtonFrame = CGRectMake((320 - 100) * 0.5, 500, 100, 47);
    [self createButtonWithTitle:@"Stop" withFrame:stopButtonFrame];

    CGRect zButtonFrame = CGRectMake((320 - 100) * 0.5, 300, 100, 47);
    [self createButtonWithTitle:@"Z" withFrame:zButtonFrame];

    CGRect upButtonFrame = CGRectMake((320 - 100) * 0.5, 200, 100, 47);
    [self createButtonWithTitle:@"^" withFrame:upButtonFrame];

    CGRect leftButtonFrame = CGRectMake(0, 300, 100, 47);
    [self createButtonWithTitle:@"<" withFrame:leftButtonFrame];

    CGRect rightButtonFrame = CGRectMake(220, 300, 100, 47);
    [self createButtonWithTitle:@">" withFrame:rightButtonFrame];

    CGRect downButtonFrame = CGRectMake((320 - 100) * 0.5, 400, 100, 47);
    [self createButtonWithTitle:@"v" withFrame:downButtonFrame];
}

- (void)createButtonWithTitle:(NSString *)string withFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:string forState:UIControlStateNormal];
    button.tag = buttonTag;
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchDown];
    buttonTag++;
    [self.view addSubview:button];
}

- (void)didTapButton:(id)sender
{
    NSString *gCode;
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;

    NSLog(@"sender tag %d", [sender tag]);
    
    switch ([sender tag]) {
        case 1:
            gCode = self.gCodeStandards.startCode;
            break;
        case 2:
            gCode = self.gCodeStandards.stopCode;
            [self reset];
            break;
        case 3:
            zPos += self.gCodeStandards.layerHeight;
            gCode = [NSString stringWithFormat:@"G%d Z%f", 1, zPos];
            break;
        case 4:
            yPos += stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case 5:
            xPos -= stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case 6:
            xPos += stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        case 7:
            yPos -= stepDistance;
            extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];
            gCode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];
            break;
        default:
            NSLog(@"default case");
            break;
    }

    if(xPos >=0 && xPos <=200 && yPos >=0 && xPos <= 200)
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
