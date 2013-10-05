//
//  FCCardCollectionViewCell.h
//  Flashcard
//
//  Created by Shuyang Li on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cardView;

- (void)flipCardAtPoint:(CGFloat)point;

@end
