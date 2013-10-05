//
//  FCCardCollectionViewController.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface FCCardCollectionViewController : UICollectionViewController

@property (strong, nonatomic) Deck *deck;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
