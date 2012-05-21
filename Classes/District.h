//
//  District.h
//  Supervote
//
//  Created by augusto callejas on 5/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictType;
@class Government;

@interface District :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * districtNum;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) DistrictType * districtType;
@property (nonatomic, retain) Government * inGovernment;

@end



