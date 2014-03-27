#import "D3DRemoteControlViewController.h"
#import "D3DPrinterSettings.h"
#import "D3DRemoteControlView.h"
#import "D3DPrinterProxy.h"

int speed = 2000;
CGFloat extrusion = 0;

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

@property(nonatomic, strong) D3DPrinterProxy *printerProxy;
@end

@implementation D3DRemoteControlViewController

- (id)init
{
    self = [super init];

    if (self)
    {
        self.printerProxy = [[D3DPrinterProxy alloc] initWithIPAddress:@"10.1.3.47"];
    }

    return self;
}

- (void)loadView
{
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
    D3DButtonTag buttonTag = (D3DButtonTag) [sender tag];

    switch (buttonTag)
    {
        case D3DButtonTagStart:
            [self.printerProxy start];
            break;
        case D3DButtonTagStop:
            [self.printerProxy stop];
            break;
        case D3DButtonTagZ:
            [self.printerProxy moveZ];
            break;
        case D3DButtonTagUp:
            [self.printerProxy moveYUp];
            break;
        case D3DButtonTagLeft:
            [self.printerProxy moveXLeft];
            break;
        case D3DButtonTagDown:
            [self.printerProxy moveYDown];
            break;
        case D3DButtonTagRight:
            [self.printerProxy moveXRight];
            break;
    }
}



@end
