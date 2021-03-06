//
//  Value.h
//  NatureBridge
//
//  Copyright 2013 NatureBridge. All Rights Reserved.
//
//  Permission is granted to copy, distribute and/or modify this file under the
//  terms of the Open Software License v. 3.0 (OSL-3.0). You may obtain a copy of
//  the license at http://opensource.org/licenses/OSL-3.0
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Value : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSManagedObject *field;

@end
