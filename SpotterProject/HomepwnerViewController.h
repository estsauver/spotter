//
//  HomepwnerViewController.h
//  SpotterProject
//
//  Created by Earl St Sauver on 9/17/12.
//  Copyright (c) 2012 Earl St Sauver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HomepwnerViewController : UIViewController <CLLocationManagerDelegate>
{
    IBOutlet UILabel *latitudeLabel;
    IBOutlet UILabel *longitudeLabel;
    IBOutlet UILabel *timestampLabel;
    IBOutlet UILabel *numberOfPoints;
    IBOutlet MKMapView *lastNetwork;
    NSNumber *lastReachabilityStatus;
}
@property (nonatomic, unsafe_unretained) bool executingInBackground;

-(IBAction)launchFeedback:(id)sender;
@end
