#import "MSCViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface MSCViewController ()

@property(nonatomic, strong) UIButton *requestButton;
@property(nonatomic, strong) UITextView *textView;

@end

@implementation MSCViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];

    

    self.requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect continueButtonFrame = CGRectMake((320 - 286) * 0.5, 320, 286, 47);
    self.requestButton.frame = continueButtonFrame;
    self.requestButton.backgroundColor = [UIColor blackColor];
    [self.requestButton setTitle:@"Continue" forState:UIControlStateNormal];

    [[self.requestButton layer] setBorderWidth:0.8f];
    [[self.requestButton layer] setBorderColor:[UIColor whiteColor].CGColor];

    [self.requestButton addTarget:self action:@selector(didTapRequestButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.requestButton];
}

- (void)didTapRequestButton:(id)didTapRequestButton
{
    NSInteger g = 1;
    NSInteger x = 100;
    NSInteger y = 100;
    NSInteger f = 1000;
    CGFloat e = 0;

//    NSString *s = [NSString stringWithFormat:@"This is a %d test", n];

    NSString *gcode = [NSString stringWithFormat:@"G%d X%d Y%d F%d, E%f", g, x, y, f, e];
    NSString *first = @"true";
    [self apiPostRequest:gcode isFirst:first];

}


- (void)startUpPrinter
{

}

- (void)closePrinter
{

}

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

@end