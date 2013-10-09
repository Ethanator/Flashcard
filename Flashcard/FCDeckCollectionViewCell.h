//
//  FCDeckCollectionViewCell.h
//  Flashcard
//
//  Created by Student on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCDeckCollectionViewCell; // Forward declare Custom Cell for the property

@protocol MyMenuDelegate <NSObject>
@end

@interface FCDeckCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *deckName;
@property (weak, nonatomic) IBOutlet UIImageView *deckImageView;
@property (weak, nonatomic) id<MyMenuDelegate> delegate;
@property int index;

@end