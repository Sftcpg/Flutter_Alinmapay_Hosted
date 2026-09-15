# flutter_alinmapay_hosted


This Flutter plugin provide merchants to easy and hasslefree integration with Merchant Payment gateway API's.

## Getting Started

Import the package to your pubspec.yaml to use it:

    ...
    dependencies:
    ...
    flutter_alinmapay_hosted: ^1.0.0

    ...
    ...

## Addition Configuration for performing transactions.

Configure Terminal Id, Terminal Password, Merchant key and URL into appconfig.json file. 
And place the file into application asset folder.

## Permission 
You need to put the following implementations in Android and iOS respectively.

Android
 
Required Permissions are:

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

iOS
    Add following code in your <project-directory>/ios/Runner/Info.plist
    
        <key>NSAppTransportSecurity</key>
        <dict>
        <key>NSAllowsArbitraryLoads</key> <true/>
        </dict>
        <key>io.flutter.embedded_views_preview</key> <true/> 