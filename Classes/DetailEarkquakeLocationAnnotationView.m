#import "DetailEarkquakeLocationAnnotationView.h"

@implementation DetailEarkquakeLocationAnnotationView

- (id)initWithAnnotation:(id )annotation reuseIdentifier:(NSString *)reuseIdentifier {
	
	MKPinAnnotationView *pinView = nil;
	
	if ( pinView == nil ) {
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	} else {
		pinView = annotation;
	}
	
	
	pinView.pinColor = MKPinAnnotationColorRed;
	pinView.canShowCallout = YES;
	pinView.animatesDrop = YES;
	
	
	[pinView setCanShowCallout:YES];
	[pinView setSelected:YES animated:YES];

	return pinView;
}

- (void) dealloc {
	[super dealloc];
}

@end
