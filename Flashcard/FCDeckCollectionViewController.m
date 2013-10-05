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
#import <CoreData/CoreData.h>

@interface FCDeckCollectionViewController ()

@property (strong, nonatomic) NSArray *decks;
@property (strong, nonatomic) Deck *selectedDeck;
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;

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
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
	//pull card decks from core data database
	/***** REMEMBER THIS IS NOT PERFORMED IN THE MAIN THREAD. DON'T EXPECT THERE TO BE ANY DECKS READY AFTER THIS METHOD *****/
	//also, this method draws a UIActivityIndicator on top of the view. It also gets rid of it afterward.
	[self pullCoreData];
	
	[super viewDidAppear:animated];
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FCDeckCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DECK_COLLECTION_VIEW_CELL_IDENTIFIER forIndexPath:indexPath];
	if ([cell isKindOfClass:[FCDeckCollectionViewCell class]])
	{
		NSInteger deckIndex = indexPath.row;
		Deck* deck = self.decks[deckIndex];
		cell.deckName.text = deck.name;
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

#pragma mark -
#pragma mark Core Data Methods

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
	self.databaseContext = databaseDocument.managedObjectContext;
	
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:DECK_ENTITY_NAME];
	// fetch the decks, store them to array
	
	NSError * error;
    if (!DEBUG) {
        self.decks = [self.databaseContext executeFetchRequest:request error:&error];
        // Sort the self.decks
        NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByIndex];
        NSArray *sortedArray = [self.decks sortedArrayUsingDescriptors:sortDescriptors];
        self.decks = sortedArray;
    } else {
        Deck *deck1 = [NSEntityDescription insertNewObjectForEntityForName:DECK_ENTITY_NAME
                                                    inManagedObjectContext:self.databaseContext];
        Deck *deck2 = [NSEntityDescription insertNewObjectForEntityForName:DECK_ENTITY_NAME
                                                    inManagedObjectContext:self.databaseContext];
        Deck *deck3 = [NSEntityDescription insertNewObjectForEntityForName:DECK_ENTITY_NAME
                        inManagedObjectContext:self.databaseContext];
        self.decks = @[deck1, deck2, deck3];
    }
	
	
	/*	if ([[NSUserDefaults standardUserDefaults] objectForKey:EXTERNALLY_OPENED_URL_DEFAULTS])
	 {
	 
	 
	 [self performSegueWithIdentifier:DECK_TO_CARD_SEGUE_IDENTIFIER sender:self];
	 }
*/
#warning HHHHHHHHHH
	
	[self.collectionView reloadData];
}

-(void)firstTimeDeckInsert
{
	//Put in a filler Deck because this is the first time the user has opened the app
#warning filler deck for first time opening.
	[self.collectionView reloadData];
	
}



@end
