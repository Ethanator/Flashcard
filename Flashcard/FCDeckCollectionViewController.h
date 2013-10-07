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
#import "FCDeckCollectionViewCell.h"

@interface FCDeckCollectionViewController : UICollectionViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

-(void)changeNameOfCell:(FCDeckCollectionViewCell*) cell name:(NSString *)name;
-(void)deleteCell:(FCDeckCollectionViewCell*) cell;
@end
