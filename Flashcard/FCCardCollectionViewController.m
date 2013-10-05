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
#import "UIImage+cameraOrientationFix.h"
#import "FCRenderViewController.h"
#import "Constants.h"
#import <CoreText/CoreText.h>


@interface FCCardCollectionViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FCRenderViewControllerDelegate>

@property (nonatomic, strong) NSURL *resourceURL;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

// methods to handle different types of inputs
- (void)renderText;
- (void)promptURL;
- (void)cameraButtonTapped:(id)sender;

// methods to handle UIAlertView actions, coming from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIntoForeground)
	 
																							 name:UIApplicationDidBecomeActiveNotification object:nil];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)appIntoForeground
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:EXTERNALLY_OPENED_URL_DEFAULTS])
	{
		self.resourceURL = [[NSUserDefaults standardUserDefaults] objectForKey:EXTERNALLY_OPENED_URL_DEFAULTS];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:EXTERNALLY_OPENED_URL_DEFAULTS];
		[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self appIntoForeground];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:CARD_TO_RENDER_SEGUE_IDENTIFIER])
	{
		FCRenderViewController* renderVC = segue.destinationViewController;
		renderVC.delegate = self;
		renderVC.resourceURL = self.resourceURL;
	}
	[super prepareForSegue:segue sender:sender];
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
	
//	if ([cardToBeChanged.frontUp boolValue]) {
//		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.frontImagePath];
//	} else {
//		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
//	}
	
	[UIView transitionWithView:viewCell.cardView
					  duration:FLIPPING_ANIMATION_DURATION
					   options:UIViewAnimationOptionTransitionFlipFromLeft 
					animations:^{
						if ([cardToBeChanged.frontUp boolValue]) {
							viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.frontImagePath];
						} else {
							viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
						}
					} completion:NULL];
	
}

- (IBAction)addCard:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ADD_CARD_ACTION_SHEET_TITLE
															 delegate:self
													cancelButtonTitle:ADD_CARD_CANCEL_BUTTON_TITLE
											   destructiveButtonTitle:ADD_CARD_DESTRUCTIVE_BUTTON_TITLE
													otherButtonTitles:ADD_CARD_OTHER_BUTTON_TITLES];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
}

// from UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *capturedimage = [info objectForKey:UIImagePickerControllerOriginalImage];
	capturedimage = [capturedimage fixOrientation];
		
//	NSInteger cardUniqueIDCounter = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
//	
//	[[NSUserDefaults standardUserDefaults] setInteger:(cardUniqueIDCounter + 1) forKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
//	
//	[[NSUserDefaults standardUserDefaults] synchronize];
		
	NSData *imageData = UIImagePNGRepresentation(capturedimage);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"tempImage.png"]];

	//	NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
		NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
		NSLog(@"the cachedImagedPath is %@",imagePath);
	}
	
	self.resourceURL = [NSURL fileURLWithPath:imagePath];

	
	[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
	
//	[self.collectionView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

// code from UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// as in <UIActionSheetDelegate>
	
	switch (buttonIndex) {
		case 0:
			// text case
			[self renderText];
			break;
			
		case 1:
			// web case
			[self promptURL];
			break;
			
		case 2:
			// image case
			[self cameraButtonTapped:self];
			break;
			
		default:
			break;
	}
	
}

// method to handle image case
- (void)cameraButtonTapped:(id)sender
{
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else {
		[[[UIAlertView alloc] initWithTitle:@"No Camera Available"
									message:nil
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		return;
	}
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:nil];
}

// method to handle text case
- (void)renderText {
	UIAlertView *promptForTextView = [[UIAlertView alloc] initWithTitle:PROMPT_FOR_TEXT_TITLE
																message:PROMPT_FOR_TEXT_MESSAGE
															   delegate:self
													  cancelButtonTitle:PROMPT_FOR_TEXT_CANCEL_BUTTON_TITLE
													  otherButtonTitles:PROMPT_FOR_TEXT_OTHER_BUTTON_TITLES];
	promptForTextView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[promptForTextView show];
}

// method to handle web case
- (void)promptURL {
	UIAlertView *promptForURLView = [[UIAlertView alloc] initWithTitle:PROMPT_FOR_URL_TITLE
																message:PROMPT_FOR_URL_MESSAGE
															   delegate:self
													  cancelButtonTitle:PROMPT_FOR_URL_CANCEL_BUTTON_TITLE
													  otherButtonTitles:PROMPT_FOR_URL_OTHER_BUTTON_TITLES];
	promptForURLView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[promptForURLView show];
}

// method to handle UIAlertView action, from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ([alertView.title isEqualToString:PROMPT_FOR_TEXT_TITLE]) {
		
		if (buttonIndex == 0) {
			NSLog(@"User Canceled with the cancel button.");
			return;
		} else if (buttonIndex == 1) {
			
			NSString * stringToRender = [alertView textFieldAtIndex:0].text;
						
			NSString *html = [NSString stringWithFormat:@"<html><head><style> div { text-align: center; display: table-cell; width: 200px; height: 150px; text-align: center; vertical-align: middle; } p { text-align: center; font-size: 4em; font-family: \"Georgia\", serif; }</style></head> <body><div><p>%@</p></div></body></html>", stringToRender];
						
			NSInteger cardUniqueIDCounter = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
			
			[[NSUserDefaults standardUserDefaults] setInteger:(cardUniqueIDCounter + 1) forKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
			
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *filePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.html",cardUniqueIDCounter]];
			NSError *error;
			
			if (![html writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:&error]) {
				NSLog((@"Failed to cache image data to disk"));
			} else {
				NSLog(@"the cachedImagedPath is %@",filePath);
			}
			
			self.resourceURL = [NSURL fileURLWithPath:filePath];
			
			[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
		}
		
	} else if ([alertView.title isEqualToString:PROMPT_FOR_URL_TITLE]) {
		if (buttonIndex == 0) {
			NSLog(@"User Canceled with the cancel button.");
			return;
		} else if (buttonIndex == 1) {
			NSString *fileURL = [alertView textFieldAtIndex:0].text;
			self.resourceURL = [NSURL fileURLWithPath:fileURL];
			[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
		}
	}
}

// required method from FCRenderViewControllerDelegate
- (void)didCollectFrontPath:(NSString *)front andBackPath:(NSString *)back {
	
	// Model
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:CARD_ENTITY_NAME inManagedObjectContext:self.deck.managedObjectContext];
	card.frontImagePath = front;
	card.backImagePath = back;
	card.frontUp = [NSNumber numberWithBool:FALSE];
	card.deck = self.deck;
	card.index = [NSNumber numberWithInt:[self.deck.cards count] + 1];
	
	[self.collectionView reloadData];
	// Save
	
	

}


@end
