//
//  BuildPokemons.m
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import "BuildPokemons.h"
#import "Pokemons.h"

@implementation BuildPokemons

+ (NSDictionary *)dataFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSLog(@"ParsedObject: %@", parsedObject);
    
    NSDictionary *results = [parsedObject valueForKey:@"pokemons"];
    NSNumber *statusCode = [[NSNumber alloc] initWithInt:999];
    if (results.count == 0) {
        statusCode = [parsedObject valueForKey:@"status_code"];
        if ([statusCode integerValue] != 999) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Scanning failed with Status Code" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"/update/lat/long" code:[statusCode integerValue] userInfo:details];
            return nil;
        }
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"No Pokemon in this area" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"/update/lat/long" code:[statusCode integerValue] userInfo:details];
        return nil;
    }
    NSLog(@"Count %lu", (unsigned long)results.count);
    
    return results;
}

+ (NSNumber *)loginFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSLog(@"ParsedObject: %@", parsedObject);
    
    NSNumber *results = [parsedObject valueForKey:@"status_code"];
    
    if ([results integerValue] <= 0) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Login failed with Status Code" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"/login/lat/long" code:[results integerValue] userInfo:details];
        
        return nil;
    }
    
    return results;
}
@end
