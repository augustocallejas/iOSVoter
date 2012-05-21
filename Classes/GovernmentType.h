//
//  GovernmentType.h
//  Supervote
//
//  Created by augusto callejas on 5/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface GovernmentType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * id;

@end



