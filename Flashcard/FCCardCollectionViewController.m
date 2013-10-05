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

@interface FCCardCollectionViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSURL *resourceURL;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

// methods to handle different types of inputs
- (void)renderText;
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
	
	if ([cardToBeChanged.frontUp boolValue]) {
		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.frontImagePath];
	} else {
		viewCell.cardView.image = [UIImage imageWithContentsOfFile:cardToBeChanged.backImagePath];
	}
	
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


// code below from UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *capturedimage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[capturedimage fixOrientation];
	
	NSData *imageData = UIImagePNGRepresentation(capturedimage);
	
	NSInteger cardUniqueIDCounter = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	if (cardUniqueIDCounter) {
		cardUniqueIDCounter++;
	} else {
		cardUniqueIDCounter = 0;
	}
	
	[[NSUserDefaults standardUserDefaults] setInteger:(cardUniqueIDCounter + 1) forKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	
	self.resourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%d.png", cardUniqueIDCounter]];
	
	[imageData writeToURL:self.resourceURL atomically:YES];

	[self performSegueWithIdentifier:CARD_TO_RENDER_SEGUE_IDENTIFIER sender:self];
	
	
	// push imageData to RenderViewController
	
	[self.collectionView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

// code above from UIImagePickerControllerDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// as in <UIActionSheetDelegate>
	// push only for url
	// method for text
	// UIImagePickerController for camera
	
	switch (buttonIndex) {
		case 0:
			// text case
			[self renderText];
			break;
			
		case 1:
			// web case
			
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


// method to handle UIAlertView action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ([alertView.title isEqualToString:PROMPT_FOR_TEXT_CANCEL_BUTTON_TITLE]) {
		switch (buttonIndex) {
			case 1:
				// "cancel"
				break;
				
			case 2:
				// "done"
				// TO-DO: render text into image
				
				for (UIView *view in alertView.subviews) {
					if ([view isKindOfClass:[UITextField class]]) {
						UITextField *textField = (UITextField *)view;
						NSString *stringToRender = textField.text;
						
						UIFont *font = [UIFont systemFontOfSize:RENDERED_TEXT_SIZE];
						CGSize size = [stringToRender sizeWithAttributes:@{NSFontAttributeName : font}];
						
						UIGraphicsBeginImageContext(size);
						
						[stringToRender drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:@{NSFontAttributeName : font}];
						
						UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
						NSData *data = UIImagePNGRepresentation(image);
					}
				}
				
				// TO-DO: send image to render
				
				
			default:
				break;
		}
	}
}



@end
