//
//  ViewController.m
//  Accelerometer Graph
//
//  Created by Tuan Shou Cheng on 2017/10/25.
//  Copyright © 2017年 Tuan Shou Cheng. All rights reserved.
//

#import "MainViewController.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"

#define kUpdateFrequency    60.0
#define kLocalizedPause     NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume    NSLocalizedString(@"Resume","resume taking samples")

@interface MainViewController ()
{
    AccelerometerFilter *filter;
    BOOL isPaused, useAdaptive;
}

@property (nonatomic, strong) IBOutlet GraphView *unfiltered;
@property (nonatomic, strong) IBOutlet GraphView *filtered;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pause;
@property (nonatomic, strong) IBOutlet UILabel *filterLabel;

- (IBAction)pauseOrResume:(id)sender;
- (IBAction)filterSelect:(id)sender;
- (IBAction)adaptiveSelect:(id)sender;

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
- (void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, pause, filterLabel;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pause.possibleTitles = [NSSet setWithObjects:kLocalizedPause, kLocalizedResume, nil];
    isPaused = NO;
    useAdaptive = NO;
    [self changeFilter:[LowpassFilter class]];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    [unfiltered setIsAccessibilityElement:YES];
    [unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];
    
    [filtered setIsAccessibilityElement:YES];
    [filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
}

#pragma mark - UIAccelerometerDelegate

// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // Update the accelerometer graph view
    if (!isPaused)
    {
        [filter addAcceleration:acceleration];
        [unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z];
        [filtered   addX:filter.x       y:filter.y       z:filter.z];
    }
}

#pragma mark - Help

- (void)changeFilter:(Class)filterClass
{
    // Ensure that the new filter class is different from the current one...
    if (filterClass != [filter class])
    {
        // And if it is, release the old one and create a new one.
        filter = [[filterClass alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
        // Set the adaptive flag
        filter.adaptive = useAdaptive;
        // And update the filterLabel with the new filter name.
        filterLabel.text = filter.name;
    }
}

- (void)notifyAccessibilityFilterDidChanged {
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

#pragma mark - Actions

- (IBAction)pauseOrResume:(id)sender
{
    if (isPaused)
    {
        // If we're paused, then resume and set the title to "Pause"
        isPaused = NO;
        pause.title = kLocalizedPause;
    }
    else
    {
        // If we are not paused, then pause and set the title to "Resume"
        isPaused = YES;
        pause.title = kLocalizedResume;
    }
    
    // Inform accessibility clients that the pause/resume button has changed.
    [self notifyAccessibilityFilterDidChanged];
}

- (IBAction)filterSelect:(id)sender
{
    if ([sender selectedSegmentIndex] == 0)
    {
        // Index 0 of the segment selects the lowpass filter
        [self changeFilter:[LowpassFilter class]];
    }
    else
    {
        // Index 1 of the segment selects the highpass filter
        [self changeFilter:[HighpassFilter class]];
    }
    
    // Inform accessibility clients that the filter has changed.
    [self notifyAccessibilityFilterDidChanged];
}

- (IBAction)adaptiveSelect:(id)sender
{
    // Index 1 is to use the adaptive filter, so if selected then set useAdaptive appropriately
    useAdaptive = [sender selectedSegmentIndex] == 1;
    // and update our filter and filterLabel
    filter.adaptive = useAdaptive;
    filterLabel.text = filter.name;
    
    // Inform accessibility clients that the adaptive selection has changed.
    [self notifyAccessibilityFilterDidChanged];
}

@end
