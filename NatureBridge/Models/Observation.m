//
//  Observation.m
//  NatureBridge
//
//  Created by Alex Volkovitsky on 12/27/12.
//  Copyright (c) 2012 Alex Volkovitsky. All rights reserved.
//

#import "Observation.h"
#import "Station.h"


@implementation Observation

@dynamic collectionDate;
@dynamic station;
@dynamic observationData;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    [self setCollectionDate:[NSDate date]];
}

@end