#import "D3DPrinterSettings.h"

@interface D3DPrinterSettings ()
@property(nonatomic, readwrite) CGFloat bottomFlowRate;
@property(nonatomic, readwrite) CGFloat filamentThickness;
@property(nonatomic, readwrite) CGFloat layerHeight;
@property(nonatomic, readwrite) CGFloat wallthickness;
@end

@implementation D3DPrinterSettings

- (id)init
{
    self = [super init];

    if (self)
    {
        self.wallthickness = 0.5;
        self.layerHeight = 0.2;
        self.filamentThickness = 2.89;
        self.bottomFlowRate = 2.0;
    }

    return self;
}

- (CGFloat)calculateExtrusionWithTargetX:(CGFloat)targetX targetY:(CGFloat)targetY currentX:(CGFloat)x currentY:(CGFloat)y
{
    CGFloat dx = targetX - x;
    CGFloat dy = targetY - y;
    CGFloat dist = (CGFloat) sqrt(dx * dx + dy * dy);

    CGFloat extruder;
    extruder = (CGFloat) (dist * self.wallthickness * self.layerHeight / (pow((self.filamentThickness * 0.5), 2) * M_PI) * self.bottomFlowRate);
    return extruder;
}

@end