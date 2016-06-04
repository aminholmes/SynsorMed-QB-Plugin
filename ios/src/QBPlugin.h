//
//  WeemoPlugin.h
//  WeemoPhonegap
//
//  Created by Charles Thierry on 10/31/13.
//
//

/**
 * This class is the interface between the Javascript and the WeemoSDK and does nothing more than controlling said driver and most of the CallView (the UIView displayed on top of the WebView of this app).
 */

#import <Cordova/CDVPlugin.h>

@class CallViewController;


@protocol WeemoControlDelegate <NSObject>

- (void)WCD:(CDVPlugin *)wdController AddController:(UIViewController *) cvc;
- (void)WCD:(CDVPlugin *)wdController RemoveController:(UIViewController *) cvc;

@end

//@interface WeemoPlugin : CDVPlugin <RtccDelegate, RtccCallDelegate, RtccAttendeeDelegate, HomeDelegate>
@interface QBPlugin : CDVPlugin
{
	
	NSString *cb_authent;
	

}
- (void)registerQBUser:(NSString *) username;


@end
