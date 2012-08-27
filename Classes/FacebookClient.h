//
//  FacebookClient.h
//  Supervote
//
//  Created by augusto callejas on 11/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

@interface FacebookClient : NSObject {

@private
	NSManagedObjectContext* _context;
	NSString* _documentsPath;
}

+ (BOOL)handleOpenURL:(NSURL *)url;
- (id)initWithContext:(NSManagedObjectContext *)context andDocumentsPath:(NSString *)path;
- (BOOL)isLoggedIn;
- (NSString *)getAccessToken;
- (void)updateFriends;
- (void)downloadFacebookPhoto:(NSString *)facebookId;
- (void)saveFacebookPhoto:(NSData *)data forFriend:(NSString *)friendId;
- (void)authorize:(id)delegate;
- (void)logout;

@end
