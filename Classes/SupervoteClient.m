//
//  SupervoteClient.m
//  Supervote
//
//  Created by augusto callejas on 11/19/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "SupervoteClient.h"

#import "Candidate.h"
#import "Election.h"
#import "Friend.h"
#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"
#import "Measure.h"
#import "Position.h"

static NSString *kDeviceIDHeaderKey = @"DeviceID";

@implementation SupervoteClient

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
	if (self) {
		parser = [[SBJSON alloc] init];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"DeviceID"]) {
			deviceID = [[defaults objectForKey:@"DeviceID"] retain];
			NSLog(@"Loaded device ID '%@'", deviceID);
		}
		
		_context = [context retain];
	}
    return self;
}

- (BOOL)isRegistered {
	return deviceID != nil;
}

/* TODO: this method should take arguments and return some value, and also have an error argument */
- (BOOL)registerDevice:(NSString *)zip5or9 withError:(NSError **)error {
	/* TODO: this should be asynchronous */
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/registration"];
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
		NSLog(@"Registered new device ID '%@'", deviceID);
		registered = YES;
	}
	else if ([request responseStatusCode] == 400) {
		registered = NO;
	}
	else {
		NSLog(@"Unexpected status code response: %d", [request responseStatusCode]);
	}
	
	return registered;
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

- (void)sendFacebookAccessToken:(NSString *)accessToken {
	/* TODO: this should be asynchronous */
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/accessToken"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:@"fb" forKey:@"socialnet"];
	[request setPostValue:accessToken forKey:@"access_token"];

	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
}

- (void)sendBallotVote:(BallotVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/voteCandidate"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forPosition.guid forKey:@"position"];
	[request setPostValue:vote.forCandidate.guid forKey:@"candidate"];
	[request setPostValue:vote.statement forKey:@"statement"];
	[request setPostValue:vote.viewableByFriends forKey:@"viewable_by_friends"];
	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
}

- (void)sendMeasureVote:(MeasureVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/voteMeasure"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forMeasure.guid forKey:@"measure"];
	[request setPostValue:vote.statement forKey:@"statement"];
	[request setPostValue:vote.viewableByFriends forKey:@"viewable_by_friends"];
	if (vote.vote != nil) {
		[request setPostValue:vote.vote forKey:@"vote"];
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
}

- (id)getVotesForBallot:(NSString *)electionGuid{
	/* TODO: this should be asynchronous */
	NSString *url = [NSString stringWithFormat:@"http://localhost:8080/votes?election=%@", electionGuid];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *votes = [parser objectWithString:json error:&error];	
		[json release];
		
		if (error != nil) {
			NSLog(@"error: %@", [error userInfo]);
			return nil;
		}
		
		return votes;
	}

	return nil;
}

- (BOOL)insertVotes:(NSArray *)votes withError:(NSError **)error{
	//NSLog(@"Inserting %d votes", [votes count]);
	for (NSDictionary *vote in votes) {
		NSString *type = [vote objectForKey:@"type"];
		
		if ([@"BallotVote" isEqualToString:type]) {
			/* cases 1) insert 2) update 3) delete */
			/* TODO: doesn't handle the delete case */
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *positionGuid = [vote objectForKey:@"position"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSString *candidateGuid = [vote objectForKey:@"candidate"];
			
			Position *position = [self getObject:@"Position" byGuid:positionGuid];
			Candidate *candidate = [self getObject:@"Candidate" byGuid:candidateGuid];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid];

			if (position != nil && candidate != nil && friend != nil) {
				if (candidate.position == position) {
					/* check if the friend ballot vote already exists */
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
						/* existing friend ballot vote, so update */
						NSLog(@"Found existing ballot vote, updating certain attributes");
						NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
						
						FriendBallotVote *existingVote = [array objectAtIndex:0];
						existingVote.forCandidate = candidate;
						existingVote.statement = statement;
						existingVote.date = date;
						
						error = nil;
						[_context save:&error];
						[date release];
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
						
						error = nil;
						[_context save:&error];
						[date release];
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
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSNumber *voteValue = [vote objectForKey:@"vote"];
			NSString *measureGuid = [vote objectForKey:@"measure"];
			
			Measure *measure = [self getObject:@"Measure" byGuid:measureGuid];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid];
			
			if (measure != nil && friend != nil) {
				
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
					NSLog(@"Error while querying for existing friend measure vote: %@", [error userInfo]);
				}
				else if ([array count] == 1) {
					/* existing friend measure vote, so update */
					NSLog(@"Found existing measure vote, updating certain attributes");
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
					
					FriendMeasureVote *existingVote = [array objectAtIndex:0];
					existingVote.vote = voteValue;
					existingVote.statement = statement;
					existingVote.date = date;
					
					error = nil;
					[_context save:&error];
					[date release];
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
					
					error = nil;
					[_context save:&error];
					[date release];
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
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/friends"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *elections = [parser objectWithString:json error:&error];	
		[json release];
		
		if (error != nil) {
		}
		
		return elections;
	}

	return nil;	
}

- (BOOL)insertFriends:(NSArray *)friends withError:(NSError **)error{
	for (NSDictionary *friend in friends) {
		NSString *guid = [friend objectForKey:@"guid"];
		NSString *name = [friend objectForKey:@"name"];
		NSString *facebookId = [friend objectForKey:@"facebookFriendId"];
		
		/* does the friend exist in the database already? */
		/* TODO guid is a good way to check if the friend already exists, but what about changes? */
		Friend *friendFound = [self getObject:@"Friend" byGuid:guid];
		if (friendFound != nil) {
			NSLog(@"Friend already in database, but are there updates, like name?");
			continue;
		}
		
		Friend *friendObj = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:_context];
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
	
	return [_context save:error];
}

- (id)getElections {
	/* http://stackoverflow.com/questions/5035132/how-to-sync-iphone-core-data-with-web-server-and-then-push-to-other-devices */
	/* http://petermcintyre.com/2010/11/04/consume-json-rest-in-ios/ */
	/* http://developer.apple.com/library/IOs/#documentation/Foundation/Reference/NSURLConnectionDelegate_Protocol/Reference/Reference.html */
	/* http://blog.zachwaugh.com/post/309924609/how-to-use-json-in-cocoaobjective-c */
	
	/* TODO: this should be asynchronous */
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/elections"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *elections = [parser objectWithString:json error:&error];	
		[json release];
		
		if (error != nil) {
			NSLog(@"error: %@", [error userInfo]);
		}
		
		return elections;
	}
	
	return nil;
}

- (BOOL)insertElections:(NSArray *)elections withError:(NSError **)error{
	for (NSDictionary *election in elections) {
		NSString *guid = [election objectForKey:@"guid"];
		
		/* does the election exist in the database already? */
		/* TODO guid is a good way to check if the election already exists, but what about changes? */		
		Election *electionFound = [self getObject:@"Election" byGuid:guid];
		if (electionFound != nil) {
			NSLog(@"Election already in database, but are there updates, like date?");
			continue;
		}
		
		NSString *title = [election objectForKey:@"title"];
		NSNumber *dateValue = [election objectForKey:@"date"];
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
		
		Election *electionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:_context];
		electionObj.guid = guid;
		electionObj.title = title;
		electionObj.date = date;
		[date release];
		
		NSArray *positions = [election objectForKey:@"positions"];
		if (positions != nil) {
			for (NSDictionary *position in positions) {
				// guid
				NSString *guid = [position objectForKey:@"guid"];
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
				positionObj.guid = guid;
				positionObj.level = level;
				positionObj.levelOrder = levelOrder;
				positionObj.title = title;
				positionObj.titleOrder = titleOrder;
				[electionObj addPositionsObject:positionObj];
				
				// candidates
				NSArray *candidates = [position objectForKey:@"candidates"];
				if (candidates != nil) {
					for (NSDictionary *candidate in candidates) {
						NSString *guid = [candidate objectForKey:@"guid"];
						NSString *name = [candidate objectForKey:@"name"];
						id party = [candidate objectForKey:@"party"];
						id occupation = [candidate objectForKey:@"occupation"];
						NSNumber *displayOrder = [candidate objectForKey:@"displayOrder"];
						
						//NSLog(@"%@ %@ %@ %@", name, party, occupation, displayOrder);
						
						Candidate *candidateObj = [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:_context];
						candidateObj.guid = guid;
						candidateObj.name = name;
						if (party != [NSNull null]) {
							candidateObj.party = party;
						}
						candidateObj.displayOrder = displayOrder;
						if (occupation != [NSNull null]) {
							candidateObj.occupation = occupation;
						}
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
