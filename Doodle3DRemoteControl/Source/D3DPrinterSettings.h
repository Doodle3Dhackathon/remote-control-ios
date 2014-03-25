#import <Foundation/Foundation.h>

@interface D3DPrinterSettings : NSObject

+ (NSString *)startCode;

+ (NSString *)stopCode;

- (NSString *)codeToMoveZ;

- (NSString *)codeToMoveRelativeX:(CGFloat)relativeX y:(CGFloat)relativeY speed:(CGFloat)speed;

- (CGFloat)calculateExtrusionForRelativeX:(CGFloat)dx y:(CGFloat)dy;

@end
