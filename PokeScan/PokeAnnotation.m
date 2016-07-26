//
//  PokeAnnotation.m
//  PokeScan
//
//  Created by Ralph Schön on 24.07.16.
//  Copyright © 2016 Ralph Schön. All rights reserved.
//

#import "PokeAnnotation.h"

@implementation PokeAnnotation

- (id)initWithTitle:(NSString *)newTitle location:(CLLocationCoordinate2D)location{
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _subtitle = @"";
        _coordinate = location;
    }
    
    return self;
}


@end
