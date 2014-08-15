//
//  FDPath.h
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>

// a point object that can be stored in arrays
@interface FDPoint : NSObject

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;

- (id)initWithCGPoint:(CGPoint)point;

@end

// a path consisting of a color and multiple way points
@interface FDPath : NSObject

// the points of this path
@property (nonatomic, strong, readonly) NSMutableArray *points;

// the color of this path
@property (nonatomic, strong, readonly) UIColor *color;

- (id)initWithColor:(UIColor *)color;
- (id)initWithPoints:(NSArray *)points color:(UIColor *)color;

// parse from a JSON representation
+ (FDPath *)parse:(NSDictionary *)dictionary;

// serialize to a JSON representation
- (NSDictionary *)serialize;

// add a point to this path
- (void)addPoint:(CGPoint)point;

@end
