//
//  Card.h
//  Flashcard
//
//  Created by Sean Fitzgerald on 10/4/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * backImagePath;
@property (nonatomic, retain) NSDecimalNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * frontImagePath;
@property (nonatomic, retain) NSManagedObject *deck;

@end
