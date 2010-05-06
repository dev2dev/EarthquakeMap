#import <UIKit/UIKit.h>
#import "Earthquake.h"


@interface EarthquakeWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UINavigationBar *toolbar;
	IBOutlet UIBarButtonItem *closeButton;
	Earthquake *earthquake;
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UINavigationBar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, retain) Earthquake *earthquake;

- (EarthquakeWebViewController*) initWithEarthquake:(Earthquake *)sentEarthquake;
- (IBAction) closeWindow: (id) sender;
- (void) setLabels;

@end
