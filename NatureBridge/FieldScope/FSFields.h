//
//  FSFields.h
//  NatureBridge
//
//  Created by Alex Volkovitsky on 12/29/12.
//  Copyright (c) 2012 Alex Volkovitsky. All rights reserved.
//

#import "FSTable.h"
#import "JSONSerializable.h"
#import "Field.h"
#import "Project.h"

@interface FSFields : FSTable <JSONSerializable>

@property Project *project;

@end
