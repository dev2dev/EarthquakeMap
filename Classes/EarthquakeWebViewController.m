#import "EarthquakeWebViewController.h"


@implementation EarthquakeWebViewController

@synthesize magLabel, nameLabel, earthquake, toolbar;

- (EarthquakeWebViewController*) initWithEarthquake:(Earthquake *)sentEarthquake {
	self.earthquake = sentEarthquake;
	return self;
}

- (void) setLabels {
	[nameLabel setText:earthquake.location];
	[magLabel setText:[NSString stringWithFormat:@"%.1f", earthquake.magnitude]];
}

@end
