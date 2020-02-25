#import "CleverTapPlugin.h"
#import "CleverTap.h"
#import "CleverTap+Inbox.h"
#import "CleverTapUTMDetail.h"
#import "CleverTap+ABTesting.h"
#import "CleverTapEventDetail.h"
#import "CleverTapSyncDelegate.h"
#import "CleverTapInAppNotificationDelegate.h"

@interface CleverTapPlugin ()  <CleverTapSyncDelegate, CleverTapInAppNotificationDelegate> {
}

@property (strong, nonatomic) FlutterMethodChannel *channel;

@end

static NSDateFormatter *dateFormatter;

@implementation CleverTapPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    CleverTapPlugin.sharedInstance.channel = [FlutterMethodChannel
                                              methodChannelWithName:@"clevertap_plugin"
                                              binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:CleverTapPlugin.sharedInstance channel:CleverTapPlugin.sharedInstance.channel];
}

+ (instancetype)sharedInstance {
    static CleverTapPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CleverTapPlugin alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    // TODO: check again
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CleverTap *clevertap = [CleverTap sharedInstance];
        [clevertap setSyncDelegate:self];
        [clevertap setInAppNotificationDelegate:self];
        [clevertap setLibrary:@"Flutter"];
        [self postNotificationWithName:kCleverTapExperimentsDidUpdate andBody:nil];
        [self addObservers];
    }
    return self;
}

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options {
    NSDictionary *notification = [options valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification && notification[@"wzrk_dl"]) {
        self.launchDeepLink = notification[@"wzrk_dl"];
        NSLog(@"CleverTapFlutter: setting launch deeplink: %@", self.launchDeepLink);
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method])
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    else if ([@"recordEvent" isEqualToString:call.method])
        [self recordEvent:call withResult:result];
    else if ([@"setDebugLevel" isEqualToString:call.method])
        [self setDebugLog:call withResult:result];
    else if ([@"profileSet" isEqualToString:call.method])
        [self profileSet:call withResult:result];
    else if ([@"recordChargedEvent" isEqualToString:call.method])
        [self recordChargedEvent:call withResult:result];
    else if ([@"initializeInbox" isEqualToString:call.method])
        [self initializeInbox];
    else if ([@"showInbox" isEqualToString:call.method])
        [self showInbox:call withResult:result];
    else if ([@"onUserLogin" isEqualToString:call.method])
        [self onUserLogin:call withResult:result];
    else if ([@"setPushTokenAsString" isEqualToString:call.method])
        [self setPushTokenAsString:call withResult:result];
    else if ([@"registerForPush" isEqualToString:call.method])
        [self registerForPush:call withResult:result];
    else if ([@"enablePersonalization" isEqualToString:call.method])
        [self enablePersonalization:call withResult:result];
    else if ([@"disablePersonalization" isEqualToString:call.method])
        [self disablePersonalization:call withResult:result];
    else if ([@"recordScreenView" isEqualToString:call.method])
        [self recordScreenView:call withResult:result];
    else if ([@"setOptOut" isEqualToString:call.method])
        [self setOptOut:call withResult:result];
    else if ([@"setOffline" isEqualToString:call.method])
        [self setOffline:call withResult:result];
    else if ([@"enableDeviceNetworkInfoReporting" isEqualToString:call.method])
        [self enableDeviceNetworkInfoReporting:call withResult:result];
    else if ([@"eventGetFirstTime" isEqualToString:call.method])
        [self eventGetFirstTime:call withResult:result];
    else if ([@"eventGetLastTime" isEqualToString:call.method])
        [self eventGetLastTime:call withResult:result];
    else if ([@"eventGetOccurrences" isEqualToString:call.method])
        [self eventGetOccurrences:call withResult:result];
    else if ([@"eventGetDetail" isEqualToString:call.method])
        [self eventGetDetail:call withResult:result];
    else if ([@"getEventHistory" isEqualToString:call.method])
        [self getEventHistory:call withResult:result];
    else if ([@"setLocation" isEqualToString:call.method])
        [self setLocation:call withResult:result];
    else if ([@"profileGetCleverTapAttributionIdentifier" isEqualToString:call.method])
        [self profileGetCleverTapAttributionIdentifier:call withResult:result];
    else if ([@"profileGetCleverTapID" isEqualToString:call.method])
        [self profileGetCleverTapID:call withResult:result];
    else if ([@"profileSetGraphUser" isEqualToString:call.method])
        [self profileSetGraphUser:call withResult:result];
    else if ([@"profileGetProperty" isEqualToString:call.method])
        [self profileGetProperty:call withResult:result];
    else if ([@"profileRemoveValueForKey" isEqualToString:call.method])
        [self profileRemoveValueForKey:call withResult:result];
    else if ([@"profileSetMultiValues" isEqualToString:call.method])
        [self profileSetMultiValues:call withResult:result];
    else if ([@"profileAddMultiValue" isEqualToString:call.method])
        [self profileAddMultiValue:call withResult:result];
    else if ([@"profileAddMultiValues" isEqualToString:call.method])
        [self profileAddMultiValues:call withResult:result];
    else if ([@"profileRemoveMultiValue" isEqualToString:call.method])
        [self profileRemoveMultiValue:call withResult:result];
    else if ([@"profileRemoveMultiValues" isEqualToString:call.method])
        [self profileRemoveMultiValues:call withResult:result];
    else if ([@"pushInstallReferrer" isEqualToString:call.method])
        [self pushInstallReferrer:call withResult:result];
    else if ([@"sessionGetTimeElapsed" isEqualToString:call.method])
        [self sessionGetTimeElapsed:call withResult:result];
    else if ([@"sessionGetTotalVisits" isEqualToString:call.method])
        [self sessionGetTotalVisits:call withResult:result];
    else if ([@"sessionGetScreenCount" isEqualToString:call.method])
        [self sessionGetScreenCount:call withResult:result];
    else if ([@"sessionGetPreviousVisitTime" isEqualToString:call.method])
        [self sessionGetPreviousVisitTime:call withResult:result];
    else if ([@"sessionGetUTMDetails" isEqualToString:call.method])
        [self sessionGetUTMDetails:call withResult:result];
    else if ([@"getInboxMessageCount" isEqualToString:call.method])
        [self getInboxMessageCount:call withResult:result];
    else if ([@"getInboxMessageUnreadCount" isEqualToString:call.method])
        [self getInboxMessageUnreadCount:call withResult:result];
    else if ([@"getInitialUrl" isEqualToString:call.method])
        [self getInitialUrl:call result:result];
    else if ([@"registerBooleanVariable" isEqualToString:call.method])
        [self registerBooleanVariable:call withResult:result];
    else if ([@"registerDoubleVariable" isEqualToString:call.method])
        [self registerDoubleVariable:call withResult:result];
    else if ([@"registerIntegerVariable" isEqualToString:call.method])
        [self registerIntegerVariable:call withResult:result];
    else if ([@"registerStringVariable" isEqualToString:call.method])
        [self registerStringVariable:call withResult:result];
    else if ([@"registerListOfBooleanVariable" isEqualToString:call.method])
        [self registerListOfBooleanVariable:call withResult:result];
    else if ([@"registerListOfDoubleVariable" isEqualToString:call.method])
        [self registerListOfDoubleVariable:call withResult:result];
    else if ([@"registerListOfIntegerVariable" isEqualToString:call.method])
        [self registerListOfIntegerVariable:call withResult:result];
    else if ([@"registerListOfStringVariable" isEqualToString:call.method])
        [self registerListOfStringVariable:call withResult:result];
    else if ([@"registerMapOfBooleanVariable" isEqualToString:call.method])
        [self registerMapOfBooleanVariable:call withResult:result];
    else if ([@"registerMapOfDoubleVariable" isEqualToString:call.method])
        [self registerMapOfDoubleVariable:call withResult:result];
    else if ([@"registerMapOfIntegerVariable" isEqualToString:call.method])
        [self registerMapOfIntegerVariable:call withResult:result];
    else if ([@"registerMapOfStringVariable" isEqualToString:call.method])
        [self registerMapOfStringVariable:call withResult:result];
    else if ([@"getBooleanVariable" isEqualToString:call.method])
        [self getBooleanVariable:call withResult:result];
    else if ([@"getDoubleVariable" isEqualToString:call.method])
        [self getDoubleVariable:call withResult:result];
    else if ([@"getIntegerVariable" isEqualToString:call.method])
        [self getIntegerVariable:call withResult:result];
    else if ([@"getStringVariable" isEqualToString:call.method])
        [self getStringVariable:call withResult:result];
    else if ([@"getListOfBooleanVariable" isEqualToString:call.method])
        [self getListOfBooleanVariable:call withResult:result];
    else if ([@"getListOfDoubleVariable" isEqualToString:call.method])
        [self getListOfDoubleVariable:call withResult:result];
    else if ([@"getListOfIntegerVariable" isEqualToString:call.method])
        [self getListOfIntegerVariable:call withResult:result];
    else if ([@"getListOfStringVariable" isEqualToString:call.method])
        [self getListOfStringVariable:call withResult:result];
    else if ([@"getMapOfBooleanVariable" isEqualToString:call.method])
        [self getMapOfBooleanVariable:call withResult:result];
    else if ([@"getMapOfDoubleVariable" isEqualToString:call.method])
        [self getMapOfDoubleVariable:call withResult:result];
    else if ([@"getMapOfIntegerVariable" isEqualToString:call.method])
        [self getMapOfIntegerVariable:call withResult:result];
    else if ([@"getMapOfStringVariable" isEqualToString:call.method])
        [self getMapOfStringVariable:call withResult:result];
    else if ([@"createNotificationChannel" isEqualToString:call.method])
        result(nil);
    else if ([@"createNotificationChannelWithSound" isEqualToString:call.method])
        result(nil);
    else if ([@"createNotificationChannelWithGroupId" isEqualToString:call.method])
        result(nil);
    else if ([@"createNotificationChannelWithGroupIdAndSound" isEqualToString:call.method])
        result(nil);
    else if ([@"createNotificationChannelGroup" isEqualToString:call.method])
        result(nil);
    else if ([@"deleteNotificationChannel" isEqualToString:call.method])
        result(nil);
    else
        result(FlutterMethodNotImplemented);
}

# pragma mark launch

- (void)getInitialUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *launchDeepLink = self.launchDeepLink;
    if (launchDeepLink != nil) {
        result(launchDeepLink);
    } else {
        result(nil);
    }
}

- (void)setDebugLog:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [CleverTap setDebugLevel:[call.arguments[@"debugLevel"] intValue]];
    result(nil);
}

- (void)setPushToken:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] setPushToken:call.arguments[@"token"]];
    result(nil);
}

- (void)setPushTokenAsString:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] setPushTokenAsString:call.arguments[@"token"]];
    result(nil);
}

- (void)registerForPush:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        // Fallback on earlier versions
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    result(nil);
}

#pragma mark Personalization

- (void)enablePersonalization:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [CleverTap enablePersonalization];
    result(nil);
}

- (void)disablePersonalization:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [CleverTap disablePersonalization];
    result(nil);
}

#pragma mark Event API

- (void)recordEvent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] recordEvent:call.arguments[@"eventName"] withProps:call.arguments[@"eventData"]];
    result(nil);
}

- (void)recordChargedEvent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] recordChargedEventWithDetails:call.arguments[@"chargeDetails"] andItems:call.arguments[@"items"]];
    result(nil);
}

- (void)recordScreenView:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] recordScreenView:call.arguments[@"screenName"]];
    result(nil);
}

- (void)profileSet:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profilePush:call.arguments[@"profile"]];
    result(nil);
}

- (void)onUserLogin:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] onUserLogin:call.arguments[@"profile"]];
    result(nil);
}

- (void)setOptOut:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] setOptOut:[call.arguments[@"value"] boolValue]];
    result(nil);
}

- (void)setOffline:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] setOffline:[call.arguments[@"value"] boolValue]];
    result(nil);
}

- (void)enableDeviceNetworkInfoReporting:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] enableDeviceNetworkInfoReporting:[call.arguments[@"value"] boolValue]];
    result(nil);
}

- (void)eventGetFirstTime:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSTimeInterval res = [[CleverTap sharedInstance] eventGetFirstTime:call.arguments[@"eventName"]];
    result(@(res));
}

- (void)eventGetLastTime:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSTimeInterval res = [[CleverTap sharedInstance] eventGetLastTime:call.arguments[@"eventName"]];
    result(@(res));
}

- (void)eventGetOccurrences:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    int res = [[CleverTap sharedInstance] eventGetOccurrences:call.arguments[@"eventName"]];
    result(@(res));
}

- (void)eventGetDetail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    CleverTapEventDetail *detail = [[CleverTap sharedInstance] eventGetDetail:call.arguments[@"eventName"]];
    NSDictionary *res = [self _eventDetailToDict:detail];
    result(res);
}

- (void)getEventHistory:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *history = [[CleverTap sharedInstance] userGetEventHistory];
    NSMutableDictionary *res = [NSMutableDictionary new];
    for (NSString *eventName in [history keyEnumerator]) {
        CleverTapEventDetail *detail = history[eventName];
        NSDictionary * _inner = [self _eventDetailToDict:detail];
        res[eventName] = _inner;
    }
    result(res);
}

- (void)setLocation:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    double lat = [call.arguments[@"latitude"] doubleValue];
    double lon = [call.arguments[@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat,lon);
    [[CleverTap sharedInstance] setLocation: coordinate];
    result(nil);
}

- (void)profileGetCleverTapAttributionIdentifier:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result([[CleverTap sharedInstance] profileGetCleverTapAttributionIdentifier]);
}

- (void)profileGetCleverTapID:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result([[CleverTap sharedInstance] profileGetCleverTapID]);
}

- (void)profileSetGraphUser:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profilePushGraphUser:call.arguments[@"profile"]];
}

- (void)profileGetProperty:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result([[CleverTap sharedInstance] profileGet:call.arguments[@"propertyName"]]);
}

- (void)profileRemoveValueForKey:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileRemoveValueForKey:call.arguments[@"key"]];
    result(nil);
}

- (void)profileSetMultiValues:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileSetMultiValues:call.arguments[@"values"] forKey:call.arguments[@"key"]];
    result(nil);
}

- (void)profileAddMultiValue:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileAddMultiValue:call.arguments[@"value"] forKey:call.arguments[@"key"]];
    result(nil);
}

- (void)profileAddMultiValues:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileSetMultiValues:call.arguments[@"values"] forKey:call.arguments[@"key"]];
    result(nil);
}

- (void)profileRemoveMultiValue:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileRemoveMultiValue:call.arguments[@"value"] forKey:call.arguments[@"key"]];
    result(nil);
}

- (void)profileRemoveMultiValues:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] profileRemoveMultiValues:call.arguments[@"values"] forKey:call.arguments[@"key"]];
    result(nil);
}

- (void)pushInstallReferrer:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] pushInstallReferrerSource:call.arguments[@"source"] medium:call.arguments[@"medium"] campaign:call.arguments[@"campaign"]];
    result(nil);
}

- (void)sessionGetTimeElapsed:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSTimeInterval res = [[CleverTap sharedInstance] sessionGetTimeElapsed];
    result(@(res));
}

- (void)sessionGetTotalVisits:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    int res = [[CleverTap sharedInstance] userGetTotalVisits];
    result(@(res));
}

- (void)sessionGetScreenCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    int res = [[CleverTap sharedInstance] userGetScreenCount];
    result(@(res));
}

- (void)sessionGetPreviousVisitTime:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSTimeInterval res = [[CleverTap sharedInstance] userGetPreviousVisitTime];
    result(@(res));
}

- (void)sessionGetUTMDetails:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    CleverTapUTMDetail *detail = [[CleverTap sharedInstance] sessionGetUTMDetails];
    NSDictionary *res = [self _utmDetailToDict:detail];
    result(res);
}

#pragma mark - Inbox

- (void)getInboxMessageCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    int res = (int)[[CleverTap sharedInstance] getInboxMessageCount];
    result(@(res));
}

- (void)getInboxMessageUnreadCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    int res = (int)[[CleverTap sharedInstance] getInboxMessageUnreadCount];
    result(@(res));
}

- (void)initializeInbox {
    [[CleverTap sharedInstance] initializeInboxWithCallback:^(BOOL success) {
        if (success) {
            [self postNotificationWithName:kCleverTapInboxDidInitialize andBody:nil];
            [[CleverTap sharedInstance] registerInboxUpdatedBlock:^{
                [self postNotificationWithName:kCleverTapInboxMessagesDidUpdate andBody:nil];
            }];
        }
    }];
}

- (void)showInbox:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *styleConfig = call.arguments[@"styleConfig"];
    if ([styleConfig isKindOfClass:[NSNull class]]) {
        styleConfig = nil;
    }
    CleverTapInboxViewController *inboxController = [[CleverTap sharedInstance] newInboxViewControllerWithConfig:[self _dictToInboxStyleConfig:styleConfig ? styleConfig : nil] andDelegate:nil];
    if (inboxController) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:inboxController];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        UIViewController *mainViewController = keyWindow.rootViewController;
        [mainViewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (CleverTapInboxStyleConfig*)_dictToInboxStyleConfig: (NSDictionary *)dict {
    CleverTapInboxStyleConfig *_config = [CleverTapInboxStyleConfig new];
    NSString *title = [dict valueForKey:@"navBarTitle"];
    if (title) {
        _config.title = title;
    }
    NSArray *messageTags = [dict valueForKey:@"tabs"];
    if (messageTags) {
        _config.messageTags = messageTags;
    }
    NSString *backgroundColor = [dict valueForKey:@"inboxBackgroundColor"];
    if (backgroundColor) {
        _config.backgroundColor = [self ct_colorWithHexString:backgroundColor alpha:1.0];
    }
    NSString *navigationBarTintColor = [dict valueForKey:@"navBarColor"];
    if (navigationBarTintColor) {
        _config.navigationBarTintColor = [self ct_colorWithHexString:navigationBarTintColor alpha:1.0];
    }
    NSString *navigationTintColor = [dict valueForKey:@"navBarTitleColor"];
    if (navigationTintColor) {
        _config.navigationTintColor = [self ct_colorWithHexString:navigationTintColor alpha:1.0];
    }
    NSString *tabBackgroundColor = [dict valueForKey:@"tabBackgroundColor"];
    if (tabBackgroundColor) {
        _config.navigationBarTintColor = [self ct_colorWithHexString:tabBackgroundColor alpha:1.0];
    }
    NSString *tabSelectedBgColor = [dict valueForKey:@"tabSelectedBgColor"];
    if (tabSelectedBgColor) {
        _config.tabSelectedBgColor = [self ct_colorWithHexString:tabSelectedBgColor alpha:1.0];
    }
    NSString *tabSelectedTextColor = [dict valueForKey:@"tabSelectedTextColor"];
    if (tabSelectedTextColor) {
        _config.tabSelectedTextColor = [self ct_colorWithHexString:tabSelectedTextColor alpha:1.0];
    }
    NSString *tabUnSelectedTextColor = [dict valueForKey:@"tabUnSelectedTextColor"];
    if (tabUnSelectedTextColor) {
        _config.tabUnSelectedTextColor = [self ct_colorWithHexString:tabUnSelectedTextColor alpha:1.0];
    }
    return _config;
}
- (UIColor *)ct_colorWithHexString:(NSString *)string alpha:(CGFloat)alpha {
    if (![string isKindOfClass:[NSString class]] || [string length] == 0) {
        return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    unsigned int hexint = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    return color;
}

#pragma mark - Dynamic Variables

- (void)registerBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerBoolVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerDoubleVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerIntegerVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerStringVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerListOfBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerArrayOfBoolVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerListOfDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerArrayOfDoubleVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerListOfIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerArrayOfIntegerVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerListOfStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerArrayOfStringVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerMapOfBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerDictionaryOfBoolVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerMapOfDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerDictionaryOfDoubleVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerMapOfIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerDictionaryOfIntegerVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)registerMapOfStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [[CleverTap sharedInstance] registerDictionaryOfStringVariableWithName:call.arguments[@"name"]];
    result(nil);
}

- (void)getBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL res = [[CleverTap sharedInstance] getBoolVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(@(res));
}

- (void)getDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    double res = [[CleverTap sharedInstance] getDoubleVariableWithName:call.arguments[@"name"] defaultValue:[call.arguments[@"defaultValue"] doubleValue]];
    result(@(res));
}

- (void)getIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    int res = [[CleverTap sharedInstance] getIntegerVariableWithName:call.arguments[@"name"] defaultValue:[call.arguments[@"defaultValue"] intValue]];
    result(@(res));
}

- (void)getStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSString *res = [[CleverTap sharedInstance] getStringVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getListOfBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSArray *res = [[CleverTap sharedInstance] getArrayOfBoolVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getListOfDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSArray *res = [[CleverTap sharedInstance] getArrayOfDoubleVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getListOfIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSArray *res = [[CleverTap sharedInstance] getArrayOfIntegerVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getListOfStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSArray *res = [[CleverTap sharedInstance] getArrayOfStringVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getMapOfBooleanVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSDictionary *res = [[CleverTap sharedInstance] getDictionaryOfBoolVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getMapOfDoubleVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSDictionary *res = [[CleverTap sharedInstance] getDictionaryOfDoubleVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getMapOfIntegerVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSDictionary *res = [[CleverTap sharedInstance] getDictionaryOfIntegerVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

- (void)getMapOfStringVariable:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    NSDictionary *res = [[CleverTap sharedInstance] getDictionaryOfStringVariableWithName:call.arguments[@"name"] defaultValue:call.arguments[@"defaultValue"]];
    result(res);
}

#pragma mark -  private/helpers

- (NSDictionary*)_eventDetailToDict:(CleverTapEventDetail*)detail {
    NSMutableDictionary *_dict = [NSMutableDictionary new];
    
    if(detail) {
        if(detail.eventName) {
            [_dict setObject:detail.eventName forKey:@"eventName"];
        }
        
        if(detail.firstTime){
            [_dict setObject:@(detail.firstTime) forKey:@"firstTime"];
        }
        
        if(detail.lastTime){
            [_dict setObject:@(detail.lastTime) forKey:@"lastTime"];
        }
        
        if(detail.count){
            [_dict setObject:@(detail.count) forKey:@"count"];
        }
    }
    
    return _dict;
}

- (NSDictionary*)_utmDetailToDict:(CleverTapUTMDetail*)detail {
    NSMutableDictionary *_dict = [NSMutableDictionary new];
    
    if(detail) {
        if(detail.source) {
            [_dict setObject:detail.source forKey:@"source"];
        }
        
        if(detail.medium) {
            [_dict setObject:detail.medium forKey:@"medium"];
        }
        
        if(detail.campaign) {
            [_dict setObject:detail.campaign forKey:@"campaign"];
        }
    }
    return _dict;
}

- (NSDictionary *)formatProfile:(NSDictionary *)profile {
    NSMutableDictionary *_profile = [NSMutableDictionary new];
    
    for (NSString *key in [profile keyEnumerator]) {
        id value = [profile objectForKey:key];
        
        if([key isEqualToString:@"DOB"]) {
            
            NSDate *dob = nil;
            
            if([value isKindOfClass:[NSString class]]) {
                
                if(!dateFormatter) {
                    dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                }
                
                dob = [dateFormatter dateFromString:value];
                
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                dob = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
            }
            
            if(dob) {
                value = dob;
            }
        }
        
        [_profile setObject:value forKey:key];
    }
    
    return _profile;
}


#pragma mark -  Notifications

- (void)emitEventInternal:(NSNotification *)notification {
    [self.channel invokeMethod:notification.name arguments:notification.userInfo];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapProfileDidInitialize
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapProfileSync
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapInAppNotificationDismissed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapInboxDidInitialize
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapInboxMessagesDidUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emitEventInternal:)
                                                 name:kCleverTapExperimentsDidUpdate
                                               object:nil];
}

- (void)postNotificationWithName:(NSString *)name andBody:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:body];
}

#pragma mark CleverTapSyncDelegate

- (void)profileDidInitialize:(NSString*)cleverTapID {
    if(!cleverTapID) {
        return;
    }
    [self postNotificationWithName:kCleverTapProfileDidInitialize andBody:@{@"CleverTapID":cleverTapID}];
}

- (void)profileDataUpdated:(NSDictionary *)updates {
    if(!updates) {
        return ;
    }
    [self postNotificationWithName:kCleverTapProfileSync andBody:@{@"updates":updates}];
}

#pragma mark CleverTapInAppNotificationDelegate

- (void)inAppNotificationDismissedWithExtras:(NSDictionary *)extras andActionExtras:(NSDictionary *)actionExtras {
    
    NSMutableDictionary *body = [NSMutableDictionary new];
    
    if (extras != nil) {
        body[@"extras"] = extras;
    }
    
    if (actionExtras != nil) {
        body[@"actionExtras"] = actionExtras;
    }
    
    [self postNotificationWithName:kCleverTapInAppNotificationDismissed andBody:body];
}

@end
