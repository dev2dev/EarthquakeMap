#import "EarthquakeWebViewController.h"


@implementation EarthquakeWebViewController

@synthesize earthquake, toolbar, closeButton, webView;

- (EarthquakeWebViewController*) initWithEarthquake:(Earthquake *)sentEarthquake {
	self.earthquake = sentEarthquake;
	return self;
}

- (IBAction) closeWindow: (id) sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) setLabels {
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:earthquake.USGSWebLink]]];
}

@end
