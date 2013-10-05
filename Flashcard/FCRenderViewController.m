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
	self.renderWebView.scrollView.maximumZoomScale = 4.0;
	self.renderWebView.scrollView.minimumZoomScale = 0.00000001;
	UIImageView* cropRectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CROP_RECT_WIDTH, CROP_RECT_HEIGHT)];
	cropRectImageView.center = self.view.center;
	cropRectImageView.image = [UIImage imageNamed:RECT_IMAGE_NAME];
	cropRectImageView.contentMode = UIViewContentModeScaleAspectFit;
	UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[cropRectImageView addGestureRecognizer:pan];
	[self.view addSubview:cropRectImageView];
	cropRectImageView.userInteractionEnabled = YES;
	self.cropRectImageView = cropRectImageView;
	
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


@end
