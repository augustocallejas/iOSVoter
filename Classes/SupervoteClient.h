//
//  SupervoteClient.h
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BallotVote.h"
#import "Election.h"
#import "MeasureVote.h"

typedef enum {
	OK, HTTP_ERROR, SERVER_ERROR, BAD_REQUEST, ELECTION_CLOSED, UNEXPECTED_RESPONSE
} vote_status;

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
- (vote_status)sendBallotVote:(BallotVote *)vote;
- (vote_status)sendMeasureVote:(MeasureVote *)vote;
- (id)getVotesForBallot:(NSString *)electionGuid;
- (BOOL)insertVotes:(NSArray *)votes;
- (id)getFriends;
- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error;
- (NSDictionary *)getElections:(vote_status *)status;
- (NSDictionary *)getElection:(NSString *)guid withLastModified:(NSDate *)time withNewModifiedTime:(NSDate **)newTime withError:(NSError **)httpError;
- (BOOL)insertElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;
- (BOOL)updateElection:(Election *)electionObj withObject:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;

@end
