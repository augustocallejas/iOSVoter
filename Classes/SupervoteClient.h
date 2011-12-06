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
	NSManagedObjectContext* _context;
	SBJSON *parser;
	NSString *deviceID;
}

- (id)initWithContext:(NSManagedObjectContext *)context;
- (BOOL)isRegistered;
- (BOOL)registerDevice;
- (void)sendFacebookAccessToken:(NSString *)accessToken;
- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid;
- (id)getVotesForBallot:(NSString *)guid;
- (BOOL)insertVotes:(NSArray *)votes withError:(NSError **)error;
- (id)getFriends;
- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error;
- (id)getElections;
- (BOOL)insertElections:(NSArray *)elections withError:(NSError **)error;

@end
