#import <Foundation/Foundation.h>

@interface D3DPrinterSettings : NSObject

@property(nonatomic, readonly) CGFloat wallthickness;
@property(nonatomic, readonly) CGFloat layerHeight;
@property(nonatomic, readonly) CGFloat filamentThickness;
@property(nonatomic, readonly) CGFloat bottomFlowRate;

+ (NSString *)startCode;

+ (NSString *)stopCode;

- (NSString *)codeToMoveZ;

- (NSString *)codeToMoveRelativeX:(CGFloat)relativeX y:(CGFloat)relativeY speed:(CGFloat)speed;

- (CGFloat)calculateExtrusionForRelativeX:(CGFloat)dx y:(CGFloat)dy;

@end
