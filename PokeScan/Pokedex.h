//
//  Pokedex.h
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pokedex : NSObject
@property (nonatomic, strong) NSArray *pokedexList;

- (instancetype)init;
@end
