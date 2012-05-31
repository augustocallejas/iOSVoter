//
//  District.h
//  Supervote
//
//  Created by augusto callejas on 5/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictType;
@class Government;

@interface District :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * districtNum;
@property (nonatomic, retain) Government * inGovernment;
@property (nonatomic, retain) DistrictType * districtType;

@end



