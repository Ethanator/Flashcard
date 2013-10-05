//
//  FCRenderViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCRenderViewController.h"
#import "Constants.h"

@interface FCRenderViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *renderWebView;
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;

@property (nonatomic, strong) UIImageView * cropRectImageView;

//model
@property (nonatomic, strong) NSString * frontPath;
@property (nonatomic, strong) NSString * backPath;
@property (nonatomic, strong) UIImage * frontImage;
@property (nonatomic, strong) UIImage * backImage;
@property (nonatomic, strong) UIImageView * frontImageView;
@property (nonatomic, strong) UIImageView * backImageView;

@end

@implementation FCRenderViewController

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
    
    self.renderWebView.delegate = self;
	NSString *testString = @"http://www.google.com";
//    self.resourceURL = [NSURL URLWithString:[testString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self loadURLToWebView];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	self.renderWebView.scrollView.maximumZoomScale = 4.0;
//	self.renderWebView.scrollView.minimumZoomScale = 0.00000001;
	self.cropRectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RECT_IMAGE_NAME]];
	self.cropRectImageView.center = self.view.center;
	self.cropRectImageView.frame = CGRectMake(0, 0, self.cropRectImageView.image.size.width / 3, self.cropRectImageView.image.size.height / 3);
	self.cropRectImageView.contentMode = UIViewContentModeScaleAspectFit;
	UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.cropRectImageView addGestureRecognizer:pan];
	[self.view addSubview:self.cropRectImageView];
	self.cropRectImageView.userInteractionEnabled = YES;
	
}

-(void) pan:(UIPanGestureRecognizer *) gesture
{
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		//get the relative distance moved
		CGPoint distance = [gesture translationInView:self.view];
		
		//apply that distance by translating the image
		
		CGFloat newX = self.cropRectImageView.frame.origin.x + distance.x;
		
		newX = (newX + self.cropRectImageView.frame.size.width / 2 > self.view.frame.size.width) ? self.view.frame.size.width - self.cropRectImageView.frame.size.width / 2 : newX;
		
		newX = (newX + self.cropRectImageView.frame.size.width / 2  < 0) ?  - self.cropRectImageView.frame.size.width / 2 : newX;
		
		CGFloat newY = self.cropRectImageView.frame.origin.y + distance.y;
		
		newY = (newY + self.cropRectImageView.frame.size.height / 2 > self.view.frame.size.height) ? self.view.frame.size.height - self.cropRectImageView.frame.size.height / 2 : newY;
		
		newY = (newY + self.cropRectImageView.frame.size.height / 2 < 0) ?  - self.cropRectImageView.frame.size.height / 2 : newY;
		
		
		//		NSLog(@"newX: %f, newY: %f", newX, newY);
		self.cropRectImageView.frame = CGRectMake(newX,
newY,
																			self.cropRectImageView.frame.size.width,
																			self.cropRectImageView.frame.size.height);
		
		//reset the translation to 0.0f
		[gesture setTranslation:CGPointZero inView:self.view];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadURLToWebView {
    [self.renderWebView loadRequest:[NSURLRequest requestWithURL:self.resourceURL]];
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error for WEBVIEW: %@", [error description]);
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Finished");
}


//Actions
- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
	if (self.frontPath && self.backPath)
	{
		[self.delegate didCollectFrontPath:self.frontPath andBackPath:self.backPath];
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Please select a front and back image"
																message:nil
															 delegate:nil cancelButtonTitle:@"OK"
											otherButtonTitles:nil] show];
	}
	
}
- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
		
	UIImage * screenImage = [self screenshot];
	CGImageRef imageRef = CGImageCreateWithImageInRect([screenImage CGImage], CGRectMake(self.cropRectImageView.frame.origin.x*2,
																																											 self.cropRectImageView.frame.origin.y*2,
																																											 self.cropRectImageView.frame.size.width*2,
																																											 self.cropRectImageView.frame.size.height*2));
	UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	NSData * imagePNGData = UIImagePNGRepresentation(croppedImage);
	NSInteger cardUniqueIDCounter = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	
	[[NSUserDefaults standardUserDefaults] setInteger:(cardUniqueIDCounter + 1) forKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
		
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"backImage%d.png",cardUniqueIDCounter]];
	
	//	NSLog((@"pre writing to file"));
	if (![imagePNGData writeToFile:imagePath atomically:NO])
	{
		NSLog((@"Failed to cache (back) image data to disk"));
	}
	else
	{
		NSLog(@"the cachedImagedPath (back) is %@",imagePath);
	}
	
	self.backPath = imagePath;
	self.backImage = croppedImage;
	self.backImageView = [[UIImageView alloc] initWithFrame:self.cropRectImageView.frame];
	self.backImageView.image = self.backImage;
	[self.view addSubview:self.backImageView];
	
	[UIView animateWithDuration:2.0 animations:^(void){
		//animate that view to the top right
		self.backImageView.center = CGPointMake(self.renderWebView.bounds.size.width - self.backImageView.frame.size.width / 2, self.backImageView.frame.size.width / 2 + [[self.navigationController navigationBar] frame].size.height);
		self.backImageView.frame = CGRectMake(self.backImageView.frame.origin.x,
																					self.backImageView.frame.origin.y,
																					self.backImageView.frame.size.width / 2,
																					self.backImageView.frame.size.height / 2);
	}];
}
- (IBAction)frontButtonTapped:(UIBarButtonItem *)sender
{
	UIImage * screenImage = [self screenshot];
	CGImageRef imageRef = CGImageCreateWithImageInRect([screenImage CGImage], CGRectMake(self.cropRectImageView.frame.origin.x*2,
																																											 self.cropRectImageView.frame.origin.y*2,
																																											 self.cropRectImageView.frame.size.width*2,
																																											 self.cropRectImageView.frame.size.height*2) );
	UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	NSData * imagePNGData = UIImagePNGRepresentation(croppedImage);
	NSInteger cardUniqueIDCounter = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	
	[[NSUserDefaults standardUserDefaults] setInteger:(cardUniqueIDCounter + 1) forKey:KEY_FOR_IMAGE_COUNTER_IN_NSUSERDEFAULTS];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"frontImage%d.png",cardUniqueIDCounter]];
	
	//	NSLog((@"pre writing to file"));
	if (![imagePNGData writeToFile:imagePath atomically:NO])
	{
		NSLog((@"Failed to cache (front) image data to disk"));
	}
	else
	{
		NSLog(@"the cachedImagedPath (front) is %@",imagePath);
	}
	
	self.frontPath = imagePath;
	self.frontImage = croppedImage;
	self.frontImageView = [[UIImageView alloc] initWithFrame:self.cropRectImageView.frame];
	self.frontImageView.image = self.frontImage;
	[self.view addSubview:self.frontImageView];
	
	self.frontImageView.center = self.cropRectImageView.center;

	[UIView animateWithDuration:2.0 animations:^(void){
		self.frontImageView.center = CGPointMake(self.frontImageView.frame.size.width / 2, self.frontImageView.frame.size.width / 2 + [[self.navigationController navigationBar] frame].size.height);
		self.frontImageView.frame = CGRectMake(self.frontImageView.frame.origin.x,
																					 self.frontImageView.frame.origin.y,
																					 self.frontImageView.frame.size.width / 2,
																					 self.frontImageView.frame.size.height / 2);
	}];
	
}

//got this method from apple's website:
//http://developer.apple.com/library/ios/#qa/qa1703/_index.html#//apple_ref/doc/uid/DTS40010193
- (UIImage*)screenshot
{
	self.cropRectImageView.hidden = YES;
	// Create a graphics context with the target size
	// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
	// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [[UIScreen mainScreen] bounds].size;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	else
		UIGraphicsBeginImageContext(imageSize);
	//	NSLog(@"time stamp");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	//	NSLog(@"time stamp");
	// Iterate over every window from back to front
	for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
		//		NSLog(@"time stamp");
		if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
		{
			// -renderInContext: renders in the coordinate space of the layer,
			// so we must first apply the layer's geometry to the graphics context
			CGContextSaveGState(context);
			// Center the context around the window's anchor point
			CGContextTranslateCTM(context, [window center].x, [window center].y);
			// Apply the window's transform about the anchor point
			CGContextConcatCTM(context, [window transform]);
			// Offset by the portion of the bounds left of and above the anchor point
			CGContextTranslateCTM(context,
														-[window bounds].size.width * [[window layer] anchorPoint].x,
														-[window bounds].size.height * [[window layer] anchorPoint].y);
			
			// Render the layer hierarchy to the current context
			[[window layer] renderInContext:context];
			
			// Restore the context
			CGContextRestoreGState(context);
		}
	}
	//	NSLog(@"time stamp");
	
	// Retrieve the screenshot image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	//	NSLog(@"time stamp");
	
	UIGraphicsEndImageContext();
	self.cropRectImageView.hidden = NO;
		
	return image;
}


@end
