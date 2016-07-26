//
//  Communicator.m
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import "Communicator.h"

@implementation Communicator

- (void)searchPokemons
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://pgoapi.zero3nna.de/update/%f/%f", _latitude, _longitude];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    //NSLog(@"%@", urlAsString);
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error) {
              [self.delegate fetchingPokemonsFailedWithError:error];
          } else {
              [self.delegate receivedPokemonsJSON:data];
              //NSLog(@"Data: %@", data);
          }
      }] resume];
    
    /*NSString *fileName = [[NSBundle mainBundle] pathForResource:@"testdata" ofType:@"json"];
    
    if (fileName) {
        NSData *testData = [[NSData alloc] initWithContentsOfFile:fileName];
        
        [self.delegate receivedPokemonsJSON:testData];
    }*/
}

- (void)loginRequest {
    NSString *urlAsString = [NSString stringWithFormat:@"http://pgoapi.zero3nna.de/login/%f/%f", _latitude, _longitude];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error) {
              [self.delegate loginFailedWithError:error];
          } else {
              [self.delegate receivedLoginJSON:data];
          }
      }] resume];
}

- (void)setLocationLat:(float)latitude longitude:(float)longitude {
    _latitude = latitude;
    _longitude = longitude;
}

@end
