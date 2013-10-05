//
//  FCCaptureImageViewController.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCCaptureImageViewControllerDelegate

-(void) captureImageViewControllerDidCaptureImage:(UIImage *) image;

@end

@interface FCCaptureImageViewController : UIViewController

@property (nonatomic, weak) id<FCCaptureImageViewControllerDelegate> delegate;

@end
