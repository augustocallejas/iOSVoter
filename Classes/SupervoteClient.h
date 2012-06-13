//
//  SupervoteClient.h
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BallotVote.h"
#import "District.h"
#import "DistrictType.h"
#import "Election.h"
#import "Government.h"
#import "GovernmentRegistration.h"
#import "GovernmentType.h"
#import "MeasureVote.h"
#import "PotentialDistrictRegistration.h"
#import "PotentialGovernmentRegistration.h"

typedef enum {
	OK, HTTP_ERROR, SERVER_ERROR, BAD_REQUEST, ELECTION_CLOSED, UNEXPECTED_RESPONSE
} vote_status;

typedef enum {
	ES_OK, ES_NOT_FOUND, ES_CLOSED, ES_NOT_MODIFIED
} election_status;

@interface SupervoteClient : NSObject {
	
@private
	NSManagedObjectContext* _context;
	SBJSON *parser;
	NSString *deviceID;
}

- (id)initWithContext:(NSManagedObjectContext *)context;
- (BOOL)isRegistered;
- (BOOL)registerDevice:(NSString *)zip5or9 withLanguage:(NSString *)language withError:(NSError **)error;
- (NSDictionary *)getProfileWithError:(NSError **)error;
- (void)findOrInsertGovernmentRegistration:(NSDictionary *)object withDisplayOrder:(int) displayOrder withParent:(Government *)parent withError:(NSError **)error;
- (void)findOrInsertDistrictRegistration:(NSDictionary *)object withParent:(GovernmentRegistration *)parent withError:(NSError **)error;
- (BOOL)resolveGovernmentRegistration:(PotentialGovernmentRegistration *)potentialRegistration
					   withGovernment:(Government *)choice
					  withCreatedTime:(NSDate *)createdTime
							withError:(NSError **)error;
- (BOOL)resolveDistrictRegistration:(PotentialDistrictRegistration *)potentialRegistration
						   withDistrict:(District *)district
						withCreatedTime:(NSDate *)createdTime
							  withError:(NSError **)error;
- (BOOL)findOrInsertPotentialGovermentRegistration:(NSDictionary *)object
										withParent:(GovernmentRegistration *)parent
										 withError:(NSError **) error;
- (void)findOrInsertPotentialDistrictRegistration:(NSDictionary *)object
									   withParent:(GovernmentRegistration *)parent
										withError:(NSError **) error;
- (District *)findOrInsertDistrict:(NSDictionary *)object
						withParent:(Government *)parent
						 withError:(NSError **)error;
- (DistrictType *)findOrInsertDistrictType:(NSDictionary *)object withError:(NSError **)error;
- (Government *)findOrInsertGovernment:(NSDictionary *)object withParent:(Government *)parent withError:(NSError **)error;
- (GovernmentType *)findOrInsertGovernmentType:(NSDictionary *)object withError:(NSError **)error;
- (void)selectGovernment:(PotentialGovernmentRegistration *)potentialRegistration
			  withChoice:(Government *)choice
			withDelegate:(id)delegate;
- (void)selectDistrict:(PotentialDistrictRegistration *)potentialDistrict
			withChoice:(District *)choice
		  withDelegate:(id)delegate;
- (vote_status)sendFacebookAccessToken:(NSString *)accessToken;
- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid;
- (vote_status)sendBallotVote:(BallotVote *)vote;
- (vote_status)sendMeasureVote:(MeasureVote *)vote;
- (NSArray *)getVotesForBallot:(NSString *)electionGuid;
- (BOOL)insertVotes:(NSArray *)votes;
- (id)getFriends;
- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error;
- (NSDictionary *)getElections:(vote_status *)status;
- (election_status)getElection:(NSDictionary **)election
					  withGuid:(NSString *)guid
			  withLastModified:(NSDate *)time
		   withNewModifiedTime:(NSDate **)newTime
					 withError:(NSError **)httpError;
- (BOOL)insertElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;
- (BOOL)updateElection:(Election *)electionObj withObject:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error;

@end
