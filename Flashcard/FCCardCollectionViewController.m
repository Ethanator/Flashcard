//
//  FCCardCollectionViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCCardCollectionViewController.h"
#import "FCCardCollectionViewCell.h"
#import "Deck.h"
#import "Card.h"
#import "Constants.h"

@interface FCCardCollectionViewController ()


@end

@implementation FCCardCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.deck.cards count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CARD_COLLECTION_VIEW_CELL_IDENTIFIER forIndexPath:indexPath];
	
	if ([cell isKindOfClass:[FCCardCollectionViewCell class]]) {
		
		FCCardCollectionViewCell *viewCell = (FCCardCollectionViewCell *)cell;
		
		NSInteger cardIndex = indexPath.row;
		
		// find which card in the deck is the card to display
		Card *cardToBeDisplayed = [[self.deck.cards objectsPassingTest:^(id obj,BOOL *stop){
			Card *cardInDeck = (Card *)obj;
			NSInteger indexOfCardInDeck = [cardInDeck.index doubleValue];
			BOOL r = (cardIndex == indexOfCardInDeck);
			return r;
		}] anyObject];
		
		// displaying image on UIImageView
		if ([cardToBeDisplayed.frontUp boolValue]) {
			viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeDisplayed.frontImagePath];
		} else {
			viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeDisplayed.backImagePath];
		}
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger cardIndex = indexPath.row;
	
	// find the card in deck
	Card *cardToBeChanged = [[self.deck.cards objectsPassingTest:^(id obj,BOOL *stop){
		Card *cardInDeck = (Card *)obj;
		NSInteger indexOfCardInDeck = [cardInDeck.index doubleValue];
		BOOL r = (cardIndex == indexOfCardInDeck);
		return r;
	}] anyObject];
	
	// change the model
	cardToBeChanged.frontUp = [NSNumber numberWithBool:![cardToBeChanged.frontUp boolValue]];
	
	// update the view
	FCCardCollectionViewCell *viewCell = (FCCardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
	if ([cardToBeChanged.frontUp boolValue]) {
		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.frontImagePath];
	} else {
		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
	}
	
}


@end
