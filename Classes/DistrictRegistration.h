//
//  DistrictRegistration.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class DistrictType;
@class GovernmentRegistration;

@interface DistrictRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) GovernmentRegistration * registration;
@property (nonatomic, retain) District * district;
@property (nonatomic, retain) DistrictType * districtType;

@end



