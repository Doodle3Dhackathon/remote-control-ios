#import <Foundation/Foundation.h>

@interface MSCGCodeStandards : NSObject

@property(nonatomic, readonly)CGFloat wallthickness;
@property(nonatomic, readonly)CGFloat layerHeight;
@property(nonatomic, readonly)CGFloat filamentThickness;
@property(nonatomic, readonly)CGFloat bottomFlowRate;
@property(nonatomic, copy) NSString *stopCode;
@property(nonatomic, copy) NSString *startCode;
@end
