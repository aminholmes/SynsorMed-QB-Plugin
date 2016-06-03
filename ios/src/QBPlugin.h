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
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Protocols.h"
@class CallViewController;


@protocol WeemoControlDelegate <NSObject>

- (void)WCD:(CDVPlugin *)wdController AddController:(UIViewController *) cvc;
- (void)WCD:(CDVPlugin *)wdController RemoveController:(UIViewController *) cvc;

@end

//@interface WeemoPlugin : CDVPlugin <RtccDelegate, RtccCallDelegate, RtccAttendeeDelegate, HomeDelegate>
@interface WeemoPlugin : CDVPlugin <HomeDelegate>
{
    CallViewController *cvc_active;
    NSString *cb_connect;
    NSString *cb_authent;
    NSString *cb_call;
    NSString *cb_disconnect;
    NSString *cb_canCall;
    NSString *cb_canComeBack;
    BOOL canComeBack;
    CGRect displayFrame;
}

//To hold the network info value
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

//@property (nonatomic) CallViewController *cvc_active;
@property (nonatomic, weak) id <WeemoControlDelegate> WDelegate;
/**
 * Connects the WeemoSDK to the cloud.
 * \param command the actual arguments are in command::arguments .
 *	arguments[0] appID: string The appID to be used to connect the SDK
 */
- (void)initialize:(CDVInvokedUrlCommand *)command;

/**
 * Authenticate a contactID.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] token:string The token used for this user
 * arguments[1] contactType:int The type of contact this user is
 */
- (void)authent:(CDVInvokedUrlCommand *)command;


/**
 * Set the name used for the contact.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] displayName: string The displayName set by the user
 */
- (void)setDisplayName:(CDVInvokedUrlCommand *)command;

/**
 * Get the remote contact status.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] contactID: string The contact ID we want the status of
 */
- (void)getStatus:(CDVInvokedUrlCommand *)command;

/**
 * Call a contact.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] the contactID whom the user whishes to call
 */
- (void)createCall:(CDVInvokedUrlCommand *)command;

/**
 * Disconnects the WeemoSDK
 */
- (void)disconnect:(CDVInvokedUrlCommand *)command;

/**
 * Mutes the call.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] callID:int The ID of the related call
 * arguments[1] muteStatus:int If 1, the mute mode is lifted, enforced otherwise
 */
- (void)muteOut:(CDVInvokedUrlCommand *)command;

/**
 * Start/resume the call
 * \param command the actual arguments are in command::arguments .
 * arguments[0] callID:int The ID of the related call
 */
- (void)resume:(CDVInvokedUrlCommand *)command;

/**
 * Hangup a call
 * \param command the actual arguments are in command::arguments .
 * arguments[0] callID:int The ID of the related call
 */
- (void)hangup:(CDVInvokedUrlCommand *)command;

/**
 * Display the callView over the webView. If the second argument is equals to 0, closing this call view
 * hangs up the call.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] callID:int The ID of the related call
 * arguments[1] canComeBack:int If 0, dismissing the callWindow while hangup the call.
 */
- (void)displayCallWindow:(CDVInvokedUrlCommand *)command;

/**
 * Display the callView over the webView. If the second argument is equals to 0, closing this call view
 * hangs up the call.
 * \param command the actual arguments are in command::arguments .
 * arguments[0] callID:int The ID of the related call
 * arguments[1] canComeBack:int If 0, dismissing the callWindow while hangup the call.
 */
- (void)displayCallView:(CDVInvokedUrlCommand *)command;


/**
 * Change the incoming audio route
 */
- (void)setAudioRoute:(CDVInvokedUrlCommand *)command;

+(BOOL)isProvider;
+(BOOL)isDataAvailable;

@end
