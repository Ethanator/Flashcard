//
//  FCDeckCollectionViewCell.m
//  Flashcard
//
//  Created by Student on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCDeckCollectionViewCell.h"
#import "FCDeckCollectionViewController.h"
#import "Constants.h"
#import "Deck.h"

@implementation FCDeckCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)rename:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERT_VIEW_RENAME_FILE
                                                        message:ALERT_VIEW_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:ALERT_VIEW_CANCEL_BUTTON
                                              otherButtonTitles:ALERT_VIEW_OTHER_BUTTON];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
}

- (void)delete:(id)sender {
    [(FCDeckCollectionViewController*)[(UICollectionView*)self.superview delegate] deleteCell:self];
}

// This alert view prompts the user to type in the name of the deck to be created
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [(FCDeckCollectionViewController*)[(UICollectionView*)self.superview delegate] changeNameOfCell:self name:name];
    }
}

@end