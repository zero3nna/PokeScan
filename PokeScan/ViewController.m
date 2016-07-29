//
//  ViewController.m
//  PokeScan
//
//  Created by Ralph Schön on 22.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import "ViewController.h"
#import "Manager.h"
#import "Pokemons.h"
#import "Communicator.h"
#import "PokeAnnotation.h"
#import "Pokedex.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController () <ManagerDelegate> {
    NSDictionary *_pokemons;
    Manager *_manager;
    float currentLatitude;
    float currentLongitude;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    _manager = [[Manager alloc] init];
    _manager.communicator = [[Communicator alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [_scanButton addTarget:self action:@selector(scanForPokemon) forControlEvents:UIControlEventTouchUpInside];
    [_currentLocation addTarget:self action:@selector(resetCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    
    currentLatitude = 0.0;
    currentLongitude = 0.0;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //NSLog(@"%@", [locations lastObject]);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    currentLatitude = userLocation.coordinate.latitude;
    currentLongitude = userLocation.coordinate.longitude;
}

-(void)scanForPokemon {
    NSLog(@"Trying to scan pokemon");
    [_mapView removeAnnotations:_mapView.annotations];
    if (currentLatitude != 0.0 && currentLongitude != 0.0) {
        NSLog(@"checking login");
        [_scanButton setUserInteractionEnabled:NO];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setForegroundColor:[UIColor colorWithRed:255.0f/255.0f green:183.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:0.6]];
        [SVProgressHUD setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [SVProgressHUD setRingThickness:4.0f];
        [SVProgressHUD setRingRadius:20.0f];
        [SVProgressHUD showWithStatus:@"Scanning Environment"];
        
        [_manager setLocationLat:currentLatitude longitude:currentLongitude];
        [_manager login];
    } else {
        NSLog(@"No GPS Position");
    }
}

- (void)resetCurrentLocation {
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow];
}

-(void)createPokeAnnotations:(NSDictionary *)pokemons {
    NSMutableArray *pokeData = [[NSMutableArray alloc] init];
    for (NSString *key in pokemons) {
        NSArray *data = [pokemons valueForKey:key];
        
        [pokeData addObject:data];
        NSLog(@"PokeData: %@", pokeData);
    }
    Pokedex *pokedex = [[Pokedex alloc] init];
    for (NSDictionary *pokemon in pokeData) {
        
        CLLocationCoordinate2D pokemonLocationCoordinate = CLLocationCoordinate2DMake([[pokemon valueForKey:@"latitude"] floatValue], [[pokemon valueForKey:@"longitude"] floatValue]);
        //NSLog(@"Location: %f , %f", pokemonLocationCoordinate.latitude, pokemonLocationCoordinate.longitude);
        NSUInteger pokemonID = [[[pokemon valueForKey:@"pokemon_data"] valueForKey:@"pokemon_id"] integerValue];
        NSArray *pokedexData = [pokedex.pokedexList objectAtIndex:pokemonID];
        
        NSTimeInterval timestamp = (NSTimeInterval)[[pokemon valueForKey:@"hides_at"] doubleValue];
        NSDate *timeTillHidden = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setLocale:[NSLocale currentLocale]];
        [dateformatter setDateFormat:@"HH:mm"];
        NSString *dateString=[dateformatter stringFromDate:timeTillHidden];
        
        PokeAnnotation *myAnnotation = [[PokeAnnotation alloc] initWithTitle:[pokedexData objectAtIndex:0] location:pokemonLocationCoordinate];
        myAnnotation.subtitle = [NSString stringWithFormat:@"Hides at: %@", dateString];
        NSString *imageName = [NSString stringWithFormat:@"p%lu", (unsigned long)pokemonID];
        NSLog(@"Image Name: %@", imageName);
        myAnnotation.imageName = imageName;
        
        
        dispatch_async (dispatch_get_main_queue(), ^
        {
            [_mapView addAnnotation:myAnnotation];
        });
    }
    
    [_scanButton setUserInteractionEnabled:YES];
    [SVProgressHUD dismiss];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"myAnnotation";
    MKAnnotationView * annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
        annotationView.enabled = YES;
    }else {
        annotationView.annotation = annotation;
    }
    
    //update the image in the view whether it's a new OR dequeued view...
    if ([annotation isKindOfClass:[PokeAnnotation class]])
    {
        PokeAnnotation *pokeAnnotation = (PokeAnnotation *)annotation;
        
        UIImage *img = [UIImage imageNamed:pokeAnnotation.imageName];
        UIImage *scaledImage = [UIImage imageWithCGImage:[img CGImage] scale:(img.scale * 1.5) orientation:(img.imageOrientation)];
        [annotationView setImage:scaledImage];
        
        /*UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        calloutView.backgroundColor = [UIColor greenColor];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:calloutView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
        [calloutView addConstraint:widthConstraint];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:calloutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20];
        [calloutView addConstraint:heightConstraint];
        
        annotationView.detailCalloutAccessoryView = calloutView;*/
    }
    
    return annotationView;
}

- (void)didReceivePokemons:(NSDictionary *)pokemons {
    NSLog(@"You have following Pokemons nearby: %@", pokemons);
    [self createPokeAnnotations:pokemons];
}


- (void)fetchingPokemonsFailedWithError:(NSError *)error {
    
    [_scanButton setUserInteractionEnabled:YES];
    [SVProgressHUD dismiss];
    
    NSString *title = [[NSString alloc] init];
    NSString *msg = [[NSString alloc] init];
    if ([[error localizedDescription] isEqualToString:@"No Pokemon in this area"]) {
        title = [error localizedDescription];
        msg = @"Please change your location.";
    } else {
        title = [error localizedDescription];
        msg = [NSString stringWithFormat:@"Scanning failed with Status Code: %@", [error userInfo]];
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:msg
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Login", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if (![[error localizedDescription] isEqualToString:@"No Pokemon in this area"]) {
                                       if (currentLatitude != 0.0 && currentLongitude != 0.0) {
                                           [_manager setLocationLat:currentLatitude longitude:currentLongitude];
                                           [_manager login];
                                       
                                       } else {
                                           NSLog(@"No GPS Position");
                                       }
                                   }
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveLogin:(NSNumber *)loginStatus {
    NSLog(@"Login with Status: %@", loginStatus);
    NSLog(@"fetching pokemon");
    [_manager fetchPokemons];
}

- (void)loginFailedWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[error localizedDescription]
                                          message:[NSString stringWithFormat:@"Login failed with Status Code: %@", [error userInfo]]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //NSLog(@"OK action");
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
