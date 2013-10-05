//
//  FCDeckCollectionViewController.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@interface FCDeckCollectionViewController : UICollectionViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>


@end
