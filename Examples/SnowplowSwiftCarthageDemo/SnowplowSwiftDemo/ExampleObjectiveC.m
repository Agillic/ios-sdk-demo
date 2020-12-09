//
//  TestObjectiveC.m
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 01/12/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgillicSDK/AgillicSDK-Swift.h>


void agillicTrackingExample() {
    MobileSDK *sdk = [[MobileSDK alloc] init];
    AgillicTracker *tracker = [sdk registerWithClientAppId:@"aClientAppID" clientAppVersion:@"1.0" solutionId:@"encodedSolutionId" userID:@"dennis.schafroth@agillic.com" pushNotificationToken:nil completionHandler: nil];
    // On each application view to track:
    // the AppViewEvent can be created once
    // UUID should be constant for the application over restart, but is not exposed in Agillic Tracking.
    // screen name is the value that is used in Agillic Condition Editor.
    NSUUID *uuid = [[ NSUUID alloc] init];
    AppViewEvent *event = [[AppViewEvent alloc] init: [uuid UUIDString] screenName:@"ios_protocol://iosapp/metrics/2" type:nil previousScreenId:nil];
    [tracker track:event];
}

