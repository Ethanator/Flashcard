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
#import "FCCaptureImageViewController.h"
#import "FCRenderViewController.h"
#import "Constants.h"
#import <CoreText/CoreText.h>


@interface FCCardCollectionViewController () <FCCaptureImageViewControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FCRenderViewControllerDelegate>

@property (nonatomic, strong) NSURL *resourceURL;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@property BOOL imageJustCaptured;

// methods to handle different types of inputs
- (void)renderText;
- (void)promptURL;
- (void)cameraButtonTapped:(id)sender;
- (void)getImageFromPhotos;

// methods to handle UIAlertView actions, coming from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@implementation FCCardCollectionViewController

- (NSManagedObjectContext *)managedObjectContext {
	if (!_managedObjectContext) _managedObjectContext = self.deck.managedObjectContext;
	return _managedObjectContext;
}

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
//		self.resourceURL = [[NSUserDefaults standardUserDefaults] objectForKey:EXTERNALLY_OPENED_URL_DEFAULTS];
		NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:EXTERNALLY_OPENED_URL_DEFAULTS];//self.resourceURL.path;
		self.resourceURL = [NSURL fileURLWithPath:string];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:EXTERNALLY_OPENED_URL_DEFAULTS];
		[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.imageJustCaptured) {
		self.imageJustCaptured = NO;
		[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
	}
	
	[self appIntoForeground];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = self.deck.name;
	

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:CARD_TO_RENDER_SEGUE_IDENTIFIER])
	{
		FCRenderViewController* renderVC = segue.destinationViewController;
		renderVC.delegate = self;
		renderVC.resourceURL = self.resourceURL;
	} else if([segue.identifier isEqualToString:SHOW_CAMERA_SEGUE])
	{
		FCCaptureImageViewController* renderVC = segue.destinationViewController;
		renderVC.delegate = self;
	}
	[super prepareForSegue:segue sender:sender];
}

-(void)captureImageViewControllerDidCaptureImage:(UIImage *)image
{
	NSData *imageData = UIImagePNGRepresentation(image);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"tempImage.png"]];
	
	NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
		NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
		NSLog(@"the cachedImagedPath is %@",imagePath);
	}
	
	self.resourceURL = [NSURL fileURLWithPath:imagePath];
	
	self.imageJustCaptured = YES;
		
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
	
	// appearance
	CGColorRef border = CELL_BORDER_COLOR.CGColor;
	cell.layer.borderColor = border;
	cell.layer.borderWidth = CELL_BORDER_WIDTH;
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger cardIndex = indexPath.row;
	
	NSSet* cards = self.deck.cards;
	int index = [[(Card *)[cards anyObject] index] intValue];
	index++;
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
							NSLog(@"Front image path:%@", cardToBeChanged.frontImagePath);
						} else {
							viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
							
							NSLog(@"Back image path:%@", cardToBeChanged.backImagePath);
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

		NSLog((@"pre writing to file"));
	if (![imageData writeToFile:imagePath atomically:NO])
	{
		NSLog((@"Failed to cache image data to disk"));
	}
	else
	{
		NSLog(@"the cachedImagedPath is %@",imagePath);
	}
	
	self.resourceURL = [NSURL URLWithString:imagePath];

	
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
			// camera case
#warning Custom Camera Protocol
			[self performSegueWithIdentifier:SHOW_CAMERA_SEGUE sender:self];
			
//			[self cameraButtonTapped:self];
			break;
			
		case 3:
			// photos case
			[self getImageFromPhotos];
			break;
			
		default:
			break;
	}
	
}

// method to handle image case
- (void)cameraButtonTapped:(id)sender
{
	
	[self startCameraControllerFromViewController:self
																	usingDelegate:self];
	
//	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//	} else {
//		[[[UIAlertView alloc] initWithTitle:@"No Camera Available"
//									message:nil
//								   delegate:self
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
//		return;
//	}
//	picker.delegate = self;
//	[self presentViewController:picker animated:YES completion:nil];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
																	 usingDelegate: (id <UIImagePickerControllerDelegate,
																									 UINavigationControllerDelegate>) delegate {
	
	if (([UIImagePickerController isSourceTypeAvailable:
				UIImagePickerControllerSourceTypeCamera] == NO)
			|| (delegate == nil)
			|| (controller == nil))
		return NO;
	
	
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
		
	// Hides the controls for moving & scaling pictures, or for
	// trimming movies. To instead show the controls, use YES.
	cameraUI.allowsEditing = NO;
	
	cameraUI.delegate = delegate;
	
	[controller presentViewController:cameraUI animated:YES completion:nil];
	return YES;
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

-(void) getImageFromPhotos
{
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	
	// Hides the controls for moving & scaling pictures, or for
	// trimming movies. To instead show the controls, use YES.
	cameraUI.allowsEditing = NO;
	
	cameraUI.delegate = self;
	
	[self presentViewController:cameraUI animated:YES completion:nil];
}

// method to handle UIAlertView action, from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ([alertView.title isEqualToString:PROMPT_FOR_TEXT_TITLE]) {
		
		if (buttonIndex == 0) {
			NSLog(@"User Canceled with the cancel button.");
			return;
		} else if (buttonIndex == 1) {
			
			NSString * stringToRender = [alertView textFieldAtIndex:0].text;
						
			NSString *html = [NSString stringWithFormat:@"<html><head><style> div { min-height: 100%;} p { margin: 0 auto;font-size: 10em; test-align: center; vertical-align: middle; word-wrap: break-word; font-family: \"Georgia\", serif; }</style></head> <body><div><p>%@</p></div></body></html>", stringToRender];
						
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
			self.resourceURL = [NSURL URLWithString:fileURL];
			[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
		}
	}
}

// required method from FCRenderViewControllerDelegate
- (void)didCollectFrontPath:(NSString *)front andBackPath:(NSString *)back {
	
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:CARD_ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
	card.frontImagePath = front;
	card.backImagePath = back;
	card.frontUp = [NSNumber numberWithBool:FALSE];
	card.deck = self.deck;
	card.index = [NSNumber numberWithInt:[self.deck.cards count] - 1];
	
	NSLog(@"front: %@\n", card.frontImagePath);
	NSLog(@"back: %@\n", card.backImagePath);
	NSLog(@"deck: %@\n", card.deck.name);
	NSLog(@"index: %@", card.index);
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
	[self.collectionView reloadData];
	
	NSInteger cardIndex = [card.index integerValue];
	
	// find the card in deck
	Card *cardToBeChanged = [[self.deck.cards objectsPassingTest:^(id obj,BOOL *stop){
		Card *cardInDeck = (Card *)obj;
		NSInteger indexOfCardInDeck = [cardInDeck.index doubleValue];
		BOOL r = (cardIndex == indexOfCardInDeck);
		return r;
	}] anyObject];
	
	// change the model
	cardToBeChanged.frontUp = [NSNumber numberWithBool:![cardToBeChanged.frontUp boolValue]];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cardIndex inSection:1];
	
	// update the view
	FCCardCollectionViewCell *viewCell = (FCCardCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
	
	[UIView transitionWithView:viewCell.cardView
					  duration:FLIPPING_ANIMATION_DURATION
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					animations:^{
						if ([cardToBeChanged.frontUp boolValue]) {
							viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.frontImagePath];
							NSLog(@"Front image path:%@", cardToBeChanged.frontImagePath);
						} else {
							viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
							
							NSLog(@"Back image path:%@", cardToBeChanged.backImagePath);
						}
					} completion:NULL];

	

}

// methods to set the appearance
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewLayout*)collectionViewLayout
		insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(10, 10, 10, 10);
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	NSError * error;
	[self.deck.managedObjectContext save:&error];
	if (error)
	{
		NSLog(@"error saving document: %@", error);
	}
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(cut:)) {
        return YES;
    }
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(cut:))
	{
		int itemIndex = [indexPath indexAtPosition:1];
        
        Card *cardToBeDeleted = [[self.deck.cards objectsPassingTest:^(id obj,BOOL *stop){
            Card *cardInDeck = (Card *)obj;
            BOOL r = ([cardInDeck.index integerValue] == itemIndex);
            return r;
        }] anyObject];

        NSMutableSet *tmpSet = [self.deck.cards mutableCopy];
        [tmpSet removeObject:cardToBeDeleted];
        self.deck.cards = tmpSet;
		
		for (Card* card in self.deck.cards)
		{
			if ([card.index intValue] > itemIndex)
			{
				card.index = [NSNumber numberWithInt:([card.index intValue] - 1)];
			}
		}
		
		//[self.deck.cards.databaseContext deleteObject:cardToBeDeleted];
		[self.collectionView reloadData];
	}
}


@end
