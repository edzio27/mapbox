//
//  MKPolygon+PolygonTag.m
//  MapBoxLayerExample
//
//  Created by Edzio27 Edzio27 on 18.04.2013.
//  Copyright (c) 2013 Edzio27 Edzio27. All rights reserved.
//

#import "MKPolygon+PolygonTag.h"

@interface MKPolygon ()

@end

@implementation MKPolygon (PolygonTag)

static char tagKey;

- (void) setTag:(int)tag {
    objc_setAssociatedObject( self, &tagKey, [NSNumber numberWithInt:tag], OBJC_NEW_PROPERTIES );
}

- (int) tag {
    return (int)[objc_getAssociatedObject( self, &tagKey ) intValue];
}

@end
