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
#import "MKPolygon+PolygonTag.h"

@interface ViewController ()

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *overlayArray;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation ViewController

- (NSMutableArray *)overlayArray {
    if(_overlayArray == nil) {
        _overlayArray = [[NSMutableArray alloc] init];
    }
    return _overlayArray;
}

- (NSMutableArray *)colorArray {
    if(_colorArray == nil) {
        _colorArray = [[NSMutableArray alloc] init];
    }
    return _colorArray;
}

- (NSMutableArray *)titleArray {
    if(_titleArray == nil) {
        _titleArray = [[NSMutableArray alloc] init];
    }
    return _titleArray;
}

- (MKMapView *)mapView {
    if(_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mapView.delegate = self;
        
        /* tap gesture */
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [_mapView addGestureRecognizer:tapRecognizer];
    }
    return _mapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.mapView];
    
    /* add overlay to array */
    [self.overlayArray addObject:[self getOverlayPolygonFromKMLFileWithName:@"C13" andTag:0]];
    [self.overlayArray addObject:[self getOverlayPolygonFromKMLFileWithName:@"C1" andTag:1]];
    
    /* add colors to array */
    [self.colorArray addObject:[UIColor blackColor]];
    [self.colorArray addObject:[UIColor blueColor]];
    
    /* add title to array */
    [self.titleArray addObject:@"C13"];
    [self.titleArray addObject:@"C1"];
    
    /* add overlays form array on map */
    for(MKPolygon *overlayPolygon in self.overlayArray) {
        [self.mapView addOverlay:overlayPolygon];
    }
}

- (MKPolygon *)getOverlayPolygonFromKMLFileWithName:(NSString *)name andTag:(int)tag {
    
    MKPolygon *overlayPolygon = nil;
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"kml"] error:NULL];
    if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
    {
        for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features)
        {
            if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).polygon)
            {
                SimpleKMLPolygon *polygon = (SimpleKMLPolygon *)((SimpleKMLPlacemark *)feature).polygon;
                SimpleKMLLinearRing *outerRing = polygon.outerBoundary;
                CLLocationCoordinate2D points[[outerRing.coordinates count]];
                NSUInteger i = 0;
                
                for (CLLocation *coordinate in outerRing.coordinates)
                    points[i++] = coordinate.coordinate;
                overlayPolygon = [MKPolygon polygonWithCoordinates:points count:[outerRing.coordinates count]];
                overlayPolygon.tag = tag;
                [self.mapView setVisibleMapRect:overlayPolygon.boundingMapRect animated:YES];
            }
        }
    }
    return overlayPolygon;
}

-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    [self.mapView removeAnnotations:self.mapView.annotations];
    /* check status for each overlay in array */
    for(MKPolygon *overlayPolygon in self.overlayArray) {
        if([self isPoint:tapPoint insidePolygonOverlay:overlayPolygon]) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = tapPoint;
            annotation.title      = [self.titleArray objectAtIndex:overlayPolygon.tag];
            [self.mapView addAnnotation:annotation];
        }
    }
}

-(BOOL)isPoint:(CLLocationCoordinate2D )tapPoint insidePolygonOverlay:(MKPolygon *)overlayPolygon
{
    MKPolygonView *polygonView = (MKPolygonView *)[self.mapView viewForOverlay:overlayPolygon];
    MKMapPoint mapPoint = MKMapPointForCoordinate(tapPoint);
    CGPoint polygonViewPoint = [polygonView pointForMapPoint:mapPoint];
    BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polygonView.path, NULL, polygonViewPoint, NO);
    if (mapCoordinateIsInPolygon) {
        return YES;
    }
    return NO;
}

#pragma mark -

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    //
    MKPolygon *polygon = (MKPolygon *)overlay;
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
    
    // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
    //
    polygonView.fillColor   = [self.colorArray objectAtIndex:polygon.tag];
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
    
    polygonView.lineWidth = 2.0;
    
    return polygonView;
}


- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point type:(int)state
{
    return nil;
}
@end
