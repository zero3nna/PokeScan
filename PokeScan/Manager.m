//
//  Manager.m
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import "Manager.h"
#import "BuildPokemons.h"

@implementation Manager

- (void)fetchPokemons
{
    [self.communicator searchPokemons];
}

- (void)login {
    [self.communicator loginRequest];
}

- (void)setLocationLat:(float)latitude longitude:(float)longitude {
    [self.communicator setLocationLat:latitude longitude:longitude];
}

#pragma mark - CommunicatorDelegate


- (void)receivedPokemonsJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSDictionary *pokemons = [BuildPokemons dataFromJSON:objectNotation error:&error];
    
    [self.delegate didReceivePokemons:pokemons];
}

- (void)fetchingPokemonsFailedWithError:(NSError *)error {
    [self.delegate fetchingPokemonsFailedWithError:error];
}

- (void)receivedLoginJSON:(NSData *)objectNotation {
    NSError *error = nil;
    NSNumber *loginCode = [BuildPokemons loginFromJSON:objectNotation error:&error];
    
    [self.delegate didReceiveLogin:loginCode];
}

- (void)loginFailedWithError:(NSError *)error {
    [self.delegate loginFailedWithError:error];
}

@end
