//
//  FDColorPickController.h
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FDColorPickController;

@protocol FDColorPickerDelegate <NSObject>

- (void)colorPicker:(FDColorPickController *)colorPicker didPickColor:(UIColor *)color;

@end

@interface FDColorPickController : UIViewController

@property (nonatomic, weak) id<FDColorPickerDelegate> delegate;

- (id)initWithColor:(UIColor *)color;

@end
