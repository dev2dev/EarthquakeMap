#import <UIKit/UIKit.h>
#import "Earthquake.h"


@interface EarthquakeWebViewController : UIViewController {
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *magLabel;
	IBOutlet UIToolbar *toolbar;
	
	Earthquake *earthquake;
	
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *magLabel;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) Earthquake *earthquake;

- (EarthquakeWebViewController*) initWithEarthquake:(Earthquake *)sentEarthquake;
- (void) setLabels;

@end
