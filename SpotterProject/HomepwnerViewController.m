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
#import "TestFlight.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@implementation HomepwnerViewController
@synthesize executingInBackground;


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
    [locationManager startUpdatingLocation];
    
    // start the notifier which will cause the reachability object to retain itself!
    
    [super viewDidLoad];
    executingInBackground = YES;
    lastReachabilityStatus = [[NSNumber alloc] initWithInt:0];

  
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
    [numberOfPoints setText:[NSString stringWithFormat:@"%d network drops", [totalPoints integerValue]]];
        
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init] ;
    annotation.coordinate = lastCoordinate;
    //MKPinAnnotationView *annotation = [[MKPinAnnotationView alloc] init];
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(lastCoordinate, 500, 500);
    [lastNetwork setRegion:region animated:YES];
    [lastNetwork addAnnotation:annotation];

     
    
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    //if (executingInBackground){
    Reachability *reach =[Reachability reachabilityForLocalWiFi];
    [reach startNotifier];
    NSNumber *reachabilityStatus = [NSNumber numberWithInt:[reach currentReachabilityStatus]];
    
    if (reachabilityStatus != lastReachabilityStatus){

        if (newLocation.horizontalAccuracy < 20)
        {
            CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
            CTCarrier *carrier = [networkInfo subscriberCellularProvider];
            PFObject * status = [PFObject objectWithClassName:@"ReachabilityStatus"];
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            [status setObject:point forKey:@"location"];
            [status setObject:[NSNumber numberWithDouble:newLocation.horizontalAccuracy] forKey:@"HorizontalAccuracy"];
            [status setObject:[NSNumber numberWithInt:reachabilityStatus] forKey:@"ReachabilityStatus"];/*
            [status setObject:[carrier carrierName] forKey:@"HomeCarrier"];
            [status setObject:[carrier mobileNetworkCode] forKey:@"MobileNetworkCode"];
                                                                               */
            [status setObject:[PFUser currentUser] forKey:@"user"];
            //[[PFUser currentUser] incrementKey:@"TotalPoints"];
            [status saveEventually];
            if (executingInBackground){
                NSArray *dictionaryObjects = [NSArray arrayWithObjects:[NSNumber numberWithDouble:newLocation.coordinate.latitude],
                                              [NSNumber numberWithDouble:newLocation.coordinate.longitude],
                                              newLocation.timestamp,
                                              nil];
                NSArray *dictionaryKeys = [NSArray arrayWithObjects:@"latitude", @"longitude",@"timestamp", nil];
                NSDictionary *locationInfo= [NSDictionary dictionaryWithObjects:dictionaryObjects forKeys:dictionaryKeys];
                NSNotification *note = [NSNotification notificationWithName:@"StatusUpload" object:self userInfo:locationInfo];
                [[PFUser currentUser] saveEventually];
                [[NSNotificationCenter defaultCenter] postNotification:note];
            }
        }
    }
    lastReachabilityStatus = reachabilityStatus;
    [reach stopNotifier];
}

-(IBAction)launchFeedback:(id)sender
{   
    [TestFlight openFeedbackView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
