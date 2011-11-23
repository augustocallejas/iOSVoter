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

@implementation SupervoteClient

-(id) init {
    self = [super init];
	if (self) {
		parser = [[SBJSON alloc] init];
	}
    return self;
}

/* TODO: this method should take arguments and return some value, and also have an error argument */
- (id)registerDevice {
//	/* TODO: release */
//	responseData = [[NSMutableData alloc] init];
//	//NSURL *url = [NSURL URLWithString:@"http://search.twitter.com/search.json?q=earthquake"];
//	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/registration?z=91104&d=1"];
//	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//	[request release];
//	[connection start];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/registration?z=91104&d=1"]];
	NSError *error;
	//NSData *response = [
	/* TODO: ignoring the response! */
	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//	NSString *json = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//	NSArray *elections = [parser objectWithString:json error:&error];	
	
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

- (void)sendFacebookAccessToken:(NSString *)accessToken {
	NSString *url = [NSString stringWithFormat:@"http://localhost:8080/accessToken?socialnet=fb&access_token=%@", accessToken];
	/* TODO: this should be asynchronous */
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//	NSString *json = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//	NSArray *elections = [parser objectWithString:json error:&error];	
//	[json release];
	
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
}

- (id)getVotesForBallot:(NSString *)guid{
	/* TODO: this should be asynchronous */
	NSString *url = [NSString stringWithFormat:@"http://localhost:8080/votes?election=%@", guid];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *json = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSArray *votes = [parser objectWithString:json error:&error];	
	[json release];
	
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
	
	return votes;
}

- (BOOL)insertVotes:(NSArray *)votes intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error{
	for (NSDictionary *vote in votes) {
		NSString *type = [vote objectForKey:@"type"];
		
		if ([@"FriendBallotVote" isEqualToString:type]) {
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *positionGuid = [vote objectForKey:@"position"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSString *candidateGuid = [vote objectForKey:@"candidate"];
			
			Position *position = [self getObject:@"Position" byGuid:positionGuid fromContext:context];
			Candidate *candidate = [self getObject:@"Candidate" byGuid:candidateGuid fromContext:context];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid fromContext:context];
			
			if (position != nil && candidate != nil && friend != nil) {
				if (candidate.position == position) {
					
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];

					FriendBallotVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendBallotVote" inManagedObjectContext:context];
					voteObj.forCandidate = candidate;
					voteObj.forPosition = position;
					voteObj.author = friend;
					voteObj.date = date;
					voteObj.statement = statement;
					
					NSError *error = nil;
					[context save:&error];
					[date release];
				}
			}
			else {
				NSLog(@"Some value was nil..");
			}

		}
		else if ([@"FriendMeasureVote" isEqualToString:type]) {
			NSNumber *dateValue = [vote objectForKey:@"date"];
			NSString *authorGuid = [vote objectForKey:@"author"];
			NSString *statement = [vote objectForKey:@"statement"];
			NSNumber *voteValue = [vote objectForKey:@"vote"];
			NSString *measureGuid = [vote objectForKey:@"measure"];
			
			Measure *measure = [self getObject:@"Measure" byGuid:measureGuid fromContext:context];
			Friend *friend = [self getObject:@"Friend" byGuid:authorGuid fromContext:context];
			
			if (measure != nil && friend != nil) {
				NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
								
				FriendMeasureVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendMeasureVote" inManagedObjectContext:context];
				voteObj.forMeasure = measure;
				voteObj.vote = voteValue;
				voteObj.author = friend;
				voteObj.statement = statement;
				voteObj.date = date;
				
				NSError *error = nil;
				[context save:&error];
				[date release];
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

- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid fromContext:(NSManagedObjectContext *)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"guid == %@", guid]];
	
	NSError *err = nil;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&err];
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
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/friends"]];
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *json = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSArray *elections = [parser objectWithString:json error:&error];	
	[json release];
	
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
	
	return elections;	
}

- (BOOL)insertFriends:(NSArray *)friends intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error{
	for (NSDictionary *friend in friends) {
		NSString *guid = [friend objectForKey:@"guid"];
		NSString *name = [friend objectForKey:@"name"];
		NSString *facebookId = [friend objectForKey:@"facebookFriendId"];
		
		/* does the friend exist in the database already? */
		/* TODO guid is a good way to check if the friend already exists, but what about changes? */
		Friend *friendFound = [self getObject:@"Friend" byGuid:guid fromContext:context];
		if (friendFound != nil) {
			NSLog(@"Friend already in database, but are there updates, like name?");
			continue;
		}
		
		Friend *friendObj = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
		friendObj.guid = guid;
		friendObj.name = name;
		
		/* query for facebook friend object */
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:context];
		[fetchRequest setFetchLimit:1];
		[fetchRequest setEntity:entity];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"friendId == %@", facebookId]];
		NSError *err = nil;
		NSArray *array = [context executeFetchRequest:fetchRequest error:&err];
		[fetchRequest release];
		if (err != nil) {
			NSLog(@"Error: %@", [err userInfo]);
		}
		else if (array != nil && [array count] == 1) {
			friendObj.facebook = [array objectAtIndex:0];
		}
	}
	
	return [context save:error];
}

- (id)getElections {
	/* http://stackoverflow.com/questions/5035132/how-to-sync-iphone-core-data-with-web-server-and-then-push-to-other-devices */
	/* http://petermcintyre.com/2010/11/04/consume-json-rest-in-ios/ */
	/* http://developer.apple.com/library/IOs/#documentation/Foundation/Reference/NSURLConnectionDelegate_Protocol/Reference/Reference.html */
	/* http://blog.zachwaugh.com/post/309924609/how-to-use-json-in-cocoaobjective-c */
	
	/* TODO: this should be asynchronous */
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/elections"]];
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *json = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSArray *elections = [parser objectWithString:json error:&error];	
	[json release];
	
	if (error != nil) {
		NSLog(@"error: %@", [error userInfo]);
	}
	
	return elections;
	//	responseData = [[NSMutableData alloc] init];
	//	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/elections"];
	//	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	//	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	//	[request release];
	//	[connection start];
}

- (BOOL)insertElections:(NSArray *)elections intoManagedContext:(NSManagedObjectContext *)context withError:(NSError **)error{
	for (NSDictionary *election in elections) {
		NSString *guid = [election objectForKey:@"guid"];
		NSString *title = [election objectForKey:@"title"];
		NSNumber *dateValue = [election objectForKey:@"date"];
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
		
		/* does the election exist in the database already? */
		/* TODO guid is a good way to check if the election already exists, but what about changes? */		
		Election *electionFound = [self getObject:@"Election" byGuid:guid fromContext:context];
		if (electionFound != nil) {
			NSLog(@"Election already in database, but are there updates, like date?");
			continue;
		}
		
		Election *electionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:context];
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
				
				Position *positionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:context];
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
						
						Candidate *candidateObj = [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:context];
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
				
				Measure *measureObj = [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:context];
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
	
	return [context save:error];
}

- (void)dealloc {
	[parser release];
    [super dealloc];
}

@end
