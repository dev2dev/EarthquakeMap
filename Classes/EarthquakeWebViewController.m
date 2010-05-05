#import "EarthquakeWebViewController.h"


@implementation EarthquakeWebViewController

@synthesize magLabel, nameLabel, earthquake;

- (void) initWithEarthquake:(Earthquake *)sentEarthquake {
	self.earthquake = sentEarthquake;
	
	nameLabel.text = sentEarthquake.location;
	magLabel.text = [NSString stringWithFormat:@"%i", sentEarthquake.magnitude];
}

@end
