//
//  FDPath.m
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FDPath.h"

@interface FDPoint ()

@property (nonatomic, readwrite) CGFloat x;
@property (nonatomic, readwrite) CGFloat y;

@end

@implementation FDPoint

- (id)initWithCGPoint:(CGPoint)point
{
    self = [super init];
    if (self != nil) {
        self->_x = point.x;
        self->_y = point.y;
    }
    return self;
}

+ (FDPoint *)parse:(id)obj
{
    // parse a point from a JSON representation
    if (![obj isKindOfClass:[NSDictionary class]]) {
        // wrong type, parsing failed
        return nil;
    }

    NSDictionary *dictionary = (NSDictionary *)obj;
    if (![dictionary[@"x"] isKindOfClass:[NSNumber class]]) {
        // no required value "x" found or wrong type, parsing failed
        return nil;
    }
    if (![dictionary[@"y"] isKindOfClass:[NSNumber class]]) {
        // no required value "y" found or wrong type, parsing failed
        return nil;
    }

    // parse point into CGPoint and convert to FDPoint
    CGPoint point = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);
    return [[FDPoint alloc] initWithCGPoint:point];
}

@end

@interface FDPath ()

@property (nonatomic, strong, readwrite) NSMutableArray *points;
@property (nonatomic, strong, readwrite) UIColor *color;

@end

@implementation FDPath

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self != nil) {
        self->_points = [NSMutableArray array];
        self->_color = color;
    }
    return self;
}

- (id)initWithPoints:(NSMutableArray *)points color:(UIColor *)color
{
    self = [super init];
    if (self != nil) {
        self->_points = [points mutableCopy];
        self->_color = color;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [self.points addObject:[[FDPoint alloc] initWithCGPoint:point]];
}

+ (FDPath *)parse:(NSDictionary *)dictionary
{
    // parse a FDPath from a JSON representation

    if (![dictionary[@"color"] isKindOfClass:[NSNumber class]]) {
        // no required value "color" found or wrong type, parsing failed
        return nil;
    }
    if (![dictionary[@"points"] isKindOfClass:[NSArray class]]) {
        // no required value "points" found or wrong type, parsing failed
        return nil;
    }

    // parse the color into UIColor
    UIColor *color = [FDPath parseColor:dictionary[@"color"]];

    // parse the points into an array
    NSArray *rawPoints = dictionary[@"points"];
    NSMutableArray *points = [NSMutableArray array];
    for (id obj in rawPoints) {
        FDPoint *point = [FDPoint parse:obj];
        if (point != nil) {
            // parsing succeeded add to path
            [points addObject:point];
        } else {
            // parsing failed, ignore and output warning
            NSLog(@"Not a valid point: %@", obj);
        }
    }
    return [[FDPath alloc] initWithPoints:points color:color];
}

- (NSDictionary *)serialize
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    // convert the color into it's JSON representation
    dictionary[@"color"] = [FDPath serializeColor:self.color];

    // add all points to the dictionary
    NSMutableArray *points = [NSMutableArray array];
    for (FDPoint *point in self.points) {
        [points addObject:@{ @"x": [NSNumber numberWithInteger:point.x], @"y": [NSNumber numberWithInteger:point.y]}];
    }
    dictionary[@"points"] = points;

    return dictionary;
}

+ (UIColor *)parseColor:(NSNumber *)number
{
    // convert an integer into a UIColor
    NSInteger integer = [number integerValue];
    CGFloat alpha = ((integer >> 24) & 0xff)/255.0;
    CGFloat red = ((integer >> 16) & 0xff)/255.0;
    CGFloat green = ((integer >> 8) & 0xff)/255.0;
    CGFloat blue = (integer & 0xff)/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSNumber *)serializeColor:(UIColor *)color
{
    // convert a UIColor into a 32 bit integer
    uint32_t integer = 0;
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    integer += ((int)(alpha * 255) & 0xff) << 24;
    integer += ((int)(red * 255) & 0xff) << 16;
    integer += ((int)(green * 255) & 0xff) << 8;
    integer += ((int)(blue * 255) & 0xff);
    return [NSNumber numberWithInteger:integer];
}

@end
