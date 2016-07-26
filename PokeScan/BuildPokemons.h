//
//  BuildPokemons.h
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildPokemons : NSObject

+ (NSDictionary *)dataFromJSON:(NSData *)objectNotation error:(NSError **)error;
+ (NSNumber *)loginFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
