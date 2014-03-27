#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

@interface D3DPrinterService : NSObject

@property(nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

- (id)initWithIPAddress:(NSString *)ipAddress;

- (void)queuePostParameters:(NSDictionary *)postParameters;
@end