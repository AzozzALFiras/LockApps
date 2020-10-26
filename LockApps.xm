#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIAlert+Blocks.h"
#import "SparkAppList.h"



@interface SBApplication
-(NSString *)displayName;
-(NSString *)bundleIdentifier;
-(int)dataUsage;
-(BOOL)isSpringBoard;
@end

NSString *bundle;

@interface SpringBoard
+ (id)sharedInstance;
- (void)_simulateHomeButtonPress;
@end


static NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/co.azozzalfiras.lockapps.plist"];
NSString *pin = [plist objectForKey:@"password"];


static void reloadPrefs() {
pin = [plist objectForKey:@"password"];
}

static void PreferencesChanges(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
reloadPrefs();
}




NSBundle* LockAppsBundle;
NSDictionary* englishLocalizations;

NSString* localize(NSString* key)
{
if(key == nil)
{
return nil;
}

if(!LockAppsBundle)
{
LockAppsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LockApps.bundle"];
}

NSString* localizedString = [LockAppsBundle localizedStringForKey:key value:key table:nil];

if([localizedString isEqualToString:key])
{
if(!englishLocalizations)
{
englishLocalizations = [NSDictionary dictionaryWithContentsOfFile:[LockAppsBundle pathForResource:@"LockApps" ofType:@"strings" inDirectory:@"en.lproj"]];
}

NSString* EnglishString = [englishLocalizations objectForKey:key];

if(EnglishString)
{
return EnglishString;
}
else
{
return key;
}
}

return localizedString;
}


%hook SpringBoard
static SpringBoard *__strong sharedInstance;
- (id)init {
id original = %orig;
sharedInstance = original;
return original;
}
%new
+ (id)sharedInstance {
return sharedInstance;
}
%end


%hook SBApplication
-(NSString*)bundleIdentifier{
NSString *orig = %orig;
if(orig){
bundle = orig;
}
return orig;
}
%end

BOOL rann = YES;

%hook SBStatusBarStateAggregator
-(void)_updateLockItem {
%orig;
rann = YES;
}
%end

%hook SpringBoard
-(void)frontDisplayDidChange:(id)arg1{
%orig;
pin = [plist objectForKey:@"password"];
NSLog(@"the return is %@", arg1);
if(arg1 == nil){
rann = YES;
}
if ([arg1 isKindOfClass:%c(SBApplication)]) {
if([SparkAppList doesIdentifier:@"co.azozzalfiras.lockapps" andKey:@"lockedApps" containBundleIdentifier:bundle] && rann){

rann = NO;

UIWindow *keyWindow1 = [UIApplication sharedApplication].keyWindow;

CGRect screenSize = [[UIScreen mainScreen] bounds];
CGFloat screenHeight = screenSize.size.height;
CGFloat screenWidth = screenSize.size.width;

__block UIWindow *window2 = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
window2.backgroundColor = [UIColor blackColor];
window2.windowLevel = UIWindowLevelStatusBar;
keyWindow1.hidden = YES;
window2.hidden = NO;
dispatch_async(dispatch_get_main_queue(), ^{
LAContext *myContext = [[LAContext alloc] init];
NSError *authError = nil;
NSString *myLocalizedReasonString = localize(@"Authenticate");

if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
[myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
localizedReason:myLocalizedReasonString
reply:^(BOOL success, NSError *error) {
dispatch_async(dispatch_get_main_queue(), ^{
if (success) {
%orig;
keyWindow1.hidden = NO;
window2.hidden = YES;
rann = NO;
return;
}else{
dispatch_async(dispatch_get_main_queue(), ^{
switch (error.code) {
case LAErrorUserCancel:
rann = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

[[objc_getClass("SpringBoard") sharedInstance] _simulateHomeButtonPress];
});
break;


case LAErrorUserFallback:
rann = NO;
UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"LockApps" message:localize(@"YOUR_PASSWORD") delegate:nil cancelButtonTitle:localize(@"CONTINUE") otherButtonTitles:localize(@"CANCEl"), nil];
alert.alertViewStyle = UIAlertViewStylePlainTextInput;
UITextField *alertTextField = [alert textFieldAtIndex:0];
alertTextField.keyboardType = UIKeyboardTypeDefault;
alertTextField.secureTextEntry = YES;
alertTextField.placeholder = localize(@"ENTER_PASSWORD");
[alert show];
[alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
if (buttonIndex == 0){
if([alertTextField.text isEqualToString:pin]){

%orig;
keyWindow1.hidden = NO;
window2.hidden = YES;
}else{
rann = NO;
keyWindow1.hidden = NO;
window2.hidden = YES;
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
[[objc_getClass("SpringBoard") sharedInstance] _simulateHomeButtonPress];
});
}

}
}];
break;


}


});
}

});


}];
}else{

UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"LockApps" message:localize(@"YOUR_PASSWORD") delegate:nil cancelButtonTitle:localize(@"CONTINUE") otherButtonTitles:localize(@"CANCEl"), nil];
alert.alertViewStyle = UIAlertViewStylePlainTextInput;
UITextField *alertTextField = [alert textFieldAtIndex:0];
alertTextField.keyboardType = UIKeyboardTypeDefault;
alertTextField.secureTextEntry = YES;
alertTextField.placeholder = localize(@"ENTER_PASSWORD");
[alert show];
[alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
if (buttonIndex == 0){
if([alertTextField.text isEqualToString:pin]){

%orig;
keyWindow1.hidden = NO;
window2.hidden = YES;
}else{
rann = NO;
keyWindow1.hidden = NO;
window2.hidden = YES;
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
[[objc_getClass("SpringBoard") sharedInstance] _simulateHomeButtonPress];
});
}

}
}];
}

});
}else if(![SparkAppList doesIdentifier:@"co.azozzalfiras.lockapps" andKey:@"lockedApps" containBundleIdentifier:bundle]){
rann = YES;
}
}else{
rann = YES;
}

}
%end

%hook SBUIController
-(void)activateApplication:(id)arg1 fromIcon:(id)arg2 location:(long long)arg3 activationSettings:(id)arg4 actions:(id)arg5 {
pin = [plist objectForKey:@"password"];
NSString* bundIdentifier = [arg1 bundleIdentifier];
if([SparkAppList doesIdentifier:@"co.azozzalfiras.lockapps" andKey:@"lockedApps" containBundleIdentifier:bundIdentifier]){
LAContext *myContext = [[LAContext alloc] init];
NSError *authError = nil;
NSString *myLocalizedReasonString = localize(@"Authenticate");

if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
[myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
localizedReason:myLocalizedReasonString
reply:^(BOOL success, NSError *error) {
dispatch_async(dispatch_get_main_queue(), ^{
if (success) {
rann = NO;
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

%orig;
});
}else{
dispatch_async(dispatch_get_main_queue(), ^{
switch (error.code) {
case LAErrorUserCancel:

break;


case LAErrorUserFallback:

UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"LockApps" message:localize(@"YOUR_PASSWORD") delegate:nil cancelButtonTitle:localize(@"CONTINUE") otherButtonTitles:localize(@"CANCEl"), nil];
alert.alertViewStyle = UIAlertViewStylePlainTextInput;
UITextField *alertTextField = [alert textFieldAtIndex:0];
alertTextField.keyboardType = UIKeyboardTypeDefault;
alertTextField.secureTextEntry = YES;
alertTextField.placeholder =localize(@"ENTER_PASSWORD");
[alert show];
[alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
if (buttonIndex == 0){
if([alertTextField.text isEqualToString:pin]){
%orig;
rann = NO;
}else{
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
[[objc_getClass("SpringBoard") sharedInstance] _simulateHomeButtonPress];
});
}

}
}];

break;


}


});
}

});


}];
}else{
UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"LockApps" message:localize(@"YOUR_PASSWORD") delegate:nil cancelButtonTitle:localize(@"CONTINUE") otherButtonTitles:localize(@"CANCEl"), nil];
alert.alertViewStyle = UIAlertViewStylePlainTextInput;
UITextField *alertTextField = [alert textFieldAtIndex:0];
alertTextField.keyboardType = UIKeyboardTypeDefault;
alertTextField.secureTextEntry = YES;
alertTextField.placeholder = localize(@"ENTER_PASSWORD");
[alert show];
[alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
if (buttonIndex == 0){
if([alertTextField.text isEqualToString:pin]){
%orig;
rann = NO;
}else{
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
[[objc_getClass("SpringBoard") sharedInstance] _simulateHomeButtonPress];
});
}

}
}];
//[self.navigationController popViewControllerAnimated:NO];
}
}else{
%orig;
}

}
%end

%ctor{
  
reloadPrefs();
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChanges, CFSTR("co.azozzalfiras.lockapps.preferences-changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
