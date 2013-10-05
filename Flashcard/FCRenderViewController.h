//
//  FCRenderViewController.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCRenderViewControllerDelegate

@required
-(void) didCollectFrontPath:(NSString *)front
								andBackPath:(NSString *)back;

@end


@interface FCRenderViewController : UIViewController
@property (nonatomic, strong) NSURL * resourceURL;
@property (nonatomic, weak) id<FCRenderViewControllerDelegate> delegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
