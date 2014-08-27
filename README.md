moves-ios-sdk
=============
[Moves App](http://moves-app.com) SDK For iOS. 

![Moves App Integration](https://apps.moves-app.com/assets/images/moves-connected-apps-logo-2.png)

#Getting Started

##Installing the moves-ios-sdk

**Use CocoaPods**

- Add the ``pod 'moves-ios-sdk', '~> 0.2.3'`` pod to your **Podfile**. 
- Run ``pod install``, and the Moves SDK will be available in your project.

**Manully way, add the moves-ios-sdk to your project**

- Open your existing project.
- Drag the **moves-ios-sdk** folder from the example project into your Xcode project.
- Make sure the “Copy items into destination group’s folder (if needed)” checkbox is checked.

##Get ClientId and ClientSecret
When you register your app with Moves, it will provide you with a **Client ID** and **Client secret**. They identify your app to Moves's API. 

[Register your app with Moves](https://dev.moves-app.com/apps)

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
**[YOUR URL SCHEME]** is setted when you [Register your app with Moves](https://dev.moves-app.com/apps)

**Important:** When configure your app [here](https://dev.moves-app.com/apps) you need to set the `Redirect URI` to: `[YOUR URL SCHEME]://authorization-completed` 

##Configure your App Delegate

At the top of your app delegate source file (and anywhere you call the MovesAPI object), you'll need to include the ``MovesAPI.h``.  Simply add this line:

``#import "MovesAPI.h"``

###Step 1

In AppDelegate. Set Your **[Client ID]**, **[Client Secret]** and **[Redirect URI]**.
```Objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"[YOUR CLIENT ID]"
                                        oauthClientSecret:@"[YOUR CLIENT SECRET]"
                                        callbackUrlScheme:@"[YOUR URL SCHEME]"];
    return YES;
}
```
###Step 2

Give the SDK an opportunity to handle incoming URLs. 
```Objc
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation 
{
    if ([[MovesAPI sharedInstance] canHandleOpenUrl:url]) {
        return YES;
    }
    // Other 3rdParty Apps Handle Url Method...
    
    
    return NO;
}
```
#Authorization 
```Objc
[[MovesAPI sharedInstance] authorizationWithViewController:self
                                                       success:^{
                                                           // Auth successed! Now you can get Moves's data
                                                       } failure:^(NSError *error) {
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

#Unit Test

You can clone this repo, and test the API.

1. Firstly, you need run the demo app, and authenticate it.
2. `pod install`
3. `command` + `U`


#Acknowledgements

- [Moves Official API Documents](https://dev.moves-app.com/)

#API Terms

[Moves API Terms](https://dev.moves-app.com/docs/terms_summary)

#License

See the [MIT license](https://github.com/vitoziv/moves-ios-sdk/blob/master/LICENSE).
