#import <Foundation/Foundation.h>

@interface D3DGCodeGenerator : NSObject

+ (NSString *)startCode;
+ (NSString *)stopCode;

+ (NSString *)moveCodeWithZ:(CGFloat)z;
@end