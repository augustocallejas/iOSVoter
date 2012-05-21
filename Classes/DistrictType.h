//
//  DistrictType.h
//  Supervote
//
//  Created by augusto callejas on 5/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface DistrictType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;

@end



