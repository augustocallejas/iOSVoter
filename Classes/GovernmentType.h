//
//  GovernmentType.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Government;

@interface GovernmentType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* governments;

@end


@interface GovernmentType (CoreDataGeneratedAccessors)
- (void)addGovernmentsObject:(Government *)value;
- (void)removeGovernmentsObject:(Government *)value;
- (void)addGovernments:(NSSet *)value;
- (void)removeGovernments:(NSSet *)value;

@end

