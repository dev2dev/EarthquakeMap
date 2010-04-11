//
//  EQMapAppDelegate.m
//  EQMap
//
//  Created by Matt Christiansen on 4/10/10.
//  Copyright Cal Poly Pomona 2010. All rights reserved.
//

#import "EQMapAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"

#import "Earthquake.h"

#import <CFNetwork/CFNetwork.h>


@implementation EQMapAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

@synthesize earthquakeList;
@synthesize earthquakeFeedConnection;
@synthesize earthquakeData;
@synthesize currentEarthquakeObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSLog(@"at applicationDidFinshishLaunching");
	
	[window addSubview:splitViewController.view];
//	[window makeKeyAndVisible];
	
    // Initialize the array of earthquakes and pass a reference to that list to the Root view controller.
    self.earthquakeList = [NSMutableArray array];
    rootViewController.earthquakeList = earthquakeList;
    // Add the navigation view controller to the window.
    //[window addSubview:navigationController.view];
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the
    // application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked! Also, avoid synchronous network access on any thread.
    //
	NSLog(@"loading data");
    static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
    NSURLRequest *earthquakeURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.earthquakeFeedConnection = [[[NSURLConnection alloc] initWithRequest:earthquakeURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed
    // URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should
    // implement a more flexible validation technique, and be able to both recover from errors and communicate problems
    // to the user in an unobtrusive manner.
    NSAssert(self.earthquakeFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}

#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.earthquakeData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [earthquakeData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error",                             @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
    self.earthquakeFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.earthquakeFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    [NSThread detachNewThreadSelector:@selector(parseEarthquakeData:) toTarget:self withObject:earthquakeData];
    self.earthquakeData = nil;
}

- (void)parseEarthquakeData:(NSData *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }
    self.currentParseBatch = nil;
    self.currentEarthquakeObject = nil;
    self.currentParsedCharacterData = nil;
    [parser release];        
    [pool release];
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)addEarthquakesToList:(NSArray *)earthquakes {
    [self.earthquakeList addObjectsFromArray:earthquakes];
    [rootViewController.tableView reloadData];
}


#pragma mark Parser constants

static const const NSUInteger kMaximumNumberOfEarthquakesToParse = 50;

static NSUInteger const kSizeOfEarthquakeBatch = 10;

static NSString * const kEntryElementName = @"entry";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kUpdatedElementName = @"updated";
static NSString * const kGeoRSSPointElementName = @"georss:point";

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (parsedEarthquakesCounter >= kMaximumNumberOfEarthquakesToParse) {
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kEntryElementName]) {
        Earthquake *earthquake = [[Earthquake alloc] init];
        self.currentEarthquakeObject = earthquake;
        [earthquake release];
    } else if ([elementName isEqualToString:kLinkElementName]) {
        NSString *relAttribute = [attributeDict valueForKey:@"rel"];
        if ([relAttribute isEqualToString:@"alternate"]) {
            NSString *USGSWebLink = [attributeDict valueForKey:@"href"];
            static NSString * const kUSGSBaseURL = @"http://earthquake.usgs.gov/";
            self.currentEarthquakeObject.USGSWebLink = [kUSGSBaseURL stringByAppendingString:USGSWebLink];
        }
    } else if ([elementName isEqualToString:kTitleElementName] || [elementName isEqualToString:kUpdatedElementName] || [elementName isEqualToString:kGeoRSSPointElementName]) {
        accumulatingParsedCharacterData = YES;
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentEarthquakeObject];
        parsedEarthquakesCounter++;
        if (parsedEarthquakesCounter % kSizeOfEarthquakeBatch == 0) {
            [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    } else if ([elementName isEqualToString:kTitleElementName]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        [scanner scanString:@"M " intoString:NULL];
        CGFloat magnitude;
        [scanner scanFloat:&magnitude];
        self.currentEarthquakeObject.magnitude = magnitude;
        [scanner scanString:@", " intoString:NULL];
        NSString *location = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet illegalCharacterSet]  intoString:&location];
        self.currentEarthquakeObject.location = location;
    } else if ([elementName isEqualToString:kUpdatedElementName]) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.currentEarthquakeObject.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
    } else if ([elementName isEqualToString:kGeoRSSPointElementName]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        double latitude, longitude;
        [scanner scanDouble:&latitude];
        [scanner scanDouble:&longitude];
        self.currentEarthquakeObject.latitude = latitude;
        self.currentEarthquakeObject.longitude = longitude;
    }
    accumulatingParsedCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (didAbortParsing == NO) {
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[earthquakeFeedConnection release];
    [earthquakeData release];
    [earthquakeList release];
    [currentEarthquakeObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
	
	
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

