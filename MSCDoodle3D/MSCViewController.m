#import "MSCViewController.h"
#import "AFHTTPRequestOperationManager.h"

NSInteger xPos;
NSInteger yPos;
int speed = 1000;

NSInteger stepDistance = 50;

CGFloat extrusion = 0;
CGFloat wallthickness = 0.5;
CGFloat layerHeight= 0.2;
CGFloat filamentThickness= 2.89;
CGFloat bottomFlowRate = 2.;


@interface MSCViewController ()

@property(nonatomic, strong) UIButton *downButton;
@property(nonatomic, strong) UITextView *textView;

@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UIButton *upButton;
@property(nonatomic, strong) UIButton *zButton;
@property(nonatomic, strong) UIButton *startButton;
@property(nonatomic, strong) UIButton *stopButton;

@end

@implementation MSCViewController

- (void)loadView
{
    //[self getConfig];

    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];

    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect startButtonFrame = CGRectMake((320 - 100) * 0.5, 100, 100, 47);
    self.startButton.frame = startButtonFrame;
    self.startButton.backgroundColor = [UIColor blackColor];
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(didTapStartButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.startButton];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect stopButtonFrame = CGRectMake((320 - 100) * 0.5, 500, 100, 47);
    self.stopButton.frame = stopButtonFrame;
    self.stopButton.backgroundColor = [UIColor blackColor];
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(didTapStopButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.stopButton];

    self.zButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect zButtonFrame = CGRectMake((320 - 100) * 0.5, 300, 100, 47);
    self.zButton.frame = zButtonFrame;
    self.zButton.backgroundColor = [UIColor blackColor];
    [self.zButton setTitle:@"Z" forState:UIControlStateNormal];
    [self.zButton addTarget:self action:@selector(didTapZButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.zButton];

    self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect upButtonFrame = CGRectMake((320 - 100) * 0.5, 200, 100, 47);
    self.upButton.frame = upButtonFrame;
    self.upButton.backgroundColor = [UIColor blackColor];
    [self.upButton setTitle:@"Up" forState:UIControlStateNormal];
    [self.upButton addTarget:self action:@selector(didTapUpButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.upButton];

    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect leftButtonFrame = CGRectMake(0, 300, 100, 47);
    self.leftButton.frame = leftButtonFrame;
    self.leftButton.backgroundColor = [UIColor blackColor];
    [self.leftButton setTitle:@"Left" forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(didTapLeftButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.leftButton];

    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rightButtonFrame = CGRectMake(220, 300, 100, 47);
    self.rightButton.frame = rightButtonFrame;
    self.rightButton.backgroundColor = [UIColor blackColor];
    [self.rightButton setTitle:@"Right" forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(didTapRightButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.rightButton];

    self.downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect downButtonFrame = CGRectMake((320 - 100) * 0.5, 400, 100, 47);
    self.downButton.frame = downButtonFrame;
    self.downButton.backgroundColor = [UIColor blackColor];
    [self.downButton setTitle:@"Down" forState:UIControlStateNormal];

    [self.downButton addTarget:self action:@selector(didTapDownButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.downButton];
}

//- (void)getConfig
//{
//    __block NSDictionary *config;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:@"http://10.1.3.14/d3dapi/config/all" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        config = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:nil];
////        wallthickness = [config objectForKey:@"printer.wallThickness"];
//
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

- (void)apiPostRequest:(NSString *)gcode isFirst:(NSString *)first
{
    NSDictionary *parameters = @{@"start" : @"true", @"first" : first, @"gcode" : gcode};

    __block NSString *apiResponse;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:@"http://10.1.3.14/d3dapi/printer/print" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        apiResponse = [NSString stringWithFormat:@"JSON: %@", responseObject];
        NSLog(@"response succes is %@", apiResponse);
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        apiResponse = [NSString stringWithFormat:@"Error: %@", error];
        NSLog(@"response failure is %@", apiResponse);
    }];
}

- (void)didTapStopButton:(id)didTapStopButton
{
    NSString *stopCode = @"M107 ;fan off\n"
            "G91 ;relative positioning\n"
            "G1 E-1 F300 ;retract the filament a bit before lifting the nozzle, to release some of the pressure\n"
            "G1 Z+3.5 E-5 X-20 Y-20 F9000 ;move Z up a bit and retract filament even more\n"
            "G28 X0 Y0 ;move X/Y to min endstops, so the head is out of the way\n"
            "M84 ;disable axes / steppers\n"
            "G90 ;absolute positioning\n"
            "M104 S180\n"
            "M117 Done ;display message (20 characters to clear whole screen)";
    [self apiPostRequest:stopCode isFirst:@"false"];
}

- (void)didTapStartButton:(id)didTapStartButton
{
    NSString *startCode = @
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
            "G1 Z0.2\n"
            "M117 Printing Marijn&Marco   ;display message (20 characters to clear whole screen)',";

    NSLog(startCode);

    [self apiPostRequest:startCode isFirst:@"true"];

}

- (void)didTapZButton:(id)didTapZButton
{
}

- (void)didTapUpButton:(id)didTapUpButton
{
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;
    yPos += stepDistance;

    speed = 1000;
    
    extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];

    NSLog(@"extrusion %f", extrusion);

    NSString *gcode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];

    if (yPos <= 200)
    {
        [self apiPostRequest:gcode isFirst:@"false"];
    }
}


- (void)didTapLeftButton:(id)didTapLeftButton
{
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;
    xPos -= stepDistance;

    speed = 1000;

    extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];

    NSString *gcode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];

    if (xPos >= 0)
    {
        [self apiPostRequest:gcode isFirst:@"false"];
    }
}

- (void)didTapRightButton:(id)didTapRightButton
{
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;
    xPos += stepDistance;

    speed = 1000;

    extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];

    NSString *gcode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];

    if (xPos <= 200)
    {
        [self apiPostRequest:gcode isFirst:@"false"];
    }
}

- (void)didTapDownButton:(id)didTapRequestButton
{
    NSInteger currentX = xPos;
    NSInteger currentY = yPos;
    yPos -= stepDistance;

    speed = 1000;

    extrusion += [self calculateExtrusionWithtargetX:xPos targetY:yPos currentX:currentX currentY:currentY];

    NSString *gcode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", 1, xPos, yPos, speed, extrusion];

    if (yPos >= 0)
    {
        [self apiPostRequest:gcode isFirst:@"false"];
    }
}

- (CGFloat)calculateExtrusionWithtargetX:(NSInteger)targetX targetY:(NSInteger)targetY currentX:(NSInteger)x currentY:(NSInteger)y
{
//    var dx = targetX - drawX,
//            dy = targetY - drawY;
//    dist = Math.sqrt(dx * dx + dy * dy);
//
//    extruder += dist * settings.wallThickness * settings.layerHeight / (Math.pow((settings.filamentThickness/2), 2) * Math.PI) * settings.bottomFlowRate;

    NSInteger dx = targetX - x;
    NSInteger dy = targetY - y;
    CGFloat dist = (CGFloat) sqrt(dx * dx + dy * dy);

    CGFloat extruder = (CGFloat) (dist * wallthickness * layerHeight / (pow((filamentThickness*0.5),2) * M_PI) * bottomFlowRate);

    return extruder;
}
@end
