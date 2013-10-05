//
//  FCCardImageView.m
//  Flashcard
//
//  Created by Shuyang Li on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "FCCardImageView.h"
#import "Constants.h"

@implementation FCCardImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CARD_IMAGE_CORNER_RADIUS];
	
	[path addClip];
	
}


@end
