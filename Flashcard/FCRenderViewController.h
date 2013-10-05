//
//  FCRenderViewController.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCCardCollectionViewCell.h"


@protocol FCRenderViewControllerDelegate
-(void) didCollectFront:(NSString *)front andDidCollectBack:(NSString *)back;
@end


@interface FCRenderViewController : UIViewController
@property (nonatomic, strong) NSURL * resourceURL;
@property (nonatomic, weak) id<FCRenderViewControllerDelegate> delegate;
@end
