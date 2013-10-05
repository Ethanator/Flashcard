//
//  FCRenderViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCRenderViewController.h"

@interface FCRenderViewController () <UIWebViewDelegate>
@property (strong, nonatomic) NSURL *resourceURL;
@property (weak, nonatomic) IBOutlet UIWebView *renderWebView;
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
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
	// Do any additional setup after loading the view.
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
