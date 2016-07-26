//
//  Communicator.h
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommunicatorDelegate;

@interface Communicator : NSObject

@property (weak, nonatomic) id<CommunicatorDelegate> delegate;

@property (nonatomic, readonly) float latitude;
@property (nonatomic, readonly) float longitude;

- (void)searchPokemons;
- (void)loginRequest;
- (void)setLocationLat:(float)latitude longitude:(float)longitude;

@end

@protocol CommunicatorDelegate <NSObject>

- (void)receivedPokemonsJSON:(NSData *)objectNotation;
- (void)fetchingPokemonsFailedWithError:(NSError *)error;
- (void)receivedLoginJSON:(NSData *)objectNotation;
- (void)loginFailedWithError:(NSError *)error;

@end