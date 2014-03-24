#import "D3DGCodeGenerator.h"

@implementation D3DGCodeGenerator

+ (NSString *)startCode
{
    return @"M109 S220 ;set target temperature\n"
            "G21 ;metric values\n"
            "G91 ;relative positioning\n"
            "M107 ;start with the fan off\n"
            "G28 X0 Y0 ;move X/Y to min endstops\n"
            "G28 Z0 ;move Z to min endstops\n"
            "G1 Z15 F9000 ;move the platform down 15mm\n"
            "G92 E0 ;zero the extruded length\n"
            "G1 F200 E10 ;extrude 10mm of feed stock\n"
            "G92 E0 ;zero the extruded length again\n"
            "G92 E0 ;zero the extruded length again\n"
            "G1 F9000\n"
            "G90 ;absolute positioning\n"
            "G1 Z0.1\n"
            "M117 Printing Marijn&Marco   ;display message (20 characters to clear whole screen)',";
}

+ (NSString *)stopCode
{
    return @"M107 ;fan off\n"
            "G91 ;relative positioning\n"
            "G1 E-1 F300 ;retract the filament a bit before lifting the nozzle, to release some of the pressure\n"
            "G1 Z+3.5 E-5 X-20 Y-20 F9000 ;move Z up a bit and retract filament even more\n"
            "G28 X0 Y0 ;move X/Y to min endstops, so the head is out of the way\n"
            "M84 ;disable axes / steppers\n"
            "G90 ;absolute positioning\n"
            "M104 S180\n"
            "M117 Done ;display message (20 characters to clear whole screen)";
}

+ (NSString *)moveCodeWithZ:(CGFloat)z
{
    return [NSString stringWithFormat:@"G1 Z%f", z];

}
@end