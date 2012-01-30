//
//  FacebookClient.h
//  Supervote
//
//  Created by augusto callejas on 11/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//


@interface FacebookClient : NSObject <FBSessionDelegate, FBRequestDelegate> {

@private
	NSManagedObjectContext* _context;
	Facebook* _facebook;
	NSString* _documentsPath;
	BOOL _loggedIn;
	id<FBSessionDelegate> _delegate;
}

@property (readonly) Facebook* facebook;
@property (readonly) BOOL loggedIn;
@property (nonatomic, retain) id<FBSessionDelegate> delegate;

- (id)initWithContext:(NSManagedObjectContext *)context andDocumentsPath:(NSString *)path;
- (void)updateFriends;
- (void)authorize;
- (void)logout;

@end
