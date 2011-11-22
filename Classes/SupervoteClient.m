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
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Election" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"guid == %@", guid]];
		
//		NSLog(@"date %@", date);
		NSError *error = nil;
		NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		if (error != nil || (array != nil && [array count] > 0)) {
//			NSLog(@"Skipping insert");
			continue;
		}
		
		Election *electionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:context];
		electionObj.guid = guid;
		electionObj.title = title;
		electionObj.date = date;
		[date release];

//		Election *election1 = (Election *) [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:self.managedObjectContext];
//		election1.title = @"2008 General Election";
//		NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
//		dateFormatter1.dateFormat = @"dd-MM-yy";
//		election1.date = [dateFormatter1 dateFromString:@"04-11-08"];
//		[dateFormatter1 release];
		
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
				
//				Position *position1 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
//				position1.level = @"President of the United States";
//				position1.levelOrder = [NSNumber numberWithInt:0];
//				position1.title = @"President and Vice President";
//				position1.titleOrder = [NSNumber numberWithInt:0];
//				[election1 addPositionsObject:position1];
				
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

//						Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
//						candidate1.name = @"Barack Obama";
//						candidate1.party = @"Democratic";
//						candidate1.displayOrder = [NSNumber numberWithInt:0];
//						candidate1.occupation = nil;
//						[position1 addCandidatesObject:candidate1];
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
				
//				Measure *measure1 = (Measure *) [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:self.managedObjectContext];
//				measure1.identifier = @"1A";
//				measure1.title = @"Safe, Reliable High-Speed Passenger Train Bond Act";
//				measure1.longDescription = @"To provide Californians a safe...";
//				measure1.level = @"Measures submitted to the voters";
//				measure1.levelOrder = [NSNumber numberWithInt:0];
//				measure1.displayOrder = [NSNumber numberWithInt:0];
//				measure1.forElection = election1;
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
