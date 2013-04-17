//
//  ViewController.m
//  MapBoxLayerExample
//
//  Created by Edzio27 Edzio27 on 17.04.2013.
//  Copyright (c) 2013 Edzio27 Edzio27. All rights reserved.
//

#import "ViewController.h"
#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup the map view
    //
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView.delegate = self;
    
    [self.view addSubview:mapView];
    
    // grab the example KML file (which we know will have no errors, but you should ordinarily check)
    //
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"C13" ofType:@"kml"] error:NULL];
    
    // look for a document feature in it per the KML spec
    //
    if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
    {
        // see if the document has features of its own
        //
        for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features)
        {
            // see if we have any placemark features with a point
            //
            if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).point)
            {
                SimpleKMLPoint *point = ((SimpleKMLPlacemark *)feature).point;
                
                // create a normal point annotation for it
                //
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                
                annotation.coordinate = point.coordinate;
                annotation.title      = feature.name;
                
                [mapView addAnnotation:annotation];
            }
            
            // otherwise, see if we have any placemark features with a polygon
            //
            else if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).polygon)
            {
                SimpleKMLPolygon *polygon = (SimpleKMLPolygon *)((SimpleKMLPlacemark *)feature).polygon;
                
                SimpleKMLLinearRing *outerRing = polygon.outerBoundary;
                
                CLLocationCoordinate2D points[[outerRing.coordinates count]];
                NSUInteger i = 0;
                
                for (CLLocation *coordinate in outerRing.coordinates)
                    points[i++] = coordinate.coordinate;
                
                // create a polygon annotation for it
                //
                MKPolygon *overlayPolygon = [MKPolygon polygonWithCoordinates:points count:[outerRing.coordinates count]];
                
                [mapView addOverlay:overlayPolygon];
                
                // zoom the map to the polygon bounds
                //
                [mapView setVisibleMapRect:overlayPolygon.boundingMapRect animated:YES];
            }
        }
    }
}

#pragma mark -

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    //
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
    
    // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
    //
    polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
    
    polygonView.lineWidth = 2.0;
    
    return polygonView;
}


@end
