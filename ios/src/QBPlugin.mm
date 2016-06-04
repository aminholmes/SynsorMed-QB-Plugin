//
//  WeemoPlugin.m
//  WeemoPhonegap
//
//  Created by Charles Thierry on 10/31/13.
//
//

#import "QBPlugin.h"
//#import "CallViewController.h"
//#import "RtccDelegate.h"

//#define KEY_MOBILEAPPID	@"appid"
//#define KEY_CALLCONTACT @"callContact"

static BOOL isProvider=false;
static BOOL isDataAvailable=false;

@implementation QBPlugin{
    

}

- (void) initQB:(CDVInvokedUrlCommand *)command
{
	
	NSLog(@"I am going to initQB");
	
	[QBSettings setApplicationID:41633];
	
	[QBSettings setAuthKey:@"YKQGUMXRvwtK9kf"];
	
	[QBSettings setAuthSecret:@"ND-eQkQxAYAUYpM"];
	
	[QBSettings setAccountKey:@"Ky2eW7fR2tqfoDzxgZB1"];
	
	[QBRTCClient initializeRTC];
	
	[[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"]
								 callbackId:command.callbackId];
	
}

- (void) authent:(CDVInvokedUrlCommand *)command
{
	NSString *loginID;
	
	cb_authent = command.callbackId;
	
	loginID = [command argumentAtIndex:0] != nil ? [command argumentAtIndex:0] : nil;
	
	NSLog(@"I am going to authenticate in QB with %@", loginID);
	
	//Try to login with user. If failed, register user and try again
	
	[self loginQBUser:loginID];
	
}

- (void) loginQBUser:(NSString *) loginID
{
	
	[QBRequest logInWithUserLogin:loginID password:[loginID stringByAppendingString:@"password"] successBlock:^(QBResponse *response, QBUUser *user) {
		
		NSLog(@"The user was found and successfully Logged in");
		
		//Now that user logged into QB, try QBChat
		
		user.password = [user.login stringByAppendingString:@"password"];
		
		[[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
			NSLog(@"Error: %@", error);
		}];
		
		[[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"]
									 callbackId:cb_authent];
		
	} errorBlock:^(QBResponse *response) {
		// error handling
		NSLog(@"The user was NOT found and cannot Log in");
		
		//Try registering user since login failed
		
		[self registerQBUser:loginID];
		
		NSLog(@"error: %@", response.error.reasons);
		
	}];
	
}

- (void) registerQBUser:(NSString *) username
{
	
	
	QBUUser *user = [QBUUser user];
	user.login = username;
	user.password = [username stringByAppendingString:@"password"]	;
	
	[QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {

		NSLog(@"I successfully signed up a new user: %@", user.login);
		//Try Logging in again
		[self loginQBUser:username];
		
		
	} errorBlock:^(QBResponse *response) {
		// error handling
		NSLog(@" I couldn't sign up new user, error: %@", response.error);
		
		[[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Auth Failure"]
									 callbackId:cb_authent];
		
	}];
	
	
}


@end
