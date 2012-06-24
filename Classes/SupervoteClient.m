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
#import "PotentialDistrictRegistration.h"
#import "PotentialGovernmentRegistration.h"

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
- (BOOL)registerDevice:(NSString *)zip5or9 withLanguage:(NSString *)language withError:(NSError **)error {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/registration"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:zip5or9 forKey:@"z"];
	[request setPostValue:language forKey:@"l"];
	
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
	NSURL *url = [self createURL:@"/voter/v1/auth/profile"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss zzz";
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	df.locale = locale;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id lastModified = [defaults objectForKey:@"RegistrationLastModified"];
	if (lastModified != nil) {
		[request addRequestHeader:@"If-Modified-Since" value:[df stringFromDate:lastModified]];
	}
	
	id profile = nil;
	
	[request startSynchronous];
	*error = [request error];
	if (*error == nil) {
		if ([request responseStatusCode] == 200) {
			NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
			LogDebug(@"Server returned %d from request '%@': %@", 200, [url path], json); 
			
			NSError *parseError = nil;
			profile = [parser objectWithString:json error:&parseError];	
			
			if (parseError != nil) {
				LogError(@"Error parsing JSON (%@): %@", json, [parseError localizedDescription]);
			}
			[json release];
			
			NSString *newLastModified = [[request responseHeaders] objectForKey:@"Last-Modified"];
			lastModified = [df dateFromString:newLastModified];
			
			/* save LastModified */
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:lastModified forKey:@"RegistrationLastModified"];
			[defaults synchronize];
			
			LogInfo(@"Updating last modified time for voter registration: %@", lastModified);
		}
		else if (request.responseStatusCode == 304) {
			/* NOT MODIFIED */
			LogInfo(@"Voter registration is up to date");
		}
		else {
			LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
		}
	}
	
	[df release];
	[locale release];
	
	return profile;
}

- (BOOL)deleteGovernmentRegistrationsAbove:(int)displayOrder withError:(NSError **)error {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentRegistration" inManagedObjectContext:_context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayOrder > %@", [NSNumber numberWithInt:displayOrder]];
	[request setPredicate:predicate];
	
	NSArray *results = [_context executeFetchRequest:request error:error];
	if (results != nil) {
		for (GovernmentRegistration *registration in results) {
			[_context deleteObject:registration];
		}
	}
	
	return [_context save:error];
}

- (void)findOrInsertGovernmentRegistration:(NSDictionary *)object withDisplayOrder:(int)displayOrder withParent:(Government *)parent withError:(NSError **)error {
	NSDictionary *governmentObj = [object objectForKey:@"government"];
	
	Government *government = [self findOrInsertGovernment:governmentObj withParent:parent withError:error];
	if (government != nil) {
		/* query for existing GovernmentRegistration at displayOrder */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentRegistration" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayOrder = %@", [NSNumber numberWithInt:displayOrder]];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];

		if (results != nil) {
			NSNumber *dateValue = [object objectForKey:@"createdTime"];
			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
			
			GovernmentRegistration *registration = nil;
			BOOL insertObject = YES;
			if ([results count] == 1) {
				registration = [results objectAtIndex:0];
				
				if ([registration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
					LogInfo(@"Current GovernmentRegistration (type=%@, name=%@, displayOrder=%d) is out of date (current=%@ vs incoming=%@), deleting current registration",
							registration.government.governmentType.id,
							registration.government.name,
							displayOrder,
							registration.createdTime,
							createdTime);
					
					[_context deleteObject:registration];
					
					[self deleteGovernmentRegistrationsAbove:displayOrder withError:error];
				}
				else {
					LogInfo(@"Current GovernmentRegistration (type=%@, name=%@, displayOrder=%d) with latest timestamp, no update necessary: (current=%@ vs incoming=%@)",
							registration.government.governmentType.id,
							registration.government.name,
							displayOrder,
							registration.createdTime,
							createdTime);
					
					insertObject = NO;
				}
			}
			
			if (insertObject) {
				LogInfo(@"Inserting incoming GovernmentRegistration: (type=%@, name=%@, displayOrder=%d, createdTime=%@)",
						government.governmentType.id,
						government.name,
						displayOrder,
						createdTime);
							
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
					for (NSDictionary *districtRegistrationObj in districtRegistrations) {
						[self findOrInsertDistrictRegistration:districtRegistrationObj withParent:registration withError:error];
						
						if (*error != nil) {
							return;
						}
					}
				}
				
				NSArray *potentialDistrictRegistrations = [object objectForKey:@"potentialDistrictRegistrations"];
				if (potentialDistrictRegistrations != nil) {
					for (NSDictionary *potentialDistrictRegistrationObj in potentialDistrictRegistrations) {
						[self findOrInsertPotentialDistrictRegistration:potentialDistrictRegistrationObj
															 withParent:registration
															  withError:error];
						
						if (*error != nil) {
							return;
						}
					}
				}
				
				NSArray *potentialGovernmentRegistrations = [object objectForKey:@"potentialGovernmentRegistrations"];
				if (potentialGovernmentRegistrations != nil && [potentialGovernmentRegistrations count] > 0) {
					if ([potentialGovernmentRegistrations count] > 1) {
						LogWarn(@"Expected only one PotentialGovernmentRegistration, found many, only processing first element");
					}

					if (![self findOrInsertPotentialGovermentRegistration:[potentialGovernmentRegistrations objectAtIndex:0]
															   withParent:registration
																withError:error]) {
						return;
					}
				}
			}
		}
	}
}

- (void)findOrInsertDistrictRegistration:(NSDictionary *)object
							  withParent:(GovernmentRegistration *)parent
							   withError:(NSError **)error {
	NSDictionary *districtObj = [object objectForKey:@"district"];
	
	District *district = [self findOrInsertDistrict:districtObj withParent:parent.government withError:error];
	if (district != nil) {
		/* query for existing DistrictRegistration at displayOrder */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictRegistration" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registration = %@ and districtType = %@", parent, district.districtType];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (results != nil) {
			NSNumber *dateValue = [object objectForKey:@"createdTime"];
			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
			
			DistrictRegistration *registration = nil;
			BOOL insertObject = YES;
			if ([results count] == 1) {
				registration = [results objectAtIndex:0];
				
				if ([registration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
					LogInfo(@"Current DistrictRegistration (type=%@, name=%@) is out of date (current=%@ vs incoming=%@), deleting current registration",
							registration.district.districtType.id,
							registration.district.name,
							registration.createdTime,
							createdTime);
					
					[_context deleteObject:registration];
				}
				else {
					LogInfo(@"Current DistrictRegistration (type=%@) with latest timestamp, no update necessary: (current=%@ vs incoming=%@)",
							registration.districtType.id,
							registration.createdTime,
							createdTime);
					
					insertObject = NO;
				}
			}
			
			if (insertObject) {
				LogInfo(@"Inserting incoming DistrictRegistration (type=%@, name=%@, createdTime=%@)",
						district.districtType.id,
						district.name,
						createdTime);
				
				registration = [NSEntityDescription insertNewObjectForEntityForName:@"DistrictRegistration" inManagedObjectContext:_context];
				registration.districtType = district.districtType;
				registration.district = district;
				registration.registration = parent;
				registration.createdTime = createdTime;
				
				
				for (PotentialDistrictRegistration* obj in parent.potentialRegistrations) {
					if (obj.districtType == district.districtType) {
						LogInfo(@"Found obsolete PotentialDistrictRegistration, deleting (type=%@, createdTime=%@)",
								obj.districtType.name,
								obj.createdTime);
						[_context deleteObject:obj];
					}
				}
				
				[_context save:error];
			}
			[createdTime release];
		}
	}
}

- (BOOL)resolveGovernmentRegistration:(PotentialGovernmentRegistration *)potentialRegistration
					   withGovernment:(Government *)choice
					  withCreatedTime:(NSDate *)createdTime
							withError:(NSError **)error {
	GovernmentRegistration *registration = [NSEntityDescription insertNewObjectForEntityForName:@"GovernmentRegistration" inManagedObjectContext:_context];
	registration.government = choice;
	registration.createdTime = createdTime;
	registration.displayOrder = [NSNumber numberWithInt:([potentialRegistration.registration.displayOrder intValue] + 1)];
	
	LogInfo(@"Replacing current PotentialGovernmentRegistration (parent=%@, createdTime=%@) with chosen GovernmentRegistration (name=%@, createdTime=%@)",
			potentialRegistration.registration.government.name,
			potentialRegistration.createdTime,
			choice.name,
			registration.createdTime);
	
	[_context deleteObject:potentialRegistration];
	return [_context save:error];
}

- (BOOL)resolveDistrictRegistration:(PotentialDistrictRegistration *)potentialRegistration
					   withDistrict:(District *)district
					withCreatedTime:(NSDate *)createdTime
						  withError:(NSError **)error {
	DistrictRegistration *registration = [NSEntityDescription insertNewObjectForEntityForName:@"DistrictRegistration" inManagedObjectContext:_context];
	registration.districtType = district.districtType;
	registration.district = district;
	registration.registration = potentialRegistration.registration;
	registration.createdTime = createdTime;
	
	LogInfo(@"Replacing current PotentialDistrictRegistration (type=%@, createdTime=%@) with chosen DistrictRegistration (districtNum=%@, createdTime=%@)",
			potentialRegistration.districtType.id,
			potentialRegistration.createdTime,
			district.districtNum,
			registration.createdTime);
	
	[_context deleteObject:potentialRegistration];	
	return [_context save:error];
}

- (BOOL)findOrInsertPotentialGovermentRegistration:(NSDictionary *)object
										withParent:(GovernmentRegistration *)parent
										 withError:(NSError **) error {
	BOOL insertObject = YES;
	NSNumber *dateValue = [object objectForKey:@"createdTime"];
	NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
	
	if (parent.potentialGovernmentRegistration != nil) {
		if ([parent.potentialGovernmentRegistration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
			LogInfo(@"Current PotentialGovernmentRegistration (parent=%@) is out of date (current=%@ vs incoming=%@), deleting current registration",
					parent.government.name,
					parent.potentialGovernmentRegistration.createdTime,
					createdTime);
			
			parent.potentialGovernmentRegistration = nil;
		}
		else {
			LogInfo(@"Current PotentialGovernmentRegistration (parent=%@) with latest timestamp, no update necessary: (current=%@ vs incoming=%@)",
					parent.government.name,
					parent.potentialGovernmentRegistration.createdTime,
					createdTime);
			
			insertObject = NO;
		}
	}
	
	BOOL status = YES;
	if (insertObject) {
		LogInfo(@"Inserting incoming PotentialGovernmentRegistration (parent=%@, createdTime=%@)",
				parent.government.name,
				createdTime);
		
		PotentialGovernmentRegistration *registration = [NSEntityDescription insertNewObjectForEntityForName:@"PotentialGovernmentRegistration" inManagedObjectContext:_context];
		registration.createdTime = createdTime;
		registration.registration = parent;
	
		NSDictionary *choices = [object objectForKey:@"choices"];
		if (choices != nil) {
			for (NSDictionary *choice in choices) {
				Government *government = [self findOrInsertGovernment:choice withParent:parent.government withError:error];
				if (government == nil) {
					return NO;
				}
				
				[registration addChoicesObject:government];
			}
		}
		
		status = [_context save:error];
	}
	[createdTime release];
	
	return status;
}



- (void)findOrInsertPotentialDistrictRegistration:(NSDictionary *)object
									   withParent:(GovernmentRegistration *)parent
										withError:(NSError **) error {
	NSDictionary *districtTypeObj = [object objectForKey:@"districtType"];
	
	DistrictType *districtType = [self findOrInsertDistrictType:districtTypeObj withError:error];
	if (*error == nil) {
		/* query for existing PotentialDistrictRegistration at displayOrder */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"PotentialDistrictRegistration" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"registration = %@ and districtType = %@", parent, districtType];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (results != nil) {
			NSNumber *dateValue = [object objectForKey:@"createdTime"];
			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
			
			PotentialDistrictRegistration *registration = nil;
			BOOL insertObject = YES;
			if ([results count] == 1) {
				registration = [results objectAtIndex:0];
				
				if ([registration.createdTime timeIntervalSinceDate:createdTime] <= -1.0) {
					LogInfo(@"Current PotentialDistrictRegistration (type=%@) is out of date (current=%@ vs incoming=%@), deleting current registration",
							registration.districtType.id,
							registration.createdTime,
							createdTime);
					
					[_context deleteObject:registration];
				}
				else {
					LogInfo(@"Current PotentialDistrictRegistration (type=%@) with latest timestamp, no update necessary: (current=%@ vs incoming=%@)",
							registration.districtType.id,
							registration.createdTime,
							createdTime);
					
					insertObject = NO;
				}
			}
			
			if (insertObject) {
				LogInfo(@"Inserting incoming PotentialDistrictRegistration (type=%@, createdTime=%@)",
						districtType.id,
						createdTime);
				
				registration = [NSEntityDescription insertNewObjectForEntityForName:@"PotentialDistrictRegistration" inManagedObjectContext:_context];
				registration.districtType = districtType;
				registration.registration = parent;
				registration.createdTime = createdTime;
				
				NSDictionary *choices = [object objectForKey:@"choices"];
				if (choices != nil) {
					for (NSDictionary *choice in choices) {
						District *district = [self findOrInsertDistrict:choice withParent:parent.government withError:error];
						if (district == nil) {
							return;
						}
						
						[registration addChoicesObject:district];
					}
				}
				
				[_context save:error];
			}
			[createdTime release];
		}
	}
}


- (District*)findOrInsertDistrict:(NSDictionary *)object withParent:(Government *)parent withError:(NSError **)error {
	NSDictionary *districtTypeObj = [object objectForKey:@"districtType"];

	DistrictType *districtType = [self findOrInsertDistrictType:districtTypeObj withError:error];
	if (*error == nil) {
		id idValue = [object objectForKey:@"id"];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"District" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (results != nil) {
			if ([results count] == 1) {
				return [results objectAtIndex:0];
			}
			
			NSString *name = [object objectForKey:@"name"];
			id shortName = [object objectForKey:@"shortName"];
			NSNumber *districtNum = [object objectForKey:@"districtNum"];
			NSNumber *year = [object objectForKey:@"year"];
			
			LogInfo(@"Inserting incoming District (type=%@, name=%@)", districtType.id, name);

			/* create and return District instance */
			District *district = [NSEntityDescription insertNewObjectForEntityForName:@"District" inManagedObjectContext:_context];
			district.id = [idValue isKindOfClass:[NSNumber class]] ? [idValue stringValue] : idValue;
			district.name = name;
			district.year = year;
			district.shortName = shortName == [NSNull null] ? nil : shortName;
			district.districtType = districtType;
			district.districtNum = districtNum;
			district.inGovernment = parent;
			
			if ([_context save:error]) {
				return district;
			}
		}
	}

	return nil;
}

- (DistrictType *)findOrInsertDistrictType:(NSDictionary *)object withError:(NSError **)error {
	NSString *idValue = [object objectForKey:@"id"];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictType" inManagedObjectContext:_context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
	[request setPredicate:predicate];
	
	NSArray *results = [_context executeFetchRequest:request error:error];
	[request release];
	
	if (results != nil) {
		if ([results count] == 1) {
			return [results objectAtIndex:0];
		}
		
		NSString *name = [object objectForKey:@"name"];
		NSNumber *displayOrder = [object objectForKey:@"displayOrder"];
		
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
	NSDictionary *governmentTypeObj = [object objectForKey:@"governmentType"];
	
	GovernmentType *governmentType = [self findOrInsertGovernmentType:governmentTypeObj withError:error];
	if (governmentType != nil) {
		id idValue = [object objectForKey:@"id"];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:1];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Government" inManagedObjectContext:_context];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
		[request setPredicate:predicate];
		
		NSArray *results = [_context executeFetchRequest:request error:error];
		[request release];
		
		if (results != nil) {
			if ([results count] == 1) {
				return [results objectAtIndex:0];
			}
			
			NSString *name = [object objectForKey:@"name"];
			id shortName = [object objectForKey:@"shortName"];
			
			/* create and return Government instance */
			Government *government = [NSEntityDescription insertNewObjectForEntityForName:@"Government" inManagedObjectContext:_context];
			government.id = [idValue isKindOfClass:[NSNumber class]] ? [idValue stringValue] : idValue;
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
	NSString *idValue = [object objectForKey:@"id"];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:1];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentType" inManagedObjectContext:_context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idValue];
	[request setPredicate:predicate];
	
	NSArray *results = [_context executeFetchRequest:request error:error];
	[request release];

	if (results != nil) {
		if ([results count] == 1) {
			return [results objectAtIndex:0];
		}
		
		NSString *name = [object objectForKey:@"name"];
		NSNumber *displayOrder = [object objectForKey:@"displayOrder"];
		
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

- (void)selectGovernment:(PotentialGovernmentRegistration *)potentialRegistration
			  withChoice:(Government *)choice
			withDelegate:(id)delegate {
	NSURL *url = [self createURL:@"/voter/v1/auth/selectGovernment"];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:[NSNumber numberWithDouble:[potentialRegistration.createdTime timeIntervalSince1970]*1000.0] forKey:@"createdTime"];
	[request setPostValue:potentialRegistration.registration.government.id forKey:@"government"];
	[request setPostValue:choice.id forKey:@"choice"];
	[request setDelegate:self];
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:potentialRegistration, @"potentialRegistration",
						choice, @"choice", delegate, @"delegate", nil];
	
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSURL *url = [request url];
	if ([@"/voter/v1/auth/selectGovernment" isEqual:[url path]]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss zzz";
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		df.locale = locale;
		
		id delegate = [request.userInfo objectForKey:@"delegate"];
		
		NSDate *date = nil;
		if ([request responseStatusCode] == 200) {
			/* OK */
			date = [df dateFromString:[[request responseHeaders] objectForKey:@"X-Created-Time"]];
			LogDebug(@"Server returned %d from request '%@': X-Created-Time = %@", 200, [url path], date);
		}
		else if ([request responseStatusCode] == 400) {
			/* BAD_REQUEST */
			LogError(@"Server returned %d from request '%@'", 400, [[request url] path]); 
			
			if (delegate != nil) {
				if ([delegate respondsToSelector:@selector(selectGovernmentFailed:status:)]) {
					[delegate performSelector:@selector(selectGovernmentFailed:status:) withObject:[NSNumber numberWithInt:STATUS_BAD_REQUEST]];
				}
			}
		}
		else {
			/* unexpected response */
			LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
			
			if (delegate != nil) {
				if ([delegate respondsToSelector:@selector(selectGovernmentFailed:status:)]) {
					[delegate performSelector:@selector(selectGovernmentFailed:status:) withObject:[NSNumber numberWithInt:STATUS_UNEXPECTED_RESPONSE]];
				}
			}
		}
		
		[df release];
		[locale release];
		
		PotentialGovernmentRegistration *potentialRegistration = [[request userInfo] objectForKey:@"potentialRegistration"];
		Government *choice = [[request userInfo] objectForKey:@"choice"];
		
		if (date != nil) {
			NSError *error = nil;
			[self resolveGovernmentRegistration:potentialRegistration
								 withGovernment:choice
								withCreatedTime:date
									  withError:&error];
			/* TODO: log error vote_status */
			if (delegate != nil) {
				if ([delegate respondsToSelector:@selector(selectGovernmentSuccess)]) {
					[delegate performSelector:@selector(selectGovernmentSuccess)];
				}
			}
		}
	}
	else if ([@"/voter/v1/auth/selectDistrict" isEqual:[url path]]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss zzz";
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		df.locale = locale;

		id delegate = [request.userInfo objectForKey:@"delegate"];
		
		NSDate *date = nil;
		NSError *error = [request error];
		if (error != nil) {
			LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
		}
		
		if ([request responseStatusCode] == 200) {
			/* OK */
			date = [df dateFromString:[[request responseHeaders] objectForKey:@"X-Created-Time"]];
			LogDebug(@"Server returned %d from request '%@': X-Created-Time = %@", 200, [url path], date);
		}
		else if ([request responseStatusCode] == 400) {
			/* BAD_REQUEST */
			LogError(@"Server returned %d from request '%@'", 400, [url path]); 
		}
		else {
			/* unexpected response */
			LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
		}
		
		[df release];
		[locale release];
		
		PotentialDistrictRegistration *potentialRegistration = [[request userInfo] objectForKey:@"potentialRegistration"];
		District *choice = [[request userInfo] objectForKey:@"choice"];
		
		if (date != nil) {
			NSError *error = nil;
			[self resolveDistrictRegistration:potentialRegistration
								 withDistrict:choice
							  withCreatedTime:date withError:&error];
			/* TODO: log error */
			if (delegate != nil) {
				if ([delegate respondsToSelector:@selector(selectDistrictSuccess)]) {
					[delegate performSelector:@selector(selectDistrictSuccess)];
				}
			}
		}
	}
	else {
		LogError(@"Cannot handle unexpected response: %@", [url path]);
	}

}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSURL *url = [request url];
	
	LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	
	id delegate = [request.userInfo objectForKey:@"delegate"];
	if (delegate != nil) {
		if ([@"/voter/v1/auth/selectGovernment" isEqual:[url path]]) {
			if ([delegate respondsToSelector:@selector(selectGovernmentFailed:)]) {
				[delegate performSelector:@selector(selectGovernmentFailed:) withObject:[NSNumber numberWithInt:STATUS_HTTP_ERROR]];
			}
		}
		else if ([@"/voter/v1/auth/selectDistrict" isEqual:[url path]]) {
			if ([delegate respondsToSelector:@selector(selectDistrictFailed:)]) {
				[delegate performSelector:@selector(selectDistrictFailed:) withObject:[NSNumber numberWithInt:STATUS_HTTP_ERROR]];
			}
		}
		else {
			LogError(@"Cannot handle unexpected response: %@", [url path]);
		}

	}
}

- (void)selectDistrict:(PotentialDistrictRegistration *)potentialDistrict
			withChoice:(District *)choice
		  withDelegate:(id)delegate{
	NSURL *url = [self createURL:@"/voter/v1/auth/selectDistrict"];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	//			NSDate *createdTime = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];

	[request setPostValue:[NSNumber numberWithDouble:[potentialDistrict.createdTime timeIntervalSince1970]*1000.0] forKey:@"createdTime"];
	[request setPostValue:potentialDistrict.registration.government.id forKey:@"government"];
	[request setPostValue:choice.id forKey:@"district"];
	[request setDelegate:self];
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:potentialDistrict, @"potentialRegistration",
						choice, @"choice", delegate, @"delegate", nil];
	
	[request startAsynchronous];
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	LogInfo(@"Received a response: %@", response);
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//	LogInfo(@"Error: %@", [error userInfo]);
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
//	LogInfo(@"Done loading, the data is: %@", responseString);
//	[responseString release];
//	
//	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate switchToMainApp];
//}

- (vote_status)sendFacebookAccessToken:(NSString *)accessToken {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/accessToken"];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:@"fb" forKey:@"socialnet"];
	[request setPostValue:accessToken forKey:@"access_token"];

	[request startSynchronous];
	
	vote_status status = OK;
	NSError *error = [request error];
	if (error != nil) {
		status = HTTP_ERROR;
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
		LogDebug(@"Server returned %d from request '%@'", 200, [url path]);
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		LogError(@"Server returned %d from request '%@'", 500, [url path]); 
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
	}
	
	return status;
}

- (vote_status)sendBallotVote:(BallotVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/voteCandidate"];
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
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
		LogDebug(@"Server returned %d from request '%@'", 200, [url path]);
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		LogError(@"Server returned %d from request '%@'", 500, [url path]); 
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		status = BAD_REQUEST;
		LogError(@"Server returned %d from request '%@'", 400, [url path]); 
	}
	else if ([request responseStatusCode] == 403) {
		/* FORBIDDEN */
		status = ELECTION_CLOSED;
		LogError(@"Server returned %d from request '%@'", 403, [url path]); 
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
	}
	
	return status;
}

- (vote_status)sendMeasureVote:(MeasureVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/voteMeasure"];
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
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
		LogDebug(@"Server returned %d from request '%@'", 200, [url path]); 
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		LogError(@"Server returned %d from request '%@'", 500, [url path]); 
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		status = BAD_REQUEST;
		LogError(@"Server returned %d from request '%@'", 400, [url path]); 
	}
	else if ([request responseStatusCode] == 403) {
		/* FORBIDDEN */
		status = ELECTION_CLOSED;
		LogError(@"Server returned %d from request '%@'", 403, [url path]); 
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
	}
	
	return status;
}

- (vote_status)handleSyncRequest:(ASIHTTPRequest *)request {
	[request startSynchronous];
	
	vote_status status = OK;
	NSError *error = [request error];
	if (error != nil) {
		status = HTTP_ERROR;
		LogError(@"Network error during request '%@': %@", [request.url path], [error localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		status = OK;
		LogDebug(@"Server returned %d from request '%@'", 200, [request.url path]); 
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		status = SERVER_ERROR;
		LogError(@"Server returned %d from request '%@'", 500, [request.url path]); 
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		status = BAD_REQUEST;
		LogError(@"Server returned %d from request '%@'", 400, [request.url path]); 
	}
	else {
		/* unexpected response */
		status = UNEXPECTED_RESPONSE;
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [request.url path]);
	}
	
	return status;
}

- (vote_status)deleteBallotVote:(BallotVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/deleteVote"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forPosition.guid forKey:@"position"];

	return [self handleSyncRequest:request];
}

- (vote_status)deleteMeasureVote:(MeasureVote *)vote {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/deleteVote"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request setPostValue:vote.forMeasure.guid forKey:@"measure"];
	[request startSynchronous];

	return [self handleSyncRequest:request];
}

- (NSArray *)getVotesForBallot:(NSString *)electionGuid{
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:[NSString stringWithFormat:@"/voter/v1/auth/votes?election=%@", electionGuid]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	[request startSynchronous];
	
	NSError *error = [request error];
	if (error != nil) {
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *votes = [parser objectWithString:json error:&error];	
		
		if (error != nil) {
			LogError(@"Error parsing JSON '%@': %@", json, [error localizedDescription]);
			[json release];
		}
		else {
			[json release];
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
	NSArray *array = [_context executeFetchRequest:request error:&error];
	[request release];
	
	if (array == nil) {
		LogError(@"Fetch error while querying for existing position vote: %@", [error localizedDescription]);
	}
	else if ([array count] == 1) {
		return (FriendBallotVote *) [array objectAtIndex:0];
	}
	
	return nil;
}

- (FriendMeasureVote *)getVoteForMeasure:(Measure *)measure byAuthor:(Friend *)friend {
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
		LogError(@"Fetch error while querying for existing measure vote: %@", [error localizedDescription]);
	}
	else if ([array count] == 1) {
		return (FriendMeasureVote *) [array objectAtIndex:0];
	}
	
	return nil;
}

- (BOOL)insertVotes:(NSArray *)votes {
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
			
			if (candidate == nil) {
				LogWarn(@"Unrecognized candidate (%@), so not storing vote", candidateGuid);
			}
			else if (![viewable boolValue])
			{
				if (position != nil && friend != nil) {
					/* check if the friend ballot vote already exists */
					FriendBallotVote *existingVote = [self getVoteForPosition:position byAuthor:friend];
					if (existingVote != nil) {
						LogInfo(@"Found existing FriendBallotVote, but incoming vote is not viewable, so delete");
						
						[_context deleteObject:existingVote];
						NSError *err = nil;
						if (![_context save:&err]) {
							LogError(@"Error while saving context: %@", [err localizedDescription]);
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
						LogInfo(@"Found existing FriendBallotVote, updating certain attributes");
						
						NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
						
						existingVote.forCandidate = candidate;
						existingVote.statement = statement;
						existingVote.date = date;
						
						NSError *err = nil;
						if (![_context save:&err]) {
							LogError(@"Error while saving context: %@", [err localizedDescription]);
						}
						[date release];
					}
					else {
						/* insert new friend ballot vote */
						LogInfo(@"Inserting new friend ballot vote");
						
						NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
						
						FriendBallotVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendBallotVote" inManagedObjectContext:_context];
						voteObj.forCandidate = candidate;
						voteObj.forPosition = position;
						voteObj.author = friend;
						voteObj.date = date;
						voteObj.statement = statement;
						
						NSError *err = nil;
						if (![_context save:&err]) {
							LogError(@"Error while saving context: %@", [err localizedDescription]);
						}
						[date release];
					}
				}
			}
			else {
				LogWarn(@"Some value was nil..");
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
						LogInfo(@"Found existing FriendMeasureVote, but incoming vote is not viewable, so delete");
						
						[_context deleteObject:existingVote];
						NSError *err = nil;
						if (![_context save:&err]) {
							LogError(@"Error while saving context: %@", [err localizedDescription]);
						}
					}
				}
			}
			else if (measure != nil && friend != nil) {
				/* check if the friend measure vote already exists */
				FriendMeasureVote *existingVote = [self getVoteForMeasure:measure byAuthor:friend];

				if (existingVote != nil) {
					/* existing friend measure vote, so update */
					LogInfo(@"Found existing FriendMeasureVote, updating certain attributes");
					
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
					
					existingVote.vote = voteValue;
					existingVote.statement = statement;
					existingVote.date = date;
					
					NSError *err = nil;
					if (![_context save:&err]) {
						LogError(@"Error while saving context: %@", [err localizedDescription]);
					}
					[date release];
				}
				else {
					/* insert new friend measure vote */
					LogInfo(@"Inserting new friend measure vote");
					
					NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateValue doubleValue]/1000.0];
					
					FriendMeasureVote *voteObj = [NSEntityDescription insertNewObjectForEntityForName:@"FriendMeasureVote" inManagedObjectContext:_context];
					voteObj.forMeasure = measure;
					voteObj.vote = voteValue;
					voteObj.author = friend;
					voteObj.statement = statement;
					voteObj.date = date;
					
					NSError *err = nil;
					if (![_context save:&err]) {
						LogError(@"Error while saving context: %@", [err localizedDescription]);
					}
					[date release];
				}
			}
			else {
				LogWarn(@"Some value was nil..");
			}
		}
		else {
			LogError(@"Unexpected type: %@", type);
		}
	}
	
	return YES;
}

- (id)getObject:(NSString *)entityName byGuid:(NSString *)guid {
	if (guid == nil) {
		return nil;
	}
	
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
		LogWarn(@"Found multiple objects (%@) with the same guid (%@), returning first object", entityName, guid);
	}
	
	return [array objectAtIndex:0];
}


- (id)getFriends {
	/* TODO: this should be asynchronous */
	NSURL *url = [self createURL:@"/voter/v1/auth/friends"];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	
	NSError *error = [request error];
	if (error != nil) {
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *friends = [parser objectWithString:json error:&error];	
		
		if (error != nil) {
			LogError(@"Error parsing JSON '%@': %@", json, [error localizedDescription]);
		}
		[json release];
		
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
			LogInfo(@"Found existing Friend, updating certain attributes");
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
			
			if (array == nil) {
				LogError(@"Fetch error while querying for FacebookFriend: %@", [err localizedDescription]);
			}
			else if ([array count] == 1) {
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
	NSURL *url = [self createURL:@"/voter/v1/auth/elections"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];	
	[request startSynchronous];
	NSError *error = [request error];
	if (error != nil) {
		*status = HTTP_ERROR;
		LogError(@"Network error during request '%@': %@", [url path], [error localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		/* OK */
		*status = OK;
		
		/* TODO: review this code */
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		LogDebug(@"Server returned %d from request '%@': %@", 200, [url path], json); 
		
		NSDictionary *elections = [parser objectWithString:json error:&error];
		
		if (error != nil) {
			LogError(@"Error parsing JSON '%@': %@", json, [error localizedDescription]);
		}
		[json release];
		
		return elections;
	}
	else if ([request responseStatusCode] == 500) {
		/* INTERNAL_SERVER_ERROR */
		*status = SERVER_ERROR;
		LogError(@"Server returned %d from request '%@'", 500, [url path]); 
	}
	else if ([request responseStatusCode] == 400) {
		/* BAD_REQUEST */
		*status = BAD_REQUEST;
		LogError(@"Server returned %d from request '%@'", 400, [url path]); 
	}
	else {
		/* unexpected response */
		*status = UNEXPECTED_RESPONSE;
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
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
	NSURL *url = [self createURL:[NSString stringWithFormat:@"/voter/v1/auth/election?election=%@", guid]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:kDeviceIDHeaderKey value:deviceID];
	if (time != nil) {
		[request addRequestHeader:@"If-Modified-Since" value:[df stringFromDate:time]];
	}
	
	[request startSynchronous];
	
//	NSDictionary *election = nil;
	*httpError = [request error];
		
	election_status status;
	if (*httpError != nil) {
		LogError(@"Network error during request '%@': %@", [url path], [*httpError localizedDescription]);
	}
	else if ([request responseStatusCode] == 200) {
		NSString *json = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		LogDebug(@"Server returned %d from request '%@': %@", 200, [url path], json);

		NSError *parseError = nil;
		*election = [parser objectWithString:json error:&parseError];	
		
		if (parseError != nil) {
			LogError(@"Error parsing JSON '%@': %@", json, [parseError localizedDescription]);
		}
		[json release];
		
		NSString *newLastModified = [[request responseHeaders] objectForKey:@"Last-Modified"];
		*newTime = [df dateFromString:newLastModified];
		status = ES_OK;
	}
	else if ([request responseStatusCode] == 404) {
		/* NOT_FOUND */
		status = ES_NOT_FOUND;
		LogError(@"Server returned %d from request '%@'", 404, [url path]); 
	}
	else if ([request responseStatusCode] == 410) {
		/* GONE */
		status = ES_CLOSED;
		LogError(@"Server returned %d from request '%@'", 410, [url path]); 
	}
	else if ([request responseStatusCode] == 304) {
		/* NOT_MODIFIED */
		status = ES_NOT_MODIFIED;
		LogError(@"Server returned %d from request '%@'", 304, [url path]); 
	}
	else {
		/* unexpected response */
		LogError(@"Server returned unexpected response %d from request '%@'", [request responseStatusCode], [url path]);
	}

	
	[df release];
	[locale release];
	
	return status;
}

- (BOOL)insertElection:(NSDictionary *)election withLastModified:(NSDate *)time withError:(NSError **)error {
	NSString *guid = [election objectForKey:@"guid"];
	NSString *title = [election objectForKey:@"title"];
	id icon = [election objectForKey:@"icon"];
	NSString *dateValue = [election objectForKey:@"date"];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateFormat = @"yyyy-MM-dd";
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	df.locale = locale;
	
	NSDate *date = [df dateFromString:dateValue];	
	[df release];
	[locale release];
	
	Election *electionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:_context];
	electionObj.status = [NSNumber numberWithBool:YES];
	electionObj.guid = guid;
	electionObj.title = title;
	electionObj.icon = icon == [NSNull null] ? nil : icon;
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
						
			Position *positionObj = [self getObject:@"Position" byGuid:positionGuid];
			if (positionObj == nil) {
				LogInfo(@"Adding new position '%@' to election '%@'", positionGuid, electionGuid);
				
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
												
						Candidate *candidateObj = [self getObject:@"Candidate" byGuid:candidateGuid];
						if (candidateObj == nil) {
							LogInfo(@"Adding new candidate '%@' to position '%@'", candidateGuid, positionGuid);
							
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
							LogWarn(@"Candidate doesn't belong in position");
						}

					}
				}
			}
			else {
				LogWarn(@"Position doesn't belong in election");
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
						
			Measure *measureObj = [self getObject:@"Measure" byGuid:measureGuid];

			if (measureObj == nil) {
				LogInfo(@"Adding new measure '%@' to election '%@'", measureGuid, electionGuid);
				
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
				LogWarn(@"Measure doesn't belong in election");
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
