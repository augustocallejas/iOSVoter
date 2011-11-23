//
//  SupervoteClient.h
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SupervoteClient : NSObject {
	
@private
	SBJSON *parser;
}

- (id)registerDevice;
- (void)sendFacebookAccessToken:(NSString *)accessToken;
- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid fromContext:(NSManagedObjectContext *)context;
- (id)getVotesForBallot:(NSString *)guid;
- (BOOL)insertVotes:(NSArray *)votes intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error;
- (id)getFriends;
- (BOOL)insertFriends:(NSArray *)friends intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error;
- (id)getElections;
- (BOOL)insertElections:(NSArray *)elections intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error;

@end
