//
//  WeemoPlugin.m
//  WeemoPhonegap
//
//  Created by Charles Thierry on 10/31/13.
//
//

#import "WeemoPlugin.h"
#import "CallViewController.h"
#import "RtccDelegate.h"

#define KEY_MOBILEAPPID	@"appid"
#define KEY_CALLCONTACT @"callContact"

static BOOL isProvider=false;
static BOOL isDataAvailable=false;

@implementation WeemoPlugin{
    
    //NSString *cb_connect;
    //NSString *authCommandID;
    //NSString *callCommandID;
}



#pragma mark - JS -> ObjectiveC
- (void)initialize:(CDVInvokedUrlCommand *)command
{
    cb_connect = [NSString stringWithString:command.callbackId];
    [[RtccDelegate instance] setHomeDelegate:self];
    
    NSLog(@">>> Initializing");
    NSLog(@">>>Beginning status of singleton: %ld",(long)[[Rtcc instance] currentStatus]);
    if ([Rtcc instance] == nil)
    {
        NSLog(@"The RTCC instance is nil");
    }
    //Had to get the Rttc instance specifically due to conflicting status methods
    RtccDelegate *myRtccD = [RtccDelegate instance];
    
    if ([myRtccD status] == sta_notConnected)
    {
        /*NSDictionary *param = @{KEY_USERID:		[[self tf_UID] text],
         KEY_DISPLA:		[[[self tf_displayname] text] isEqualToString:@""]?[[self tf_UID] text]:[[self tf_displayname] text]
         };*/
        NSDictionary *param = @{
                                KEY_MOBILEAPPID: [command argumentAtIndex:0]
                                };
        
        //[Rtcc RtccWithAppID:[command argumentAtIndex:0] andDelegate:self error:nil];
        [[RtccDelegate instance] rtccConnect:param];
    } else if ([myRtccD status] == sta_authenticated)
    {
        NSLog(@">>> Pressing disconnect");
        [[RtccDelegate instance] rtccDisconnect];
    }
    
    NSLog(@">>>>The RTCC Version is: %@", [[RtccDelegate instance] RTCCVersion]);
}

- (void)getNetworkType:(CDVInvokedUrlCommand *)command
{
	NSLog(@"About to try to get network type in plugin");
	NSString *networkType;
	self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
	NSLog(@"Initial cell connection: %@", self.networkInfo.currentRadioAccessTechnology);
	
	//Create listener for change in radio type
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioAccessChanged) name:CTRadioAccessTechnologyDidChangeNotification object:nil];
	
	if([self.networkInfo.currentRadioAccessTechnology  isEqual:@"CTRadioAccessTechnologyLTE"]){
		networkType = @"LTE";
	}else{
		networkType = @"OTHER";
	}
	
	[[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:networkType]
								 callbackId:command.callbackId];
	
}

- (void)radioAccessChanged {
	NSLog(@"Now you're connected via %@", self.networkInfo.currentRadioAccessTechnology);
}


- (void)getEngineStatus: (CDVInvokedUrlCommand *)command
{
    
}

+(BOOL)isProvider
{
    return isProvider;
}

+(BOOL)isDataAvailable
{
    return isDataAvailable;
}


- (void)authent:(CDVInvokedUrlCommand *)command
{
    NSLog(@"About to try to auntenticate in plugin");
    cb_authent = [NSString stringWithString:command.callbackId];
    
    [[RtccDelegate instance] rtccAuth:[command argumentAtIndex:0] type:[[command argumentAtIndex:1] intValue]];
    
    
}


- (void)setDisplayName:(CDVInvokedUrlCommand *)command
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        [[Rtcc instance] setDisplayName:[command argumentAtIndex:0]];
    });
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:command.callbackId];
}

- (void)getStatus:(CDVInvokedUrlCommand *)command
{
	NSLog(@">>>> Inside the GetStatus Method");
    cb_canCall = [NSString stringWithString:command.callbackId];
    NSArray* contacts = [NSArray arrayWithObject:[command argumentAtIndex:0]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
		NSLog(@">>>> About to getPresence for contacts: %@", contacts);
        //[[Rtcc instance] getPresenceForContacts:contacts];
		[[RtccDelegate instance] getPresence:contacts];
	
    });
    
}

- (void)createCall:(CDVInvokedUrlCommand *)command
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        NSLog(@"The caller id is: %@", [command argumentAtIndex:0]);
        if([command argumentAtIndex:1]!=nil)
        {
            isProvider=[[command argumentAtIndex:1] boolValue];
            //TODO
            NSLog(@"isProvider ---> %d",isProvider);
        }
        else
        {
            NSLog(@"isProvider ---> %@", @"null value is coming");
        }
        if([command argumentAtIndex:2]!=nil)
        {
            isDataAvailable=[[command argumentAtIndex:2] boolValue];
            //TODO
            NSLog(@"isDataAvailable ---> %d",isDataAvailable);
        }
        else
        {
            NSLog(@"isDataAvailable ---> %@", @"nil value is coming");
        }
        
        
        if([Rtcc instance].isConnected){
            NSLog(@"Instance is connected before calling");
        }
        if([Rtcc instance].isAuthenticated){
            NSLog(@"Instance is authenticated before calling");
        }
        NSDictionary *param = @{
                                KEY_CALLCONTACT: [command argumentAtIndex:0],
                                @"video": @YES
                                };
        [[RtccDelegate instance]call:param];
        //[[Rtcc instance] createCall:[command argumentAtIndex:0] andSetDisplayName:@"Patient"];
    });
}

- (void)disconnect:(CDVInvokedUrlCommand *)command
{
    cb_disconnect = [NSString stringWithString:command.callbackId];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
    [[RtccDelegate instance] rtccDisconnect];
    //});
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:command.callbackId];
}

- (void)muteOut:(CDVInvokedUrlCommand *)command
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        [[[Rtcc instance] activeCall]audioStop];
    });
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand *)command
{/*
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
		[[[Rtcc instance]activeCall]resume];
  });
  */
    if([command argumentAtIndex:1]!=nil)
    {
        isProvider=[[command argumentAtIndex:1] boolValue];
        //TODO
        NSLog(@"isProvider in On resume ---> %d",isProvider);
    }
    else
    {
        NSLog(@"isProvider in On resume ---> %@", @"null value is coming");
    }
    //[self displayCallWindow:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        [[[RtccDelegate instance]activeCall]resume];
    });
    //[[[RtccDelegate instance] activeCall] resume];
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:command.callbackId];
}

- (void)hangup:(CDVInvokedUrlCommand *)command
{
    //	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
    //		[[[RtccDelegate instance]activeCall]hangup];
    //	});
    [self removeCallView:nil];
    [[[RtccDelegate instance] activeCall] hangup];
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:command.callbackId];
}
/*
 - (void)displayCallWindow:(CDVInvokedUrlCommand *)command
 {
	cb_canComeBack = [NSString stringWithString:command.callbackId];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
 
 canComeBack = [[command argumentAtIndex:1] intValue] == 0 ? NO:YES;
 displayFrame = CGRectMake(0., 0.,
 [[[[[[UIApplication sharedApplication] delegate]window]rootViewController] view]bounds].size.width,
 [[[[[[UIApplication sharedApplication] delegate]window]rootViewController] view]bounds].size.height);
 //[self addCallView:view_fullscreen];
 [self addCallView];
 [[[Rtcc instance] activeCall] videoStart];
 NSLog(@"%s setCanComeBack %@ (%d %@)",__FUNCTION__, [[command argumentAtIndex:1]intValue]==0?@"NO":@"YES", [[command argumentAtIndex:1]intValue], cvc_active );
 
	});
	
 }
 */

- (void)displayCallView:(CDVInvokedUrlCommand *)command
{
    /*Empty: We aren't using */
}

- (void)displayCallWindow:(CDVInvokedUrlCommand *)command
{
    if (cvc_active)
    {
        NSLog(@"CVC Already exists");
        return;
    }
    UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    
    BOOL isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    NSString *storyboardname = isPad?@"ipad":@"iphone";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyboardname bundle:[NSBundle mainBundle]];
    cvc_active = [storyBoard instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    [rootController addChildViewController:cvc_active];
    [rootView addSubview:[cvc_active view]];
    [[cvc_active view] setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleLeftMargin];
    [[RtccDelegate instance] setCallDelegate:cvc_active];
    
    if (command != nil) {
        
        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                     callbackId:command.callbackId];
    }
    
    
}

- (void)removeCallView:(void(^)())completionBlock
{
    if (!cvc_active) return;
    [cvc_active removeFromParentViewController];
    [[cvc_active view] removeFromSuperview];
    /*
     [[self inPointer] removeFromSuperview];
     [[self inPointer] setHidden:YES];
     */
    //completionBlock();
    [[RtccDelegate instance] setCallDelegate:nil];
    //setCvc_active:nil;
    cvc_active = nil;
    
}


- (void)setAudioRoute:(CDVInvokedUrlCommand *)command
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        [[[Rtcc instance] activeCall]setAudioRoute:route_headsetOrLoudspeaker];
        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)[[[Rtcc instance] activeCall]audioRoute]]
                                     callbackId:command.callbackId];
    });
}


#pragma mark -
/*
 - (void)addCallView:(viewType_t)viewType
 {
	NSLog(@">>>> %s", __FUNCTION__);
	if (cvc_active)
	{
 return;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
 cvc_active = [[CallViewController alloc]initWithNibName:@"CallViewController" bundle:[NSBundle mainBundle]];
 [cvc_active setCwDelegate:self];
 [[[[[UIApplication sharedApplication] delegate]window]rootViewController]addChildViewController:cvc_active];
 
 [cvc_active setCanComeBack:canComeBack];
 [cvc_active setViewType:viewType];
 
 [[cvc_active view] setFrame:displayFrame];
 if ([[[cvc_active view] superview] isEqual:[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view]] )
 {
 return;
 }
 
 [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] addSubview:[cvc_active view]];
	});
 }
 */

- (void)addCallView
{
    NSLog(@">>>> %s", __FUNCTION__);
    
    UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    
    NSLog(@"The Root Controller name: %@", rootController.description);
    NSLog(@"The Root View name: %@", rootView.description);
    
    if (cvc_active)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //[[self view] endEditing:YES];
        BOOL isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        NSString *storyboardname = isPad?@"ipad":@"iphone";
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyboardname bundle:[NSBundle mainBundle]];
        cvc_active = [storyBoard instantiateViewControllerWithIdentifier:@"CallViewController"];
        
        //[self addChildViewController:[self cvc_active]];
        //[[self view] addSubview:[[self cvc_active] view]];
        /*[[[self cvc_active] view] setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin |
         UIViewAutoresizingFlexibleRightMargin |
         UIViewAutoresizingFlexibleTopMargin |
         UIViewAutoresizingFlexibleLeftMargin];
         */
        
        
        
        //cvc_weemo = [[weemoCallViewController alloc]initWithNibName:@"weemoCallViewController" bundle:[NSBundle mainBundle]];
        //[cvc_weemo setCwDelegate:self];
        [[[[[UIApplication sharedApplication] delegate]window]rootViewController]addChildViewController:cvc_active];
        
        //[cvc_active setCanComeBack:canComeBack];
        //[cvc_active setViewType:viewType];
        //[[cvc_active view] setFrame:displayFrame];
        
        if ([[[cvc_active view] superview] isEqual:[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view]] )
        {
            NSLog(@"The superview of cvcactive is the root");
            return;
        }
        
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] addSubview:[cvc_active view]];
        /*[[cvc_active view] setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin |
         UIViewAutoresizingFlexibleRightMargin |
         UIViewAutoresizingFlexibleTopMargin |
         UIViewAutoresizingFlexibleLeftMargin];
         */
        [[RtccDelegate instance] setCallDelegate:cvc_active];
    });
}


/*
 - (void)removeCallView
 {
	dispatch_async(dispatch_get_main_queue(), ^{
 [[cvc_active view]removeFromSuperview];
 [cvc_active removeFromParentViewController];
 //		[[[[[UIApplication sharedApplication] delegate]window]rootViewController]dismissModalViewControllerAnimated:NO];
 //[cvc_active setCwDelegate:nil];
 cvc_active = nil;
	});
 }
 */

#pragma mark - Rtcc Delegation

- (void)rtccDidConnect:(NSError *)error
{
    if (cb_connect)
    {
        if (error)
        {
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                         messageAsInt:(int)[error code]]
                                         callbackId:cb_connect];
        } else {
            NSLog(@"RTCC connected without error");
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                         callbackId:cb_connect];
        }
    }
    cb_connect = nil;
    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.connectionChanged(%d);", (int)[error code]] scheduledOnRunLoop:YES];
}

- (void)rtccDidAuthenticate:(NSError *)error
{
    if (error)
    {
        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                     messageAsInt:(int)[error code]]
                                     callbackId:cb_authent];
    } else {
        NSLog(@"RTCC authenticated without error");
        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                  messageAsString:@"OK"]
                                     callbackId:cb_authent];
    }
    cb_authent = nil;
}

- (void)rtccCallCreated:(RtccCall *)call
{
    NSLog(@">>>> %s", __FUNCTION__);
    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callCreated(%d, \"%s\");", [call callid],
                                   [[call contactUID] UTF8String]] scheduledOnRunLoop:YES];
    [call setDelegate:[RtccDelegate instance]];
    dispatch_async(dispatch_get_main_queue(), ^{
        //		[self addCallView];
    });
}

- (void)rtccCallEnded:(RtccCall *)call
{
    NSLog(@">>>> %s", __FUNCTION__);
    //	[self removeCallView];
}

- (void)rtccContact:(NSString *)contactID canBeCalled:(BOOL)canBeCalled
{
    NSLog(@">>>> %s", __FUNCTION__);
    [[self commandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:canBeCalled?1:0] callbackId:cb_canCall];
}





- (void)rtccDidDisconnect:(NSError *)error
{
    NSLog(@">>>> %s", __FUNCTION__);
    if (cb_disconnect)
    {
        if (error)
        {
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                         messageAsInt:(int)[error code]]
                                         callbackId:cb_connect];
        } else {
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                         callbackId:cb_connect];
        }
    }
    [[self commandDelegate] evalJs:[NSString stringWithFormat:@"Weemo.internal.connectionChanged(%d);", (int)[error code]] scheduledOnRunLoop:YES];
    cb_disconnect = nil;
}

#pragma mark - RtccCall delegation
- (void)RtccCall:(id)sender videoOutSizeChange:(CGSize)size
{
    //[cvc_active resizeVideoOut:NO];
    [cvc_active resizeCallView:YES];
}

- (void)RtccCall:(id)sender videoReceiving:(BOOL)isReceiving
{
    NSLog(@">>>> %s: %@", __FUNCTION__, isReceiving ?@"YES":@"NO");
    [cvc_active updateIdleStatus];
    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.videoInChanged(%d, %s);", [sender callid], isReceiving?"true":"false"] scheduledOnRunLoop:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[cvc_active v_videoIn]setHidden:!isReceiving];
        [cvc_active resizeVideoIn:YES];
    });
}

- (void)rtccCall:(id)sender videoSending:(BOOL)isSending
{
    NSLog(@">>>> %s: %@",__FUNCTION__,  isSending ? @"YES":@"NO");
    [cvc_active updateIdleStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[cvc_active b_toggleVideo]setSelected:isSending];
        [[cvc_active v_videoOut]setHidden:!isSending];
        [cvc_active resizeVideoIn:YES];
    });
}

- (void)rtccCall:(id)sender videoProfile:(video_profile_t)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@">>>> %s: %d",__FUNCTION__,  (int)profile);
        [cvc_active resizeVideoIn:YES];
    });
}

- (void)rtccCall:(id)sender videoSource:(int)source
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@">>>> %s: %@",__FUNCTION__,  (source == 0)?@"Front":@"Back");
        [[cvc_active b_switchVideo] setSelected:!(source == 0)];
        [cvc_active resizeVideoIn:YES];
    });
}

- (void)rtccCall:(id)call audioSending:(BOOL)isSending
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@">>>> %s: %@",__FUNCTION__,  isSending?@"YES":@"NO");
        [[cvc_active b_toggleAudio]setSelected:!isSending];
    });
}

- (void)rtccCall:(id)sender callStatus:(callStatus_t)status
{
    NSString *callStatus;
    NSLog(@">>>> %s: 0x%X",__FUNCTION__,  (int)status);
    
    switch (status) {
        case callStatus_proceeding:
            callStatus = @"PROCEEDING";
            break;
        case callStatus_ringing:
            callStatus = @"RINGING";
            break;
        case callStatus_active:
            callStatus = @"ACTIVE";
            break;
        case callStatus_ended:
            callStatus = @"ENDED";
            break;
        default:
            break;
    }
    NSLog(@"The status of the call in plugin is: %@",callStatus);
    NSLog(@"The callID in the plugin is: %d", [[[Rtcc instance]activeCall] callid]);
    
    [cvc_active updateIdleStatus];
    
    //[[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callStatusChanged(%d, %u);", [[[Rtcc instance]activeCall] callid], status] scheduledOnRunLoop:YES];
    
    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callStatusChanged(%d,'%@');", [[[Rtcc instance]activeCall] callid],callStatus] scheduledOnRunLoop:YES];
}

#pragma mark - CallWindow Delegation
- (void)cwHangup:(CallViewController *)sender
{
    //if ([cvc_active canComeBack])
    if (YES)
    {
        //[self removeCallView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[Rtcc instance]activeCall]videoStop];
        });
    } else {
        [[[Rtcc instance]activeCall]hangup];
    }
    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                 callbackId:cb_canComeBack];
}

#pragma mark - dgMethods

- (void)dgStatusChange:(appStatus)status
{ //Yes, i really should think about automating the enable/hidden status change.
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            default:
            case sta_notConnected: //not connected, not connecting
            {	//auth interface
                
                
            }	break;
            case sta_connecting: //connecting
            {
            }	break;
            case sta_authenticating:
            case sta_connected: //connected, not authenticated
            {
                if (cb_connect)
                {
                    if (NO)
                    {
                        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                                     messageAsInt:0]
                                                     callbackId:cb_connect];
                    } else {
                        NSLog(@"RTCC connected without error");
                        [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                                     callbackId:cb_connect];
                    }
                }
                cb_connect = nil;
                [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.connectionChanged(%d);", 0] scheduledOnRunLoop:YES];
                
            }	break;
            case sta_authenticated: //connected & authenticated
            {
                //AH: Not passing back any errors on auth. Will have to fix later
                if (NO)
                {
                    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                                 messageAsInt:0]
                                                 callbackId:cb_authent];
                } else {
                    NSLog(@"RTCC authenticated without error");
                    [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                              messageAsString:@"OK"]
                                                 callbackId:cb_authent];
                }
                cb_authent = nil;
                
            }	break;
            case sta_resetting:
            case sta_disconnecting: //Disconnecting
            {
                
            } break;
        }
        
    });
}

- (void)dgCallStatusChange:(RtccCall *)call
{
    
    NSLog(@">>>> %s: 0x%X",__FUNCTION__,  (int)[call callStatus]);
    
    NSString *callStatus, *callTerminatedMessage;
    
    if ([call callStatus] == callStatus_ringing)
    {
        callStatus = @"RINGING";
        //AH: If the call was created incoming, let JS know
        [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callCreated(%d, \"%s\");", [call callid],
                                       [[call contactUID] UTF8String]] scheduledOnRunLoop:YES];
        
    } else if ([call callStatus] == callStatus_ended || call == nil) {
        
        callStatus = @"ENDED";
        NSTimeInterval elapsedTime = [[[RtccDelegate instance] activeCall] callDuration];
        int secondes = fmod(elapsedTime, 60);
        int minutes = fmod(elapsedTime / 60, 60);
        int hours = elapsedTime / 3600;
        callTerminatedMessage = [callTerminatedMessage stringByAppendingFormat:@"\nDuration: %@", [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, secondes]];
        /*
         dispatch_async(dispatch_get_main_queue(), ^{
         [[self emitting] dismissWithClickedButtonIndex:-1 animated:YES];
         [[self incoming] dismissWithClickedButtonIndex:-1 animated:YES];
         [self setEmitting: nil]; [self setIncoming: nil];
         [[AlertSystem sharedAlert] stopRinging];
         [[AlertSystem sharedAlert] dismissLocalNotification];
         [self removeCallView:^{
         [self dgDisplayMessage:callTerminatedMessage during:2.];
         }];
         });*/
    } else if ([call callStatus] == callStatus_proceeding)
    {
        callStatus = @"PROCEEDING";
        //AH: If the call was created outgoing, let JS know
        [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callCreated(%d, \"%s\");", [call callid],
                                       [[call contactUID] UTF8String]] scheduledOnRunLoop:YES];
        
    } else if ([call callStatus] == callStatus_active)
    {
        callStatus = @"ACTIVE";
        
        //Check to make sure the active call is sending audio
        if([[RtccDelegate instance] activeCall].sendingAudio){
            NSLog(@">>>> The call is sending Audio Successfully during the call");
        }else{
            NSLog(@">>>> The call is NOT sending Audio Successfully. Attempted to restart audio sending");
            //restart audio to attempt getting it going again
            [[[RtccDelegate instance] activeCall] audioStop];
            [[[RtccDelegate instance] activeCall] audioStart];
        }
        
        //Now that the call is active, display the Call Window
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayCallWindow:nil];
            
        });
    }
    
    
    NSLog(@"The status of the call in plugin is: %@",callStatus);
    NSLog(@"The callID in the plugin is: %d", [[[Rtcc instance]activeCall] callid]);
    
    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"Weemo.internal.callStatusChanged(%d,'%@');", [[[Rtcc instance]activeCall] callid],callStatus] scheduledOnRunLoop:YES];
    
//    [[self commandDelegate]evalJs:[NSString stringWithFormat:@"javascript: angular.element(document.querySelector('#pageContainer')).scope().$broadcast('callchange','%@');",callStatus]] ;
    
}



- (void)dgSetMPHandle:(NSString *)mpHandle
{}

- (void)dgMeetingPointCreated:(NSString *)mpHandle
{
    
}

- (void)dgDidConnect:(NSError *)did
{
    
}

- (void)dgDidAuthenticate:(NSError *)did
{
    
}

- (void)dgDidDisconnect:(NSError *)error
{/*
  [self removeCallView:^{
  [self dgDisplayMessage:NSLocalizedString(@"mes_disconnected", nil) during:2.];
  }];
  */
    
    if (cb_disconnect)
    {
        if (NO)
        {
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                         messageAsInt:[error code]]
                                         callbackId:cb_disconnect];
        } else {
            [[self commandDelegate]sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                         callbackId:cb_disconnect];
            
        }
    }
    [self removeCallView:nil];
    [[self commandDelegate] evalJs:[NSString stringWithFormat:@"Weemo.internal.connectionChanged(%d);", (int)[error code]] scheduledOnRunLoop:YES];
    cb_disconnect = nil;
    
}

- (void)dgContact:(NSString *)contactUID canBeCalled:(BOOL)canBe
{

	NSLog(@">>>> %s", __FUNCTION__);
	[[self commandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:canBe?1:0] callbackId:cb_canCall];

	
}

- (void)dgDisplayMessage:(NSString *)message during:(float)timer
{
    
}

- (void)dgDisplayIncomingChat:(NSString *)message fromContact:(NSString *)contactID answer:(void (^)())action
{
}

#pragma mark - HomeDelegate Methods

- (void)shareCursorLocation:(CGPoint)location
{
    
}
- (void)shareClickLocation:(CGPoint)location
{
    
}
- (void)callCursorLocation:(CGPoint)location
{
    
}


@end
