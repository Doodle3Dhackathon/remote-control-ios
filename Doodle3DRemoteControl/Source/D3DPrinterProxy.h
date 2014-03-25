#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

@interface D3DPrinterProxy : NSObject
@property(nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

- (id)initWithIPAddress:(NSString *)ipAddress;

- (void)start;

- (void)stop;

- (void)moveZ;

- (void)moveYUp;

- (void)moveYDown;

- (void)moveXRight;

- (void)moveXLeft;

@end