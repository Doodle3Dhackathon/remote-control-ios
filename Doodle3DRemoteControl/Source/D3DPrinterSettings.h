#import <Foundation/Foundation.h>

@interface D3DPrinterSettings : NSObject

@property(nonatomic, readonly) CGFloat wallthickness;
@property(nonatomic, readonly) CGFloat layerHeight;
@property(nonatomic, readonly) CGFloat filamentThickness;
@property(nonatomic, readonly) CGFloat bottomFlowRate;

- (CGFloat)calculateExtrusionWithTargetX:(CGFloat)targetX targetY:(CGFloat)targetY currentX:(CGFloat)x currentY:(CGFloat)y;
@end
