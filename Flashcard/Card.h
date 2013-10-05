//
//  Card.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/5/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Deck;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * backImagePath;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * frontImagePath;
@property (nonatomic, retain) NSNumber * frontUp;
@property (nonatomic, retain) Deck *deck;

@end
