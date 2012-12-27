//
//  FSStore.m
//  NatureBridge
//
//  Created by Alex Volkovitsky on 12/22/12.
//  Copyright (c) 2012 Alex Volkovitsky. All rights reserved.
//

#import "FSStore.h"

@class Project;

@interface FSStore ()
- (NSString *) itemArchivePath;
@end

@implementation FSStore

@synthesize model;
@synthesize context;
@synthesize allProjects;
@synthesize allStations;

+ (FSStore *)dbStore
{
    static FSStore *dbStore = nil;
    if (!dbStore) {
        dbStore = [[super allocWithZone:nil] init];
    }
    return dbStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self dbStore];
}

- (id) init
{
    self = [super init];
    
    if (self) {
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:[NSURL fileURLWithPath:[self itemArchivePath]]
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
    }
    
    return self;
}

- (BOOL) saveChanges
{
    NSError *error = nil;
    BOOL successful = [context save:&error];
    if (!successful) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    return successful;
}

- (void) loadProjects
{
    if (![self allProjects]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[[model entitiesByName] objectForKey:@"Project"]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        [self setAllProjects:[[NSMutableArray alloc] initWithArray:result]];
    }
    
    // Seed data
    if ([[self allProjects] count] == 0) {
        [self createProject:@"Olympic"];
        [self createProject:@"Olympic Weather"];
    }
}

- (Project *) createProject:(NSString *)projectName
{
    Project *project = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
    [project setName:projectName];
    [[self allProjects] addObject:project];
    return project;
}

// private

- (NSString *) itemArchivePath
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

@end
