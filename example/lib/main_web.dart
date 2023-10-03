import 'package:flutter/material.dart';
import 'dart:html';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

var offLine = false;
var optOut = false;

const htmlData = "<div><button id='inbox'>Inbox</button></div>";
void main() {
  runApp(MaterialApp(
      // Title
      title: "Using Gradient",
      // Home
      home: Scaffold(
          // Appbar
          appBar: AppBar(
            // Title
            title: Text("Hello World"),
          ),
          // Body
          body: ListView(
            children: <Widget>[
              TextButton(
                child: Text(
                  "Init",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  print("on init tap");
                  if (kIsWeb) {
                    print("on web init");
                    CleverTapPlugin.init(
                        "WRK-485-456Z", "sk1-staging-4", "wzrkt.com");
                    CleverTapPlugin.setDebugLevel(3);
                  }
                },
              ),
              TextButton(
                child: Text(
                  "Push Event",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  print("on event tap");
                  if (kIsWeb) {
                    print("on web event puch");
                    CleverTapPlugin.recordEvent("Amee", {});
                  }
                },
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set Debug Level"),
                    subtitle: Text(
                        "Sets the debug level in Android/iOS to show console logs"),
                    onTap: () {
                      CleverTapPlugin.setDebugLevel(3);
                    },
                    trailing: Icon(Icons.info),
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Get CleverTap ID"),
                    subtitle: Text("Returns Clevertap ID"),
                    onTap: getCleverTapId,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Get Account ID"),
                    subtitle: Text("Returns Account ID"),
                    onTap: getAccountId,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set Offline"),
                    subtitle: Text("Switches CleverTap to offline mode"),
                    onTap: setOffline,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Performs onUserLogin"),
                    subtitle: Text("Used to identify multiple profiles"),
                    onTap: onUserLogin,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Push User"),
                    subtitle: Text("Pushes/Records a user"),
                    onTap: recordUser,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set Profile Multi Values"),
                    subtitle: Text("Sets a multi valued user property"),
                    onTap: setProfileMultiValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Add Profile Multi Value"),
                    subtitle: Text("Add user property"),
                    onTap: addMultiValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Add Profile Multi values"),
                    subtitle: Text("Add a multi valued user property"),
                    onTap: addMultiValues,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Remove Multi Value"),
                    subtitle: Text("Remove user property"),
                    onTap: removeMultiValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Remove Multi Values"),
                    subtitle: Text("Remove a multi valued user property"),
                    onTap: removeMultiValues,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Remove Profile Value For Key"),
                    subtitle: Text("Removes user property of given key"),
                    onTap: removeProfileValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Profile increment value"),
                    subtitle: Text("Increment value by 15"),
                    onTap: incrementValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Profile decrement value"),
                    subtitle: Text("Decrement value by 10"),
                    onTap: decrementValue,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set Location"),
                    subtitle: Text("Use to set Location of a user"),
                    onTap: setLocation,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set Opt Out"),
                    subtitle:
                        Text("Used to opt out of sending data to CleverTap"),
                    onTap: setOptOut,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Set UseIP"),
                    subtitle: Text(
                        "Used to ensure that the CleverTap does not auto collect the device IP"),
                    onTap: setUseIP,
                  ),
                ),
              ),
              Card(
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text("Render Notification Viewed"),
                    subtitle:
                        Text("Used to render the notification viewed event"),
                    onTap: renderViewedEvent,
                  ),
                ),
              )
            ],
          ))));
}

void getCleverTapId() {
  CleverTapPlugin.getCleverTapID().then((clevertapId) {
    print("$clevertapId");
  }).catchError((error) {
    print("$error");
  });
}

void getAccountId() {
  CleverTapPlugin.getAccountID().then((accountId) {
    print("$accountId");
  }).catchError((error) {
    print("$error");
  });
}

void setOffline() {
  if (offLine) {
    CleverTapPlugin.setOffline(false);
    offLine = false;
    print("You are online");
  } else {
    CleverTapPlugin.setOffline(true);
    offLine = true;
    print("You are offline");
  }
}

void setProfileMultiValue() {
  var values = ["bag", "shoes"];
  CleverTapPlugin.profileSetMultiValues("stuff", values);
  print("check console for details");
}

void addMultiValue() {
  var value = "jacket";
  CleverTapPlugin.profileAddMultiValue("stuff", value);
  print("check console for details");
}

void addMultiValues() {
  var values = ["cap", "wallet"];
  CleverTapPlugin.profileAddMultiValues("stuff", values);
  print("check console for details");
}

void removeMultiValue() {
  var value = "jacket";
  CleverTapPlugin.profileRemoveMultiValue("stuff", value);
  print("check console for details");
}

void removeMultiValues() {
  var values = ["cap", "bag"];
  CleverTapPlugin.profileRemoveMultiValues("stuff", values);
  print("check console for details");
}

void removeProfileValue() {
  CleverTapPlugin.profileRemoveValueForKey("stuff");
  print("check console for details");
}

void incrementValue() {
  var value = 15;
  CleverTapPlugin.profileIncrementValue("score", value);
  print("check console for details");
}

void decrementValue() {
  var value = 10;
  CleverTapPlugin.profileDecrementValue("score", value);
  print("check console for details");
}

void setLocation() {
  var lat = 19.07;
  var long = 72.87;
  CleverTapPlugin.setLocation(lat, long);
  print("Location is set");
}

void setOptOut() {
  if (optOut) {
    CleverTapPlugin.setOptOut(false);
    optOut = false;
    print("You have opted in");
  } else {
    CleverTapPlugin.setOptOut(true);
    optOut = true;
    print("You have opted out");
  }
}

void setUseIP() {
  CleverTapPlugin.setOptOut(false);
  print("UseIP set to false");
}

void onUserLogin() {
  var profile = {
    'Name': 'Captain America',
    'Identity': '100',
    'Email': 'captain@america.com',
    'Phone': '+14155551234'
  };
  CleverTapPlugin.onUserLogin(profile);
  print("onUserLogin called, check console for details");
}

void recordUser() {
  var profile = {
    'Name': 'Sonam',
    'Identity': '100',
    'Email': 'johndoe0@gmail.com',
  };
  CleverTapPlugin.profileSet(profile);
  print("Pushed profile");
}

void renderViewedEvent() {
  var customNotificationPayload = {
    'msgId': '1696324910_20231003', // required
    'pivotId': 'wzrk_default',
  };
  CleverTapPlugin.renderNotificationViewed(customNotificationPayload);
}
