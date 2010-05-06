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
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,200,30)];
	titleLabel.text = earthquake.location;
	titleLabel.backgroundColor = [UIColor clearColor];
	UINavigationItem *navItem = [UINavigationItem alloc];
	navItem.titleView = titleLabel;
	
	closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:@selector(closeWindow:)];
	navItem.rightBarButtonItem = closeButton;
	
	[toolbar pushNavigationItem:navItem animated:NO];
	[toolbar setDelegate:self];
	[navItem release];
	[titleLabel release];
	
}

@end
