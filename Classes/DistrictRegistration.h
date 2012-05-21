//
//  DistrictRegistration.h
//  Supervote
//
//  Created by augusto callejas on 5/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class GovernmentRegistration;

@interface DistrictRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) District * district;
@property (nonatomic, retain) GovernmentRegistration * registration;

@end



