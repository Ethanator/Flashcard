//
//  FCDeckCollectionViewCell.h
//  Flashcard
//
//  Created by Student on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCDeckCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *deckName;
@property (weak, nonatomic) IBOutlet UIImageView *deckImageView;



@end