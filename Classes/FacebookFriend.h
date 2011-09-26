//
//  FacebookFriend.h
//  Supervote
//
//  Created by augusto callejas on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface FacebookFriend :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * photoDownloaded;
@property (nonatomic, retain) NSString * friendId;

@end



