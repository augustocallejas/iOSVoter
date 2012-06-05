//
//  District.h
//  Supervote
//
//  Created by augusto callejas on 6/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictType;
@class Government;
@class PotentialDistrictRegistration;

@interface District :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * districtNum;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * districtDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) DistrictType * districtType;
@property (nonatomic, retain) NSSet* newRelationship;
@property (nonatomic, retain) Government * inGovernment;

@end


@interface District (CoreDataGeneratedAccessors)
- (void)addNewRelationshipObject:(PotentialDistrictRegistration *)value;
- (void)removeNewRelationshipObject:(PotentialDistrictRegistration *)value;
- (void)addNewRelationship:(NSSet *)value;
- (void)removeNewRelationship:(NSSet *)value;

@end

