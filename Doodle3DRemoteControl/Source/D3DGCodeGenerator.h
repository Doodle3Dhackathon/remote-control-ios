#import <Foundation/Foundation.h>

@interface D3DGCodeGenerator : NSObject

+ (NSString *)startCode;
+ (NSString *)stopCode;

+ (NSString *)moveCodeWithZ:(CGFloat)z;

+ (NSString *)generateMoveCodeForX:(CGFloat)x y:(CGFloat)y speed:(NSInteger)speed extrusion:(CGFloat)extrusion;
@end