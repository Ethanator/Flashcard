//
//  FCCaptureImageViewController.m
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCCaptureImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface FCCaptureImageViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession * videoCaptureSession;
@property (nonatomic, strong) AVCaptureDevice * videoCaptureDevice;
@property (weak, nonatomic) IBOutlet UIView *videoPreviewLayer;

@property BOOL captureNextImage;

@end

@implementation FCCaptureImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupVideoCamera
{
	self.videoCaptureSession = [[AVCaptureSession alloc] init];
	self.videoCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
	//instantiate the capture session
	
	self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	//instantiate the capture device
	
	NSError *error = nil;
	
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice
																																			error:&error];
	if (!input) {
		NSLog(@"Error with camera: %@", error);
		return;
	}
	
	[self.videoCaptureSession addInput:input];
	//hook up the session and input
	
	AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
	output.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: kCVPixelFormatType_32BGRA]
																										 forKey: (id)kCVPixelBufferPixelFormatTypeKey];
	[self.videoCaptureSession addOutput:output];
	
	//	dispatch_queue_t sampleBufferQueue = dispatch_queue_create("sampleBufferQueue", NULL);
	
	//If the camera is not put on the main queue, the app silently crashes with memory warnings when calling the main
	//Queue from the SampleBuffer delegate method.
	//
	//For now, if we want UI changes from analyzing the camera data, the SampleBuffer must be dispatched to the main queue.
	
	[output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	AVCaptureConnection *videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
	if ([videoConnection isVideoOrientationSupported])
	{
		[videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
	}
	
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCaptureSession];
	
	[captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[captureVideoPreviewLayer setFrame:self.videoPreviewLayer.bounds];
	
	CALayer *rootLayer = [self.videoPreviewLayer layer];
	[rootLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[rootLayer addSublayer:captureVideoPreviewLayer];
	
	[self.videoCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	if(self.captureNextImage)
	{
		[self.delegate captureImageViewControllerDidCaptureImage:[self imageFromSampleBuffer:sampleBuffer]];
		self.captureNextImage = NO;
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (IBAction)captureButtonTapped:(UIButton *)sender
{
	self.captureNextImage = YES;
}

- (IBAction)cancelButtonTapped:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setupVideoCamera];
	[self.videoCaptureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.videoCaptureSession stopRunning];
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

-(NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationPortrait;
}

//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//	return UIInterfaceOrientationPortrait;
//}

-(BOOL)shouldAutorotate
{
	return NO;
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
	// Get a CMSampleBuffer's Core Video image buffer for the media data
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	// Lock the base address of the pixel buffer
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	// Get the number of bytes per row for the pixel buffer
	void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	
	// Get the number of bytes per row for the pixel buffer
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	// Get the pixel buffer width and height
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	// Create a device-dependent RGB color space
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// Create a bitmap graphics context with the sample buffer data
	CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
																							 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	// Create a Quartz image from the pixel data in the bitmap graphics context
	CGImageRef quartzImage = CGBitmapContextCreateImage(context);
	// Unlock the pixel buffer
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	// Free up the context and color space
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	// Create an image object from the Quartz image
	UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
	// Release the Quartz image
	CGImageRelease(quartzImage);
	
	return (image);
}


@end
