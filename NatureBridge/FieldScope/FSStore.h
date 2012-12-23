//
//  FSStore.h
//  NatureBridge
//
//  Created by Alex Volkovitsky on 12/22/12.
//  Copyright (c) 2012 Alex Volkovitsky. All rights reserved.
//
//  This file manages the database connection through CoreData

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Project.h"

@interface FSStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    @public
    NSMutableArray *allProjects;
}

- (BOOL) saveChanges;
- (void) loadProjects;
- (Project *) createProject:(NSString *)projectName;

extern FSStore *dbStore;

@end