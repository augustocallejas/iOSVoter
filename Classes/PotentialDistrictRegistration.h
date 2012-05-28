//
//  PotentialDistrictRegistration.h
//  Supervote
//
//  Created by augusto callejas on 5/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class DistrictType;
@class GovernmentRegistration;

@interface PotentialDistrictRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) GovernmentRegistration * registration;
@property (nonatomic, retain) DistrictType * districtType;
@property (nonatomic, retain) NSSet* choices;

@end


@interface PotentialDistrictRegistration (CoreDataGeneratedAccessors)
- (void)addChoicesObject:(District *)value;
- (void)removeChoicesObject:(District *)value;
- (void)addChoices:(NSSet *)value;
- (void)removeChoices:(NSSet *)value;

@end

