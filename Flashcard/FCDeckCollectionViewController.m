//
//  FCDeckCollectionViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCDeckCollectionViewController.h"
#import "FCDeckCollectionViewCell.h"
#import "FCCardCollectionViewController.h"
#import "Deck.h"

@interface FCDeckCollectionViewController ()

@property (strong, nonatomic) NSArray *decks;
@property (strong, nonatomic) Deck *selectedDeck;

@end

@implementation FCDeckCollectionViewController

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
	
	//pull card decks from core data database
	/***** REMEMBER THIS IS NOT PERFORMED IN THE MAIN THREAD. DON'T EXPECT THERE TO BE ANY DECKS READY AFTER THIS METHOD *****/
	//also, this method draws a UIActivityIndicator on top of the view. It also gets rid of it afterward.
	[self pullCoreData];
	
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
	return [self.decks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DECK_COLLECTION_VIEW_CELL_IDENTIFIER forIndexPath:indexPath];
	if ([cell isKindOfClass:[FCDeckCollectionViewCell class]]) {
		FCDeckCollectionViewCell *viewCell = (FCDeckCollectionViewCell *)cell;
        
        
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Save the index of the selected deck
    // Have a private property that is the selected item
    self.selectedDeck = self.decks[indexPath.row];
    [self performSegueWithIdentifier:DECK_TO_CARD_SEGUE_IDENTIFIER sender:self];
    // Perform segue, identify the segue, in the segue set Shuyang's public variables
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:DECK_TO_CARD_SEGUE_IDENTIFIER]) {
        FCCardCollectionViewController *viewController = segue.destinationViewController;
        viewController.deck = self.selectedDeck;
    }
    [super prepareForSegue:segue sender:sender];
}

- (void)pullCoreData {
	
	//start the activity indicator
#warning activity indicator
	
	//get the bundle documents URL
	NSURL * databaseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	databaseURL = [databaseURL URLByAppendingPathComponent:FLASHCARD_DATA_MODEL_NAME];
	
	//create a managed document from the douments URl and the appended the model's name
	UIManagedDocument * databaseDocument = [[UIManagedDocument alloc] initWithFileURL:databaseURL];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[databaseURL path]])
	{
		[databaseDocument openWithCompletionHandler:^(BOOL success) {
			
			//turn off the activity indicator
#warning activity indicator

			if (success)
			{
				//pull the data from the document
				[self documentIsReady:databaseDocument];
			}
			else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																			 message:nil
																			delegate:self
														 cancelButtonTitle:nil
														 otherButtonTitles: nil] show];
		}];
	}
	else
	{
		[databaseDocument saveToURL:databaseURL
										forSaveOperation:UIDocumentSaveForCreating
									 completionHandler:^(BOOL success){
										 
										 //turn off the activity indicator
#warning activity indicator

										 if (success)
										 {
											 //pull the data from the document
											 [self documentIsReady:databaseDocument];

											 //Put in a filler Deck because this is the first time the user has opened the app
											 [self firstTimeDeckInsert];
										 }
										 else [[[UIAlertView alloc] initWithTitle:@"Storage Error"
																											message:nil
																										 delegate:self
																						cancelButtonTitle:nil
																						otherButtonTitles: nil] show];
									 }];
	}

	
}

-(void)documentIsReady:(UIManagedDocument *)databaseDocument
{
	NSManagedObjectContext * databaseContext = databaseDocument.managedObjectContext;
	
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:DECK_ENTITY_NAME];
	// fetch the decks, store them to array
	
	NSError * error;
    if (!DEBUG) self.decks = [databaseContext executeFetchRequest:request error:&error];
    else {
        Deck *deck1 = [[Deck alloc] init];
        Deck *deck2 = [[Deck alloc] init];
        Deck *deck3 = [[Deck alloc] init];
        deck1.name = @"Ethan"; deck1.index = [NSNumber numberWithInt:0];
        deck2.name = @"Sean"; deck2.index = [NSNumber numberWithInt:1];
        deck3.name = @"Shuyang"; deck3.index = [NSNumber numberWithInt:2];
        
        self.decks = @[deck1, deck2, deck3];
    }
	[self.collectionView reloadData];}

-(void)firstTimeDeckInsert
{
	//Put in a filler Deck because this is the first time the user has opened the app
#warning filler deck for first time opening.
	[self.collectionView reloadData];
	
}



@end
