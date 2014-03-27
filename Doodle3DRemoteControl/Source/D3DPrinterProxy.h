#import <Foundation/Foundation.h>

@class D3DPrinterService;

@interface D3DPrinterProxy : NSObject

@property(nonatomic, strong) D3DPrinterService * printerService;

- (void)start;

- (void)stop;

- (void)moveZ;

- (void)moveYUp;

- (void)moveYDown;

- (void)moveXRight;

- (void)moveXLeft;

@end