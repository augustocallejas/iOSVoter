// 
//  Government.m
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Government.h"

#import "District.h"
#import "GovernmentRegistration.h"
#import "GovernmentType.h"
#import "PotentialGovernmentRegistration.h"

@implementation Government 

@dynamic shortName;
@dynamic id;
@dynamic name;
@dynamic parent;
@dynamic children;
@dynamic registrations;
@dynamic governmentType;
@dynamic potentialGovernmentRegistrations;
@dynamic districts;

@end
