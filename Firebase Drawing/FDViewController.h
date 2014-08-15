//
//  FDViewController.h
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FDDrawView.h"
#import "FDColorPickController.h"

@interface FDViewController : UIViewController<FDDrawViewDelegate, FDColorPickerDelegate>

@end
