//
//  FDViewController.m
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FDViewController.h"

#import <Firebase/Firebase.h>
#import "FDDrawView.h"
#import "FDColorPickController.h"

// Replace this with your own Firebase
static NSString * const kFirebaseURL = @"https://android-drawing.firebaseio-demo.com";

@interface FDViewController ()

// The firebase this demo uses
@property (nonatomic, strong) Firebase *firebase;

// The current state of the paths drawn
@property (nonatomic, strong) NSMutableArray *paths;

// A view the user can draw on
@property (nonatomic, strong) FDDrawView *drawView;

// A button to choose a new color
@property (nonatomic, strong) UIButton *colorButton;

// A set of paths by this user that have not been acknowlegded by the server yet
@property (nonatomic, strong) NSMutableSet *outstandingPaths;

// The handle that was returned for observing child events
@property (nonatomic) FirebaseHandle childAddedHandle;

@end

@implementation FDViewController

- (id)init
{
    self = [super init];
    if (self != nil) {
        // initialize the firebase that is used for this sample
        self.firebase = [[Firebase alloc] initWithUrl:kFirebaseURL];

        // setup the state variables
        self.paths = [NSMutableArray array];
        self.outstandingPaths = [NSMutableSet set];

        // get a weak reference so we don't cause any retain cycles in tha callback block
        __weak FDViewController *weakSelf = self;

        // New drawings will appear as child added events
        self.childAddedHandle = [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            if ([weakSelf.outstandingPaths containsObject:snapshot.key]) {
                // this was drawn by this device and already taken care of by our draw view, ignore
            } else {
                // parse the path into our internal format
                FDPath *path = [FDPath parse:snapshot.value];
                if (path != nil) {
                    // the parse was successful, add it to our view
                    if (weakSelf.drawView != nil) {
                        [weakSelf.drawView addPath:path];
                    }
                    // keep track of the paths so far
                    [weakSelf.paths addObject:path];
                } else {
                    // there was an error parsing the snapshot, log an error
                    NSLog(@"Not a valid path: %@ -> %@", snapshot.key, snapshot.value);
                }
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    // make sure there are no outstanding observers
    [self.firebase removeObserverWithHandle:self.childAddedHandle];
}

- (void)colorButtonPressed
{
    // the user decided to choose a new color, present the color picker view controller modally
    FDColorPickController *cpc = [[FDColorPickController alloc] initWithColor:self.drawView.drawColor];

    // set the color picker delegate to self
    cpc.delegate = self;

    // wrap the color picker view controller into a navigation view controller for over 9000 beauty
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:cpc];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:vc animated:YES completion:nil];
}

- (void)colorPicker:(FDColorPickController *)colorPicker didPickColor:(UIColor *)color
{
    // the user chose a new color, update the drawing view
    self.drawView.drawColor = color;
}

- (void)drawView:(FDDrawView *)view didFinishDrawingPath:(FDPath *)path
{
    // the user finished drawing a path
    Firebase *pathRef = [self.firebase childByAutoId];

    // get the name of this path which serves as a global id
    NSString *name = pathRef.key;

    // remember that this path was drawn by this user so it's not drawn twice
    [self.outstandingPaths addObject:name];

    // save the path to Firebase
    [pathRef setValue:[path serialize] withCompletionBlock:^(NSError *error, Firebase *ref) {
        // The path was successfully saved and can now be removed from the outstanding paths
        [self.outstandingPaths removeObject:name];
    }];
}

- (void)loadView
{
    // load and setup views

    // this is the main view and used to show drawing from other users and let the user draw
    self.drawView = [[FDDrawView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];

    // make sure it's resizable to fit any device size
    self.drawView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // add any paths that were already received from Firebase
    for (FDPath *path in self.paths) {
        [self.drawView addPath:path];
    }

    // make sure the user can draw on this view
    self.drawView.userInteractionEnabled = YES;

    // set the delegate of this view to self
    self.drawView.delegate = self;

    // create the color button
    self.colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    // make button over 9000 beauty
    self.colorButton.layer.cornerRadius = 10;
    self.colorButton.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    self.colorButton.layer.borderColor = self.colorButton.tintColor.CGColor;
    self.colorButton.layer.borderWidth = 1;
    [self.colorButton setTitle:@"Color" forState:UIControlStateNormal];

    // make sure clicks on the button call our method
    [self.colorButton addTarget:self
                         action:@selector(colorButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];

    // ensure the button has the right size and position
    CGSize viewSize = self.drawView.frame.size;
    CGSize buttonSize = CGSizeMake(100, 40);
    self.colorButton.frame = CGRectMake(viewSize.width - buttonSize.width - 20,
                                        viewSize.height - buttonSize.height - 20,
                                        buttonSize.width,
                                        buttonSize.height);
    self.colorButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;

    // add the button to the draw view
    [self.drawView addSubview:self.colorButton];

    // finally set the view of this view controller to the draw view
    self.view = self.drawView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
        self.drawView = nil;
        self.colorButton = nil;
    }
}

@end
