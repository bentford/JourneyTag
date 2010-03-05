//
//  JTImageView.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTImageView.h"


@implementation JTImageView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushTagDetails" object:self];
}

- (void)dealloc {
    [super dealloc];
}


@end
