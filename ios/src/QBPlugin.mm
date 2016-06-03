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
	
	[[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"]
								 callbackId:command.callbackId];
	
}


@end
