#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "D3DPrinterService.h"
#import "AFHTTPRequestOperation.h"
#import "D3DPrinterSettings.h"

@interface D3DPrinterService ()
@property(nonatomic) BOOL busy;
@property(nonatomic, strong) NSMutableArray *gCodeQueue;
@property(nonatomic, strong) NSString *ipAddress;
@end

@implementation D3DPrinterService

- (id)initWithIPAddress:(NSString *)ipAddress
{
    self = [self init];

    if (self)
    {
        self.ipAddress = ipAddress;

        self.gCodeQueue = [NSMutableArray array];
    }

    return self;
}

- (AFHTTPRequestOperationManager *)requestOperationManager
{
    if (!_requestOperationManager)
    {
        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
    }
    return _requestOperationManager;
}

- (void)queuePostParameters:(NSDictionary *)postParameters
{
    NSParameterAssert(self.gCodeQueue);
    [self.gCodeQueue addObject:postParameters];
    [self startPostingFromQueueUnlessBusy];
}

- (void)startPostingFromQueueUnlessBusy
{
    if (self.busy) return;
    [self postNextFromQueue];
}

- (void)postNextFromQueue
{
    if (![self.gCodeQueue count]) return;

    id gCodeParameters = [self.gCodeQueue objectAtIndex:0];
    [self.gCodeQueue removeObjectAtIndex:0];
    [self postAPIRequestWithGCodeParameters:gCodeParameters];
}

- (void)postAPIRequestWithGCodeParameters:(NSDictionary *)parameters
{
    self.busy = YES;

    NSString *URLString = [NSString stringWithFormat:@"http://%@/d3dapi/printer/print", self.ipAddress];
    [self.requestOperationManager POST:URLString
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   self.busy = NO;
                                   [self postNextFromQueue];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.busy = NO;
    }];
}

@end