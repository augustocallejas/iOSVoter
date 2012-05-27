//
//  SupervoteClient.m
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "SupervoteClient.h"

#import "Candidate.h"
#import "District.h"
#import "DistrictRegistration.h"
#import "Election.h"
#import "Friend.h"
#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"
#import "Government.h"
#import "GovernmentRegistration.h"
#import "GovernmentType.h"
#import "Measure.h"
#import "Position.h"

static NSString *kDeviceIDHeaderKey = @"DeviceID";
static NSString* kAPIUrl = @"http://localhost:9999";

@implementation SupervoteClient

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
	if (self) {
		parser = [[SBJSON alloc] init];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"DeviceID"]) {
			deviceID = [[defaults objectForKey:@"DeviceID"] retain];
			LogInfo(@"Loaded device ID '%@'", deviceID);
		}
		
		_context = [context retain];
	}
    return self;
}

- (BOOL)isRegistered {
	return deviceID != nil;
}

- (NSURL *)createURL:(NSString *)service {
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAPIUrl, service]];
}

/* TODO: this method should take arguments and return some value, and also have an error argument */
- (BOOL)registerDevice:(NSString *)zip5or9 withError:(NSError **)error {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/registration"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:zip5or9 forKey:@"z"];
	
	[request startSynchronous];
	BOOL registered = NO;
	*error = [request error];
	if (*error != nil) {
		return registered;
	}
	else if ([request responseStatusCode] == 200) {
		/* save UUID */
		deviceID = [request responseString];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:deviceID forKey:@"DeviceID"];
		[defaults synchronize];
		LogInfo(@"Registered new device ID '%@'", deviceID);
		registered = YES;
	}
	else if ([request responseStatusCode] == 400) {
		registered = NO;
	}
	else {
		LogError(@"Unexpected status code response: %d", [request responseStatusCode]);
	}
	
	return registered;
}

- (NSDictionary *)getProfileWithError:(NSError **)error {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/profile"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request startSynchronous];
	
	[request startSynchronous];
	*error = [request error];
	if (*error == nil) {
		if ([request responseStatusCode] == 200) {
			
			NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
			NSLog(@"JSON: %@", json);
			NSError *parseError = nil;
			id profile = [parser objectWithString:json error:&parseError];	
			[json release];
			
			if (parseError != nil) {
				NSLog(@"Parse error: %@", [parseError userInfo]);
			}
			else {
				//NSLog(@"Got profile: %@", profile);
			}
			
			return profile;
			
		}
	}
	
	return nil;
}

- (void)findOrInsertGovernmentRegistration:(NSDictionary *)object withDisplayOrder:(int) displayOrder withParent:(Government *)parent withError:(NSError **)error {
	/* TODO: check if value is nil? */
	NSDictionary *governmentObj = [object objectForKey:@"government"];
	
	Government *government = [self findOrInsertGovernment:governmentObj withParent:parent withError:error];
	if (*error == nil) {
		/* query for existing GovernmentRegistration at displayOrder */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentRegistration" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayOrder = %@", [NSNumber numberWithInt:displayOrder]];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];

		if (*error == nil) {
			NSNumber *dateValue = [object objectForKey:@"createdTime"];
			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
			
			GovernmentRegistration *registration = nil;
			BOOL insertObject = YES;
			if (results != nil && [results count] == 1) {
				registration = [results objectAtIndex:0];
				
				if ([registration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
					LogDebug(@"Current GovernmentRegistration is out of date (current=%@ vs incoming=%@), deleting current registration", registration.createdTime, createdTime);
					
					[_context deleteObject:registration];
				}
				else {
					LogDebug(@"Current GovernmentRegistration with latest timestamp, no update necessary: (current=%@ vs incoming=%@)", registration.createdTime, createdTime);
					
					insertObject = NO;
				}
			}
			
			if (insertObject) {
				LogDebug(@"Inserting incoming GovernmentRegistration: (type=%@, name=%@, displayOrder=%d, createdTime=%@)", government.governmentType.name, government.name, displayOrder, createdTime);
							
				/* TODO: currently only inserting... */
				registration = [NSEntityDescription insertNewObjectForEntityForName:@"GovernmentRegistration" inManagedObjectContext:_context];
				registration.displayOrder = [NSNumber numberWithInt:displayOrder];
				registration.government = government;
				registration.createdTime = createdTime;
				
				[_context save:error];
			}
			[createdTime release];
			
			if (*error == nil) {
				NSArray *governmentRegistrations = [object objectForKey:@"governmentRegistrations"];
				if (governmentRegistrations != nil) {
					for (NSDictionary *governmentRegistrationObj in governmentRegistrations) {
						[self findOrInsertGovernmentRegistration:governmentRegistrationObj withDisplayOrder:(displayOrder+1) withParent:government withError:error];
						
						if (*error != nil) {
							return;
						}
					}
				}
				
				NSArray *districtRegistrations = [object objectForKey:@"districtRegistrations"];
				if (districtRegistrations != nil) {
					/* TODO: */
					for (NSDictionary *districtRegistrationObj in districtRegistrations) {
						[self findOrInsertDistrictRegistration:districtRegistrationObj withParent:registration withError:error];
						
						if (*error != nil) {
							return;
						}
					}
				}
			}
		}
	}
}

- (void)findOrInsertDistrictRegistration:(NSDictionary *)object withParent:(GovernmentRegistration *)parent withError:(NSError **)error {
	/* TODO: check if value is nil? */
	NSDictionary *districtObj = [object objectForKey:@"district"];
	
	District *district = [self findOrInsertDistrict:districtObj withParent:parent.government withError:error];
	if (*error == nil) {
		/* query for existing DistrictRegistration at displayOrder */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictRegistration" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registration = %@ and district = %@", parent, district];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (*error == nil) {
			NSNumber *dateValue = [object objectForKey:@"createdTime"];
			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
			
			DistrictRegistration *registration = nil;
			BOOL insertObject = YES;
			if (results != nil && [results count] == 1) {
				registration = [results objectAtIndex:0];
				
				if ([registration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
					LogDebug(@"Current DistrictRegistration is out of date (current=%@ vs incoming=%@), deleting current registration", registration.createdTime, createdTime);
					
					[_context deleteObject:registration];
				}
				else {
					LogDebug(@"Current DistrictRegistration with latest timestamp, no update necessary: (current=%@ vs incoming=%@)", registration.createdTime, createdTime);
					
					insertObject = NO;
				}
			}
			
			if (insertObject) {
				LogDebug(@"Inserting incoming DistrictRegistration: (type=%@, name=%@, createdTime=%@)", district.districtType.name, district.name, createdTime);
				
				/* TODO: currently only inserting... */
				registration = [NSEntityDescription insertNewObjectForEntityForName:@"DistrictRegistration" inManagedObjectContext:_context];
				registration.district = district;
				registration.registration = parent;
				registration.createdTime = createdTime;
				
				[_context save:error];
			}
			[createdTime release];
		}
	}
}


- (District*)findOrInsertDistrict:(NSDictionary *)object withParent:(Government *)parent withError:(NSError **)error {
	/* TODO: check if value is nil? */
	NSDictionary *districtTypeObj = [object objectForKey:@"districtType"];
	
	DistrictType *districtType = [self findOrInsertDistrictType:districtTypeObj withError:error];
	if (*error == nil) {
		NSString *name = [object objectForKey:@"name"];
		id shortName = [object objectForKey:@"shortName"];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"District" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ && districtType = %@", name, districtType];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (*error == nil) {
			if (results != nil && [results count] == 1) {
				return [results objectAtIndex:0];
			}
			
			/* create and return Government instance */
			District *district = [NSEntityDescription insertNewObjectForEntityForName:@"District" inManagedObjectContext:_context];
			district.name = name;
			district.shortName = shortName == [NSNull null] ? nil : shortName;
			district.districtType = districtType;
			if (parent != nil) {
				district.inGovernment = parent;
			}
			
			if ([_context save:error]) {
				return district;
			}
		}
	}
	
	return nil;
}

- (DistrictType *)findOrInsertDistrictType:(NSDictionary *)object withError:(NSError **)error {
	/* TODO: check if values are not nil? */
	NSString *idValue = [object objectForKey:@"id"];
	NSString *name = [object objectForKey:@"name"];
	NSNumber *displayOrder = [object objectForKey:@"displayOrder"];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictType" inManagedObjectContext:_context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
	[request setPredicate:predicate];
	
	NSArray *results = [_context executeFetchRequest:request error:error];
	[request release];
	
	if (*error == nil) {
		if (results != nil && [results count] == 1) {
			return [results objectAtIndex:0];
		}
		
		/* create and return DistrictType instance */
		DistrictType *districtType = [NSEntityDescription insertNewObjectForEntityForName:@"DistrictType" inManagedObjectContext:_context];
		districtType.id = idValue;
		districtType.name = name;
		districtType.displayOrder = displayOrder;
		
		if ([_context save:error]) {
			return districtType;
		}
	}
	
	return nil;
}

- (Government *)findOrInsertGovernment:(NSDictionary *)object withParent:(Government *)parent withError:(NSError **)error {
	/* TODO: check if value is nil? */
	NSDictionary *governmentTypeObj = [object objectForKey:@"governmentType"];
	
	GovernmentType *governmentType = [self findOrInsertGovernmentType:governmentTypeObj withError:error];
	if (*error == nil) {
		NSString *name = [object objectForKey:@"name"];
		id shortName = [object objectForKey:@"shortName"];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Government" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ && governmentType = %@", name, governmentType];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (*error == nil) {
			if (results != nil && [results count] == 1) {
				return [results objectAtIndex:0];
			}
			
			/* create and return Government instance */
			Government *government = [NSEntityDescription insertNewObjectForEntityForName:@"Government" inManagedObjectContext:_context];
			government.name = name;
			government.shortName = shortName == [NSNull null] ? nil : shortName;
			government.governmentType = governmentType;
			if (parent != nil) {
				government.parent = parent;
			}
			
			if ([_context save:error]) {
				return government;
			}
		}
	}
	
	return nil;
}

- (GovernmentType *)findOrInsertGovernmentType:(NSDictionary *)object withError:(NSError **)error {
	/* TODO: check if values are not nil? */
	NSString *idValue = [object objectForKey:@"id"];
	NSString *name = [object objectForKey:@"name"];
	NSNumber *displayOrder = [object objectForKey:@"displayOrder"];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentType" inManagedObjectContext:_context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
	[request setPredicate:predicate];
	
	NSArray *results = [_context executeFetchRequest:request error:error];
	[request release];

	if (*error == nil) {
		if (results != nil && [results count] == 1) {
			return [results objectAtIndex:0];
		}
		
		/* create and return GovernmentType instance */
		GovernmentType *governmentType = [NSEntityDescription insertNewObjectForEntityForName:@"GovernmentType" inManagedObjectContext:_context];
		governmentType.id = idValue;
		governmentType.name = name;
		governmentType.displayOrder = displayOrder;
		
		if ([_context save:error]) {
			return governmentType;
		}
	}
	
	return nil;
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	NSLog(@"Received a response: %@", response);
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//	NSLog(@"Error: %@", [error userInfo]);
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//	[responseData appendData:data];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//	
//	NSString* responseString = [[NSString alloc] initWithData:responseData
//													 encoding:NSUTF8StringEncoding];
//	NSLog(@"Done loading, the data is: %@", responseString);
//	[responseString release];
//	
//	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate switchToMainApp];
//}

- (vote_status)sendFacebookAccessToken:(NSString *)accessToken {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/accessToken"];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:@"fb" forKey:@"socialnet"];
	[request setPostValue:accessToken forKey:@"access_token"];

	[request startSynchronous];
	
	vote_status status = OK;
	NSError *error = [request error];
	if (error != nil) {
		status = HTTP_ERROR;
		/* TODO: log to disk? */
//		NSLog(@"error: %@", [error userInfo]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		/* TODO: log to disk */
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		/* TODO: log to disk */
	}
	
	return status;
}

- (vote_status)sendBallotVote:(BallotVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voteCandidate"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forPosition.forElection.guid forKey:@"election"];
	[request setPostValue:vote.forPosition.guid forKey:@"position"];
	[request setPostValue:vote.forCandidate.guid forKey:@"candidate"];
	[request setPostValue:vote.statement forKey:@"statement"];
	[request setPostValue:vote.viewableByFriends forKey:@"viewable_by_friends"];
	
	[request startSynchronous];
	
	vote_status status = OK;
	NSError *error = [request error];
	if (error != nil) {
		status = HTTP_ERROR;
		/* TODO: log to disk? */
		//NSLog(@"error: %@", [error userInfo]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		/* TODO: log to disk */
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		status = BAD_REQUEST;
		/* TODO: log to disk */
	}
	else if ([request responseStatusCode] == 403) {
		/* FORBIDDEN */
		status = ELECTION_CLOSED;
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		/* TODO: log to disk */
	}
	
	return status;
}

- (vote_status)sendMeasureVote:(MeasureVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voteMeasure"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forMeasure.forElection.guid forKey:@"election"];
	[request setPostValue:vote.forMeasure.guid forKey:@"measure"];
	[request setPostValue:vote.statement forKey:@"statement"];
	[request setPostValue:vote.viewableByFriends forKey:@"viewable_by_friends"];
	if (vote.vote != nil) {
		[request setPostValue:vote.vote forKey:@"vote"];
	}
	
	vote_status status = OK;
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		status = HTTP_ERROR;
		/* TODO: log to disk */
//		NSLog(@"error: %@", [error userInfo]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		/* TODO: log to disk */
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		status = BAD_REQUEST;
		/* TODO: log to disk */
	}
	else if ([request responseStatusCode] == 403) {
		/* FORBIDDEN */
		status = ELECTION_CLOSED;
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		/* TODO: log to disk */
	}
	
	return status;
}

- (id)getVotesForBallot:(NSString *)electionGuid{
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:[NSString stringWithFormat:@"/votes?election=%@", electionGuid]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request startSynchronous];
	
	NSError *httpError = [request error];
	if (httpError != nil) {
		NSLog(@"Network error while getting votes for election: %@", [httpError userInfo]);
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
//		NSLog(@"Votes: %@", json);
		
		NSError *parseError = nil;
		NSArray *votes = [parser objectWithString:json error:&parseError];	
		[json release];
		
		if (parseError != nil) {
			NSLog(@"Parse error: %@", [parseError userInfo]);
		}
		else {
			return votes;
		}
	}

	return nil;
}

- (FriendBallotVote *)getVoteForPosition:(Position *)position byAuthor:(Friend *)friend {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[position managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && author == %@", position, friend];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[position managedObjectContext] executeFetchRequest:request error:&error];
	[request release];
	
	if (error != nil) {
		NSLog(@"Error while querying for existing ballot vote: %@", [error userInfo]);
	}
	else if ([array count] == 1) {
		return (FriendBallotVote *) [array objectAtIndex:0];
	}
	
	return nil;
}

- (FriendMeasureVote *)getVoteForMeasure:(Measure *)measure byAuthor:(Friend *)friend {
	/* check if the friend measure vote already exists */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendMeasureVote" inManagedObjectContext:[measure managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forMeasure == %@ && author == %@", measure, friend];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[measure managedObjectContext] executeFetchRequest:request error:&error];
	[request release];
	
	if (error != nil) {
		NSLog(@"Error while querying for existing measure vote: %@", [error userInfo]);
	}
	else if ([array count] == 1) {
		return (FriendMeasureVote *) [array objectAtIndex:0];
	}
	
	return nil;
}

- (BOOL)insertVotes:(NSArray *)votes {
	//NSLog(@"Inserting %d votes", [votes count]);
	for (NSDictionary *vote in votes) {
		NSString *type = [vote objectForKey:@"type"];
		
		if ([@"BallotVote" isEqualToString:type]) {
			/* cases 1) insert 2) update 3) delete */
			NSNumber *viewable = [vote objectForKey:@"viewable"];
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *positionGuid = [vote objectForKey:@"position"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSString *candidateGuid = [vote objectForKey:@"candidate"];
			
			Position *position = [self getObject:@"Position" byGuid:positionGuid];
			Candidate *candidate = [self getObject:@"Candidate" byGuid:candidateGuid];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid];
			
			if (![viewable boolValue])
			{
				if (position != nil && friend != nil) {
					/* check if the friend ballot vote already exists */
					FriendBallotVote *existingVote = [self getVoteForPosition:position byAuthor:friend];
					if (existingVote != nil) {
						NSLog(@"Found existing FriendBallotVote, but incoming vote is not viewable, so delete");
						[_context deleteObject:existingVote];
						NSError *err = nil;
						[_context save:&err];
						if (err != nil) {
							NSLog(@"Error: %@", [err userInfo]);
						}
					}
				}
			}
			else if (position != nil && candidate != nil && friend != nil) {
				if (candidate.position == position) {
					/* check if the friend ballot vote already exists */					
					FriendBallotVote *existingVote = [self getVoteForPosition:position byAuthor:friend];
					
					if (existingVote != nil) {
						/* existing friend ballot vote, so update */
						NSLog(@"Found existing FriendBallotVote, updating certain attributes");
						NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
						
						existingVote.forCandidate = candidate;
						existingVote.statement = statement;
						existingVote.date = date;
						
						NSError *err = nil;
						[_context save:&err];
						[date release];
						
						if (err != nil) {
							NSLog(@"Error: %@", [err userInfo]);
						}
					}
					else {
						/* insert new friend ballot vote */
						NSLog(@"Inserting new friend ballot vote");
						NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
						
						FriendBallotVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendBallotVote" inManagedObjectContext:_context];
						voteObj.forCandidate = candidate;
						voteObj.forPosition = position;
						voteObj.author = friend;
						voteObj.date = date;
						voteObj.statement = statement;
						
						NSError *err = nil;
						[_context save:&err];
						[date release];
						
						if (err != nil) {
							NSLog(@"Error: %@", [err userInfo]);
						}
					}
				}
			}
			else {
				NSLog(@"Some value was nil..");
			}

		}
		else if ([@"MeasureVote" isEqualToString:type]) {
			/* cases 1) insert 2) update 3) delete */
			/* TODO: doesn't handle the delete case */
			NSNumber *viewable = [vote objectForKey:@"viewable"];
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSNumber *voteValue = [vote objectForKey:@"vote"];
			NSString *measureGuid = [vote objectForKey:@"measure"];
			
			Measure *measure = [self getObject:@"Measure" byGuid:measureGuid];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid];
			
			if (![viewable boolValue])
			{
				if (measure != nil && friend != nil) {
					/* check if the friend measure vote already exists */
					FriendMeasureVote *existingVote = [self getVoteForMeasure:measure byAuthor:friend];
					if (existingVote != nil) {
						NSLog(@"Found existing FriendMeasureVote, but incoming vote is not viewable, so delete");
						[_context deleteObject:existingVote];
						NSError *err = nil;
						[_context save:&err];
						if (err != nil) {
							NSLog(@"Error: %@", [err userInfo]);
						}
					}
				}
			}
			else if (measure != nil && friend != nil) {
				/* check if the friend measure vote already exists */
				FriendMeasureVote *existingVote = [self getVoteForMeasure:measure byAuthor:friend];

				if (existingVote != nil) {
					/* existing friend measure vote, so update */
					NSLog(@"Found existing FriendMeasureVote, updating certain attributes");
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
					
					existingVote.vote = voteValue;
					existingVote.statement = statement;
					existingVote.date = date;
					
					NSError *err = nil;
					[_context save:&err];
					[date release];
					
					if (err != nil) {
						NSLog(@"Error: %@", [err userInfo]);
					}
				}
				else {
					/* insert new friend measure vote */
					NSLog(@"Inserting new friend measure vote");
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
					
					FriendMeasureVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendMeasureVote" inManagedObjectContext:_context];
					voteObj.forMeasure = measure;
					voteObj.vote = voteValue;
					voteObj.author = friend;
					voteObj.statement = statement;
					voteObj.date = date;
					
					NSError *err = nil;
					[_context save:&err];
					[date release];
					
					if (err != nil) {
						NSLog(@"Error: %@", [err userInfo]);
					}
				}
			}
			else {
				NSLog(@"Some value was nil..");
			}
		}
		else {
			NSLog(@"Unexpected type: %@", type);
		}
	}
	
	return YES;
}

- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_context];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"guid == %@", guid]];
	
	NSError *err = nil;
	NSArray *array = [_context executeFetchRequest:fetchRequest error:&err];
	[fetchRequest release];
	if (err != nil || array == nil) {
		return nil;
	}
	if ([array count] == 0) {
		return nil;
	}
	else if ([array count] == 2) {
		NSLog(@"Found multiple objects (%@) with the same guid (%@), returning first object", entityName, guid);
	}
	
	return [array objectAtIndex:0];
}


- (id)getFriends {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/friends"];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	
	NSError *httpError = [request error];
	if (httpError != nil) {
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSError *parseError = nil;
		NSArray *friends = [parser objectWithString:json error:&parseError];	
		[json release];
		
		if (parseError != nil) {
			NSLog(@"Parse error: %@", [parseError userInfo]);
		}
		
		return friends;
	}

	return nil;	
}

- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error{
	for (NSDictionary *friend in friends) {
		NSString *guid = [friend objectForKey:@"guid"];
		NSString *name = [friend objectForKey:@"name"];
		NSString *facebookId = [friend objectForKey:@"facebookFriendId"];
		
		/* does the friend exist in the database already? */
		Friend *friendObj = [self getObject:@"Friend" byGuid:guid];
		if (friendObj != nil) {
			NSLog(@"Found existing Friend, updating certain attributes");
			friendObj.name = name;
		}
		else {
			friendObj = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:_context];
			friendObj.guid = guid;
			friendObj.name = name;
			
			/* query for facebook friend object */
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:_context];
			[fetchRequest setFetchLimit:1];
			[fetchRequest setEntity:entity];
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"friendId == %@", facebookId]];
			
			NSError *err = nil;
			NSArray *array = [_context executeFetchRequest:fetchRequest error:&err];
			[fetchRequest release];
			if (err != nil) {
				NSLog(@"Error: %@", [err userInfo]);
			}
			else if (array != nil && [array count] == 1) {
				friendObj.facebook = [array objectAtIndex:0];
			}
		}
	}
	
	return [_context save:error];
}

- (NSDictionary *)getElections:(vote_status *)status {
	/* http://stackoverflow.com/questions/5035132/how-to-sync-iphone-core-data-with-web-server-and-then-push-to-other-devices */
	/* http://petermcintyre.com/2010/11/04/consume-json-rest-in-ios/ */
	/* http://developer.apple.com/library/IOs/#documentation/Foundation/Reference/NSURLConnectionDelegate_Protocol/Reference/Reference.html */
	/* http://blog.zachwaugh.com/post/309924609/how-to-use-json-in-cocoaobjective-c */
	
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/elections"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
//		NSLog(@"Error sending request: %@", [error userInfo]);
		
		*status = HTTP_ERROR;
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		*status = OK;
		
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSDictionary *elections = [parser objectWithString:json error:&error];
		[json release];
		
		if (error != nil) {
			NSLog(@"Error parsing JSON: %@", [error userInfo]);
		}
		
		return elections;
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		*status = SERVER_ERROR;
		/* TODO: log to disk */
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		*status = BAD_REQUEST;
		/* TODO: log to disk */
	}
	else {
		/* unexpected response */
		*status = UNEXPECTED_RESPONSE;
		/* TODO: log to disk */
	}
	
	return nil;
}

- (election_status)getElection:(NSDictionary **)election
					  withGuid:(NSString *)guid
			  withLastModified:(NSDate *)time
		   withNewModifiedTime:(NSDate **)newTime
					 withError:(NSError **)httpError {
	/* http://stackoverflow.com/questions/5035132/how-to-sync-iphone-core-data-with-web-server-and-then-push-to-other-devices */
	/* http://petermcintyre.com/2010/11/04/consume-json-rest-in-ios/ */
	/* http://developer.apple.com/library/IOs/#documentation/Foundation/Reference/NSURLConnectionDelegate_Protocol/Reference/Reference.html */
	/* http://blog.zachwaugh.com/post/309924609/how-to-use-json-in-cocoaobjective-c */
	
	*newTime = nil;
	*httpError = nil;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss zzz";
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	df.locale = locale;
	
	/* TODO: this should be asynchronous */
	//NSString *url = [NSString stringWithFormat:@"http://localhost:8080/election?election=%@", guid];
	NSURL *url = [self createURL:[NSString stringWithFormat:@"/election?election=%@", guid]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	if (time != nil) {
		[request addRequestHeader:@"If-Modified-Since" value:[df stringFromDate:time]];
	}
	
	[request startSynchronous];
	
//	NSDictionary *election = nil;
	*httpError = [request error];
	
	LogDebug(@"%@ -> %d", [request url], [request responseStatusCode]);
	
	election_status status;
	if (*httpError != nil) {
	}
	else if ([request responseStatusCode] == 200) {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSError *parseError = nil;
		*election = [parser objectWithString:json error:&parseError];	
//		NSLog(@"JSON %@", json);
		[json release];
		
		if (parseError != nil) {
			NSLog(@"Parse error: %@", [parseError userInfo]);
		}
		
		NSString *newLastModified = [[request responseHeaders] objectForKey:@"Last-Modified"];
		*newTime = [df dateFromString:newLastModified];
		status = ES_OK;
	}
	else if ([request responseStatusCode] == 404) {
		/* NOT_FOUND */
		//NSLog(@"Election '%@' does not exist", guid);
		status = ES_NOT_FOUND;
	}
	else if ([request responseStatusCode] == 410) {
		/* GONE */
		//NSLog(@"Election '%@' is closed", guid);
		status = ES_CLOSED;
	}
	else if ([request responseStatusCode] == 304) {
		/* NOT_MODIFIED */
		//NSLog(@"Election '%@' was not modified", guid);
		status = ES_NOT_MODIFIED;
	}
	
	[df release];
	[locale release];
	
	return status;
}

- (BOOL)insertElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error {
	NSString *guid = [election objectForKey:@"guid"];
	NSString *title = [election objectForKey:@"title"];
	NSString *icon = [election objectForKey:@"icon"];
	NSNumber *dateValue = [election objectForKey:@"date"];
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
	
	Election *electionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:_context];
	electionObj.status = [NSNumber numberWithBool:YES];
	electionObj.guid = guid;
	electionObj.title = title;
	electionObj.icon = icon;
	electionObj.date = date;
	electionObj.lastModified = time;
	[date release];
	
	NSArray *positions = [election objectForKey:@"positions"];
	if (positions != nil) {
		for (NSDictionary *position in positions) {
			// guid
			NSString *positionGuid = [position objectForKey:@"guid"];
			// title
			NSString *title = [position objectForKey:@"title"];
			// level
			NSString *level = [position objectForKey:@"level"];
			// levelOrder
			NSNumber *levelOrder = [position objectForKey:@"levelOrder"];
			// titleOrder
			NSNumber *titleOrder = [position objectForKey:@"titleOrder"];
			
			//NSLog(@"%@ %@ %@ %@ %@", guid, title, level, levelOrder, titleOrder);
			
			Position *positionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:_context];
			positionObj.guid = positionGuid;
			positionObj.level = level;
			positionObj.levelOrder = levelOrder;
			positionObj.title = title;
			positionObj.titleOrder = titleOrder;
			[electionObj addPositionsObject:positionObj];
			
			// candidates
			NSArray *candidates = [position objectForKey:@"candidates"];
			if (candidates != nil) {
				for (NSDictionary *candidate in candidates) {
					NSString *candidateGuid = [candidate objectForKey:@"guid"];
					NSString *name = [candidate objectForKey:@"name"];
					id subtitle = [candidate objectForKey:@"subtitle"];
					NSNumber *displayOrder = [candidate objectForKey:@"displayOrder"];
					
					//NSLog(@"%@ %@ %@ %@", name, party, occupation, displayOrder);
					
					Candidate *candidateObj = [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:_context];
					candidateObj.guid = candidateGuid;
					candidateObj.name = name;
					candidateObj.subtitle = subtitle == [NSNull null] ? nil : subtitle;
					candidateObj.displayOrder = displayOrder;
					[positionObj addCandidatesObject:candidateObj];
				}
			}
		}
	}
	
	NSArray *measures = [election objectForKey:@"measures"];
	if (measures != nil) {
		for (NSDictionary *measure in measures) {
			NSString *guid = [measure objectForKey:@"guid"];
			NSString *identifier = [measure objectForKey:@"identifier"];
			NSString *title = [measure objectForKey:@"title"];
			NSString *level = [measure objectForKey:@"level"];
			NSNumber *levelOrder = [measure objectForKey:@"levelOrder"];
			NSNumber *displayOrder = [measure objectForKey:@"displayOrder"];
			NSString *longDescription = [measure objectForKey:@"longDescription"];
			
			//NSLog(@"%@ %@ %@ %@ %@ %@ %@", guid, identifier, title, level, levelOrder, displayOrder, longDescription);
			
			Measure *measureObj = [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:_context];
			measureObj.guid = guid;
			measureObj.identifier = identifier;
			measureObj.title = title;
			measureObj.longDescription = longDescription;
			measureObj.level = level;
			measureObj.levelOrder = levelOrder;
			measureObj.displayOrder = displayOrder;
			[electionObj addMeasuresObject:measureObj];
		}
	}
	
	return [_context save:error];
}

- (BOOL)updateElection:(Election *)electionObj withObject:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error {
	NSString *electionGuid = [election objectForKey:@"guid"];
	NSString *title = [election objectForKey:@"title"];
	NSNumber *dateValue = [election objectForKey:@"date"];
	NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
	
	electionObj.title = title;
	electionObj.date = date;
	electionObj.lastModified = time;
	[date release];
	
	// positions
	NSArray *positions = [election objectForKey:@"positions"];
	if (positions != nil) {
		for (NSDictionary *position in positions) {
			// guid
			NSString *positionGuid = [position objectForKey:@"guid"];
			// title
			NSString *title = [position objectForKey:@"title"];
			// level
			NSString *level = [position objectForKey:@"level"];
			// levelOrder
			NSNumber *levelOrder = [position objectForKey:@"levelOrder"];
			// titleOrder
			NSNumber *titleOrder = [position objectForKey:@"titleOrder"];
			
			//NSLog(@"%@ %@ %@ %@ %@", guid, title, level, levelOrder, titleOrder);
			
			Position *positionObj = [self getObject:@"Position" byGuid:positionGuid];
			if (positionObj == nil) {
				NSLog(@"Adding new position '%@' to election '%@'", positionGuid, electionGuid);
				
				positionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:_context];
				positionObj.guid = positionGuid;
				[electionObj addPositionsObject:positionObj];
			}
			
			if (positionObj.forElection == electionObj) {
				positionObj.level = level;
				positionObj.levelOrder = levelOrder;
				positionObj.title = title;
				positionObj.titleOrder = titleOrder;
				
				// candidates
				NSArray *candidates = [position objectForKey:@"candidates"];
				if (candidates != nil) {
					for (NSDictionary *candidate in candidates) {
						NSString *candidateGuid = [candidate objectForKey:@"guid"];
						NSString *name = [candidate objectForKey:@"name"];
						id subtitle = [candidate objectForKey:@"subtitle"];
						NSNumber *displayOrder = [candidate objectForKey:@"displayOrder"];
						
						//NSLog(@"%@ %@ %@ %@", name, party, occupation, displayOrder);
						
						Candidate *candidateObj = [self getObject:@"Candidate" byGuid:candidateGuid];
						if (candidateObj == nil) {
							NSLog(@"Adding new candidate '%@' to position '%@'", candidateGuid, positionGuid);
							
							candidateObj = [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:_context];
							candidateObj.guid = candidateGuid;
							[positionObj addCandidatesObject:candidateObj];
						}
						
						if (candidateObj.position == positionObj) {
							candidateObj.name = name;
							candidateObj.subtitle = subtitle == [NSNull null] ? nil : subtitle;
							candidateObj.displayOrder = displayOrder;
						}
						else {
							NSLog(@"Candidate doesn't belong in position");
						}

					}
				}
			}
			else {
				NSLog(@"Position doesn't belong in election");
			}

		}
	}
	
	// measures
	NSArray *measures = [election objectForKey:@"measures"];
	if (measures != nil) {
		for (NSDictionary *measure in measures) {
			NSString *measureGuid = [measure objectForKey:@"guid"];
			NSString *identifier = [measure objectForKey:@"identifier"];
			NSString *title = [measure objectForKey:@"title"];
			NSString *level = [measure objectForKey:@"level"];
			NSNumber *levelOrder = [measure objectForKey:@"levelOrder"];
			NSNumber *displayOrder = [measure objectForKey:@"displayOrder"];
			NSString *longDescription = [measure objectForKey:@"longDescription"];
			
			//NSLog(@"%@ %@ %@ %@ %@ %@ %@", guid, identifier, title, level, levelOrder, displayOrder, longDescription);
			
			Measure *measureObj = [self getObject:@"Measure" byGuid:measureGuid];

			if (measureObj == nil) {
				NSLog(@"Adding new measure '%@' to election '%@'", measureGuid, electionGuid);
				
				measureObj = [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:_context];
				measureObj.guid = measureGuid;
				[electionObj addMeasuresObject:measureObj];
			}
			
			if (measureObj.forElection == electionObj) {				
				measureObj.identifier = identifier;
				measureObj.title = title;
				measureObj.longDescription = longDescription;
				measureObj.level = level;
				measureObj.levelOrder = levelOrder;
				measureObj.displayOrder = displayOrder;
			}
			else {
				NSLog(@"Measure doesn't belong in election");
			}

		}
	}
	
	return [_context save:error];
}

- (void)dealloc {
	[_context release];
	if (deviceID != nil) {
		[deviceID release];
	}
	[parser release];
    [super dealloc];
}

@end
