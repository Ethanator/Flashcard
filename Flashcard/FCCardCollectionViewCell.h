//
//  FCCardCollectionViewCell.h
//  Flashcard
//
//  Created by Shuyang Li on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCCardImageView.h"

@interface FCCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet FCCardImageView *cardView;

@end
