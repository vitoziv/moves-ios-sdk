moves-ios-sdk
=============
[Moves App](http://moves-app.com) SDK For iOS. 

![Moves App Integration](https://dev.moves-app.com/assets/images/moves-api.png)

#Getting Started

##Installing the moves-ios-sdk
**1. CocoaPods**

- Add the ``pod 'moves-ios-sdk', '~> 0.0.4'`` pod to your **Podfile**. 
- Run ``pod install``, and the Moves SDK will be available in your project.

What's [CocoaPods](http://cocoapods.org/).
See the documentation on the CocoaPods website if you want to set up a new or existing project.

**2. Add the moves-ios-sdk to your project**
- Open your existing project.
- Drag the **moves-ios-sdk** folder from the example project into your Xcode project.
- Make sure the “Copy items into destination group’s folder (if needed)” checkbox is checked.
- In this case you need to add [AFNetworking](https://github.com/AFNetworking/AFNetworking) to your project.

##Get ClientId and ClientSecret
When you register your app with Moves, it will provide you with a **Client ID** and **Client secret**. They identify your app to Moves's API. 

[Register your app with Moves](https://dev.moves-app.com/clients)

##Add the Moves URL scheme
copy and paste the following into the XML Source for the Info.plist:
```Xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.yourcompany</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>[YOUR URL SCHEME]</string>
            </array>
        </dict>
    </array>
```
**[YOUR URL SCHEME]** is setted when you [Register your app with Moves](https://dev.moves-app.com/clients)

##Configure your App Delegate

At the top of your app delegate source file (and anywhere you call the MovesAPI object), you'll need to include the ``MovesAPI.h``.  Simply add this line:

``#import "MovesAPI.h"``

###Step 1

In AppDelegate. Set Your **[Client ID]**, **[Client secret]** and **[Redirect URI]**.
```Objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"[YOUR Client ID]"
                                        oauthClientSecret:@"[YOUR Client secret]"
                                        callbackUrlScheme:@"[YOUR URL SCHEME]"];
    return YES;
}
```
###Step 2

Give the SDK an opportunity to handle incoming URLs. 
```Objc
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[MovesAPI sharedInstance] canHandleOpenUrl:url]) {
        return YES;
    }
    // Other 3rdParty Apps Handle Url Method...
    
    
    return NO;
}
```
#Authorization 
```Objc
[[MovesAPI sharedInstance] authorizationSuccess:^{
    // Auth successed! Now you can get Moves's data
} failure:^(NSError *reason) {
    // Auth failed!
}];
```
#Start get Moves's data
Get user profile
```Objc
[[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
    // Get user
} failure:^(NSError *error) {
    // Something wrong
}];
```
More other API see the ``MovesAPI.h`` file

#Acknowledgements
The **moves-ios-sdk** uses the following open source software:

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [Moves Official API Documents](https://dev.moves-app.com/)

#API Terms

[Moves API Terms](https://dev.moves-app.com/docs/terms_summary)

#License

See the [MIT license](https://github.com/vitoziv/moves-ios-sdk/blob/master/LICENSE).
