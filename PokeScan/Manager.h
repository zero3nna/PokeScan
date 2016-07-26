//
//  Manager.h
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Communicator.h"

@protocol ManagerDelegate;

@interface Manager : NSObject <CommunicatorDelegate>

@property (strong, nonatomic) Communicator *communicator;
@property (weak, nonatomic) id<ManagerDelegate> delegate;

- (void)fetchPokemons;
- (void)login;
- (void)setLocationLat:(float)latitude longitude:(float)longitude;

@end

@protocol ManagerDelegate <NSObject>

- (void)didReceivePokemons:(NSDictionary *)pokemons;
- (void)fetchingPokemonsFailedWithError:(NSError *)error;

- (void)didReceiveLogin:(NSNumber *)loginStatus;
- (void)loginFailedWithError:(NSError *)error;

@end
