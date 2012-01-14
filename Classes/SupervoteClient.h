//
//  SupervoteClient.h
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BallotVote.h"
#import "MeasureVote.h"

@interface SupervoteClient : NSObject {
	
@private
	NSManagedObjectContext* _context;
	SBJSON *parser;
	NSString *deviceID;
}

- (id)initWithContext:(NSManagedObjectContext *)context;
- (BOOL)isRegistered;
- (BOOL)registerDevice:(NSString *)zip5or9 withError:(NSError **)error;
- (void)sendFacebookAccessToken:(NSString *)accessToken;
- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid;
- (void)sendBallotVote:(BallotVote *)vote;
- (void)sendMeasureVote:(MeasureVote *)vote;
- (id)getVotesForBallot:(NSString *)electionGuid;
- (BOOL)insertVotes:(NSArray *)votes withError:(NSError **)error;
- (id)getFriends;
- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error;
- (NSDictionary *)getElections;
- (NSDictionary *)getElection:(NSString *)guid withLastModified:(NSDate *)time withNewModifiedTime:(NSDate **)newTime;
- (BOOL)insertElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;
- (BOOL)updateElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;

@end
