#import <UIKit/UIKit.h>
#import "Earthquake.h"


@interface EarthquakeWebViewController : UIViewController {
	UILabel *nameLabel;
	UILabel *magLabel;
	
	Earthquake *earthquake;
	
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *magLabel;
@property (nonatomic, retain) Earthquake *earthquake;

- (void) initWithEarthquake: (Earthquake *) earthquake;

@end
