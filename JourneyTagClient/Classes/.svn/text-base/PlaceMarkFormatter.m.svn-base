//
//  PlaceMarkFormatter.m
//  JourneyTag
//
//  Created by Ben Ford on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlaceMarkFormatter.h"


@implementation PlaceMarkFormatter

+ (NSString*)standardFormat:(MKPlacemark*)placemark
{
    NSString *first = [placemark.locality length] != 0 ? placemark.locality : placemark.subAdministrativeArea; 
    first = [first length] != 0 ? first : placemark.postalCode;
    NSString *info = [[NSString alloc] initWithFormat:@"%@, %@, %@",first, placemark.administrativeArea, placemark.country];
    return [info autorelease];
}
@end
