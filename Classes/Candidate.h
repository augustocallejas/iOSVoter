//
//  Candidate.h
//  Supervote
//
//  Created by augusto callejas on 8/26/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Candidate : NSManagedObject {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *occupation;

@end
