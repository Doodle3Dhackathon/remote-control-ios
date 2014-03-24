#import <Foundation/Foundation.h>

@class D3DPrinterSettings;

@interface D3DPrinterProxy : NSObject
- (id)initWithIPAddress:(NSString *)ipAddress;

- (void)start;

- (void)stop;

- (void)moveUp;
@end