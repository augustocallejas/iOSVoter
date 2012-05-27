//
//  DistrictRegistration.h
//  Supervote
//
//  Created by augusto callejas on 5/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class GovernmentRegistration;

@interface DistrictRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) GovernmentRegistration * registration;
@property (nonatomic, retain) District * district;

@end



