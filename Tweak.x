#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

//#define REMOTE_LOG_IP "172.20.10.2"
//#import <RemoteLog.h>

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString * nsDomainString = @"ch.filippofinke.lockbtc";
static NSString * nsNotificationString = @"ch.filippofinke.lockbtc/preferences.changed";
static BOOL enabled;
static UILabel* label;


static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue)? [enabledValue boolValue] : YES;
	//RLog(@"Enabled: %s", enabled ? "Yes":"No");
}

@interface SBFLockScreenDateViewController
-(id)dateView;
@end


%hook SBFLockScreenDateViewController

-(void)setScreenOff:(BOOL)arg1 {
	if(!arg1 && enabled) {
		id view = [self dateView];
		if([[view subviews] count] == 2) {
			label = [[UILabel alloc] initWithFrame:CGRectMake(([view bounds].size.width - 200 )/ 2, [view bounds].size.height + 5, 200, 25)];
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.textColor = [UIColor whiteColor];
			[view addSubview:label];
		}

		NSURL *url = [NSURL URLWithString:@"https://api.coinbase.com/v2/prices/BTC-CHF/sell"];
		NSData *data = [NSData dataWithContentsOfURL:url];
		NSError *e = nil;
		NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
		NSString *text = [NSString stringWithFormat:@"1 BTC = %@ CHF", JSON[@"data"][@"amount"]];
		[label setText:text];
		//RLog(@"JSON: %@", JSON);
	} else if(label) {
		[label removeFromSuperview];
		label = nil;
	}
	//RLog(@"SBFLockScreenDateViewController setScreenOff %s", arg1? "YES" : "NO");
	%orig;
}

%end

%ctor {
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);


}
