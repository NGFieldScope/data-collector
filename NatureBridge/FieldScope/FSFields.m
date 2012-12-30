//
//  FSFields.m
//  NatureBridge
//
//  Created by Alex Volkovitsky on 12/29/12.
//  Copyright (c) 2012 Alex Volkovitsky. All rights reserved.
//

#import "FSFields.h"
#import "FSFieldGroups.h"
#import "FSValues.h"
#import "FSConnection.h"
#import "FSStore.h"
#import "FieldGroup.h"

@implementation FSFields

+ (NSString *)tableName
{
    return @"Field";
}

/* This bad boy reads from the schemas API and saves the result into the three associated tables
 * Do not call this directly, as it is a callback from FSFields.load
 *
 * WARNING: Calling this multiple times on the same database in unsupported and will result in data duplication
 */
- (void)readFromJSONDictionary:(NSDictionary *)response
{
    for (NSDictionary *schema in [response objectForKey:@"results"]) {
        if (![[schema objectForKey:@"type"] isEqual:@"Observation"]) {
            continue;
        }
        for (NSDictionary *fieldGroupJSON in [schema objectForKey:@"fieldGroupJSONs"]) {
            NSNumber *remoteId = [NSNumber numberWithInt:[[fieldGroupJSON objectForKey:@"id"] intValue]];
            FieldGroup *fieldGroup = [FSFieldGroups findOrCreate:remoteId
                                                           named:[fieldGroupJSON objectForKey:@"label"]];
            
            for (NSDictionary *fieldJSON in [fieldGroupJSON objectForKey:@"fields"]) {
                Field *field = [NSEntityDescription insertNewObjectForEntityForName:[FSFields tableName]
                                                             inManagedObjectContext:[[FSStore dbStore] context]];
                
                // mandatory fields
                [field setFieldGroup:fieldGroup];
                [field setLabel:[fieldJSON objectForKey:@"label"]];
                [field setName:[fieldJSON objectForKey:@"name"]];
                [field setType:[fieldJSON objectForKey:@"type"]];
                
                // these are optional and may be null
                if (![[fieldJSON objectForKey:@"units"] isKindOfClass:[NSNull class]]) {
                    [field setUnits:[fieldJSON objectForKey:@"units"]];
                }
                if (![[fieldJSON objectForKey:@"minimum"] isKindOfClass:[NSNull class]]) {
                    [field setMinimum:[NSNumber numberWithInt:[[fieldGroupJSON objectForKey:@"minimum"] intValue]]];
                }
                if (![[fieldJSON objectForKey:@"maximum"] isKindOfClass:[NSNull class]]) {
                    [field setMinimum:[NSNumber numberWithInt:[[fieldGroupJSON objectForKey:@"maximum"] intValue]]];
                }
                
                // some fields have predefined values
                for (NSDictionary *valueJSON in [fieldJSON objectForKey:@"values"]) {
                    Value *value = [NSEntityDescription insertNewObjectForEntityForName:[FSValues tableName]
                                                                 inManagedObjectContext:[[FSStore dbStore] context]];
                     
                    [value setField:field];
                    [value setValue:[valueJSON objectForKey:@"value"]];
                    [value setLabel:[valueJSON objectForKey:@"label"]];
                    
                }
            }
        }
    }
    [[FSStore dbStore] saveChanges];
}

/* As with the other load methods, we hereby initialize the FieldGroup, Field, and Value tables
 * Key difference: these tables are not stored in a global array like Project, Station, and Observation
 */
+ (void)load:(void (^)(NSError *))block
{
    // Guard against loading these tables from the API multiple times
    // TODO: in the future we should support dynamic schemas, but the future is not today
    if([[FSFieldGroups executeRequest:[FSFieldGroups buildRequest]] count] == 0) {
        NSURL *url = [NSURL URLWithString:[[FSConnection apiPrefix] stringByAppendingString:@"schemas.json"]];
        NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        FSFields *rootObject = [[FSFields alloc] init];
        
        FSConnection *connection = [[FSConnection alloc] initWithRequest:request rootObject:rootObject completion:block];
        
        [connection start];
    }
}

@end