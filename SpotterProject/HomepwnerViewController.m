//
//  HomepwnerViewController.m
//  SpotterProject
//
//  Created by Earl St Sauver on 9/17/12.
//  Copyright (c) 2012 Earl St Sauver. All rights reserved.
//

#import "HomepwnerViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
@interface HomepwnerViewController ()

@end

@implementation HomepwnerViewController

- (void)viewDidLoad
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(newStatus:) name:@"StatusUpload" object:nil];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"/cardboard.png"]];
    
    // Create location manager object
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    [locationManager setDelegate:self];
    // We want all results from the location manager
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    // And we want it to be as accurate as possible
    // regardless of how much time/power it takes
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        [locationManager startUpdatingLocation];
        lastReachabilityStatus = [NSNumber numberWithInt:1];
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        [locationManager startUpdatingLocation];
        lastReachabilityStatus = [NSNumber numberWithInt:0];
    };
    
    // start the notifier which will cause the reachability object to retain itself!
    [reach startNotifier];
    
    [super viewDidLoad];
  
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)newStatus:(NSNotification *)note
{
    id poster =[note object];
    NSString *name = [note name];
    NSDictionary *extraInformation = [note userInfo];
    NSNumber *latiude = [extraInformation objectForKey:@"latitude"];
    NSNumber *longitude = [extraInformation objectForKey:@"longitude"];
    NSDate *eventTime = [extraInformation objectForKey:@"timestamp"];
    //Need to make coordinate from the status
    CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake([latiude doubleValue], [longitude doubleValue]);
    
    [latitudeLabel setText:[NSString stringWithFormat:@"%@", latiude]];
    [longitudeLabel setText:[NSString stringWithFormat:@"%@", longitude]];
    [timestampLabel setText:[NSString stringWithFormat:@"%@", eventTime]];

    NSNumber * totalPoints = [[PFUser currentUser] objectForKey:@"TotalPoints"];
    [numberOfPoints setText:[NSString stringWithFormat:@"You submitted %d points", [totalPoints integerValue]]];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(lastCoordinate, 500, 500);
    [lastNetwork setRegion:region animated:YES];
     
    
}
-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    NSNotificationCenter *nc  = [NSNotificationCenter defaultCenter];
    CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *mnc = [carrier mobileNetworkCode];

    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 1.0)
    {
        PFObject * status = [PFObject objectWithClassName:@"ReachabilityStatus"];
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        [status setObject:point forKey:@"location"];
        [status setObject:lastReachabilityStatus forKey:@"ReachableBool"];
        [status setObject:[carrier carrierName] forKey:@"HomeCarrier"];
        [status setObject:mnc forKey:@"MobileNetworkCode"];
        [status setObject:[PFUser currentUser] forKey:@"user"];
        [[PFUser currentUser] incrementKey:@"TotalPoints"];
        [status saveEventually];
        
        NSArray *dictionaryObjects = [NSArray arrayWithObjects:[NSNumber numberWithDouble:newLocation.coordinate.latitude],
                                      [NSNumber numberWithDouble:newLocation.coordinate.longitude],
                                      newLocation.timestamp,
                                      nil];
        NSArray *dictionaryKeys = [NSArray arrayWithObjects:@"latitude", @"longitude",@"timestamp", nil];
        NSDictionary *locationInfo= [NSDictionary dictionaryWithObjects:dictionaryObjects forKeys:dictionaryKeys];
        NSNotification *note = [NSNotification notificationWithName:@"StatusUpload" object:self userInfo:locationInfo];
        [[PFUser currentUser] saveEventually];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        [manager stopUpdatingLocation];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
