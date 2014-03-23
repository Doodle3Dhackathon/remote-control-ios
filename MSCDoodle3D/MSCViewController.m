#import "MSCViewController.h"
#import "AFHTTPRequestOperationManager.h"

NSInteger xPos;
NSInteger yPos;
CGFloat zPos;
int speed = 2000;
int buttonTag = 1;

NSString * ipAddress = @"10.1.3.47";

NSInteger stepDistance = 50;

CGFloat extrusion = 0;
CGFloat wallthickness = 0.5;
CGFloat layerHeight = 0.2;
CGFloat filamentThickness = 2.89;
CGFloat bottomFlowRate = 2.;

bool firstCode;

@interface MSCViewController ()

@end

@implementation MSCViewController

- (void)loadView
{
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
            gCode = @
                "M109 S220 ;set target temperature\n"
                "G21 ;metric values\n"
                "G91 ;relative positioning\n"
                "M107 ;start with the fan off\n"
                "G28 X0 Y0 ;move X/Y to min endstops\n"
                "G28 Z0 ;move Z to min endstops\n"
                "G1 Z15 F9000 ;move the platform down 15mm\n"
                "G92 E0 ;zero the extruded length\n"
                "G1 F200 E10 ;extrude 10mm of feed stock\n"
                "G92 E0 ;zero the extruded length again\n"
                "G92 E0 ;zero the extruded length again\n"
                "G1 F9000\n"
                "G90 ;absolute positioning\n"
                "G1 Z0.1\n"
                "M117 Printing Marijn&Marco   ;display message (20 characters to clear whole screen)',";
            break;
        case 2:
            gCode = @"M107 ;fan off\n"
                    "G91 ;relative positioning\n"
                    "G1 E-1 F300 ;retract the filament a bit before lifting the nozzle, to release some of the pressure\n"
                    "G1 Z+3.5 E-5 X-20 Y-20 F9000 ;move Z up a bit and retract filament even more\n"
                    "G28 X0 Y0 ;move X/Y to min endstops, so the head is out of the way\n"
                    "M84 ;disable axes / steppers\n"
                    "G90 ;absolute positioning\n"
                    "M104 S180\n"
                    "M117 Done ;display message (20 characters to clear whole screen)";
            [self reset];
            break;
        case 3:
            zPos += layerHeight;
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

    CGFloat extruder = (CGFloat) (dist * wallthickness * layerHeight / (pow((filamentThickness * 0.5), 2) * M_PI) * bottomFlowRate);

    return extruder;
}
@end
