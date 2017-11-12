//
//  ViewController.m
//  IntripperSampleApp
//
//  Created by Sang.Mac.04 on 02/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import "PhonixMallController.h"
#import <InTripper/InTripper.h>
#import "IntripperEnvironment.h"
#import "AwesomeMenu.h"
#import "IntripperFloorButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LocateViewController.h"
#import "UILabel+Boldify.h"
#import "IANavigation.h"
#import "Conversion.h"
#import "CustomMallAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import "ArriveToDestinationViewController.h"
#import "OfferBand.h"
#import "RerouteViewController.h"
#import "SearchViewController.h"
#import "RouteListWindow.h"

@interface PhonixMallController ()<IntripperMapDelegate,AwesomeMenuDelegate,LocateViewDelegate,IANavigationDelegate,ConversionBandDelegate,UIAlertViewDelegate,ArriveToDestinationDelegate>

@property (strong, nonatomic) AwesomeMenu *floorMenu;
@property (strong, nonatomic) THLabel *lblSelectedFloorTitle;
@property(assign,readwrite)BOOL InterActiveMap;
@property (readwrite) CGPoint panCoord;
@property (readwrite) CGRect panRectCoord;

@end

@implementation PhonixMallController{
    IntripperMap *intripperMap;
    NSNumber *viewUserFloor;
    NSNumber *viewDesFloor;
    BOOL isNavigationStarted;
    CGSize estimatedTimeLabelSize;
    CGRect distanceinFtFrame;
    CGSize estimatedDistanceLabelSize;
    NSMutableArray *instructArray;
    BOOL tapTwiceFloor;
    NSArray *floorList;
    LocateViewController *newLocationController;
    BOOL isVolOn;
    NSMutableArray *allStore;
    IANavigation *locator;
    BOOL isLocationServiceStoped;
    int currentFloor;
    Conversion *conversionBand;
    BOOL isConvergenceDone;
    BOOL locationStabilize;
    int locationReadingCount;
    CustomMallAlertView *alertView;
    ArriveToDestinationViewController *demoview;
    OfferBand *offerBand;
    NSArray *promoData;
    int nextOfferColorset;
    CustomMallAlertView *alertViewForExitNavigation;
    BOOL reroutingEnable;
    SearchViewController *searchlist;
    RouteListWindow *routeListWindow;
    CGIndoorMapPoint singleTapPoint;
    BOOL hideBandForCertainTime;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    intripperMap=[[IntripperMap alloc] init];
    intripperMap.view.frame =CGRectMake(0, 0, [self.vwMap bounds].size.width, [self.vwMap bounds].size.height);
    intripperMap.mapdelegate=self;
    intripperMap.VenueID=@"32";
    intripperMap.useMapboxMap=NO;
    intripperMap.showStoreDuringNavigation=YES;
    intripperMap.floorNumber=0;
    intripperMap.enableFloorSelector=NO;
    [self.vwMap addSubview:intripperMap.view];
    [intripperMap autoFit];
    isVolOn=TRUE;
    UISwipeGestureRecognizer *onNavigationswipeLeft = [[UISwipeGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(onNavigationswipeLeft:)];
    [onNavigationswipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.vwTurnDetail addGestureRecognizer:onNavigationswipeLeft];
    
    UISwipeGestureRecognizer *onNavigationswipeRight = [[UISwipeGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(onNavigationswipeRight:)];
    [onNavigationswipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.vwTurnDetail addGestureRecognizer:onNavigationswipeRight];
    [self ShowNavigationDetail:NO animation:NO];
    [self ShowTurnDetail:NO animation:NO];
    [IntripperEnvironment circleButton:self.btnLocate];
    [IntripperEnvironment circleButton:self.btnGetDirection];
    [IntripperEnvironment circleButton:self.btnVolume];
    [self addPan];
    self.imgNavigation.transform = CGAffineTransformMakeRotation(M_PI_4);
}

-(void)viewWillAppear:(BOOL)animated{
    nextOfferColorset=-1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Intripper MAP

-(void)IndoorMapLoaded:(id)sender
{
   
}

-(void)hideMapAsset:(BOOL)Hide{
    NSLog(@"hide Asset %@",Hide?@"Y":@"N");
    if (Hide) {
        self.btnLocate.hidden=TRUE;
        self.btnGetDirection.hidden=TRUE;
    }
    else{
        self.btnLocate.hidden=FALSE;
        self.btnGetDirection.hidden=FALSE;
    }
}

- (void) removeMarkers {
    [intripperMap mapCleanup];
}

- (IBAction)onTapLocateMe:(UIButton *)sender
{
    [intripperMap centerBlueDot];
}

- (IBAction)turnVolOn:(UIButton *)sender
{
    if ([self.btnVolume.currentImage isEqual:[UIImage imageNamed:@"ic_volume_on.png"]])
    {
        [self.btnVolume setImage:[UIImage imageNamed:@"ic_volume_off.png"] forState:UIControlStateNormal];
        isVolOn=FALSE;
    }
    
    else
    {
        [self.btnVolume setImage:[UIImage imageNamed:@"ic_volume_on.png"] forState:UIControlStateNormal];
        isVolOn=TRUE;
    }
}

-(void) intripper:(id)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate floor:(int)level
{
    NSLog(@"Coordinates latitude and longitude are %f and %f",coordinate.latitude,coordinate.longitude);
    CLLocation *loc=[[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:3.0f verticalAccuracy:1.0 timestamp:[NSDate date]];
    [intripperMap setBlueDot:loc onFloor:level];
    
}
-(void)intripper:(id)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate floor:(int)level
{
    NSLog(@"Coordinates latitude and longitude are %f and %f",coordinate.latitude,coordinate.longitude);
    CLLocation *tappedPoint = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSDictionary *areaDetail=[intripperMap getTappedAreaInfo :tappedPoint onFloor:level];
    if (areaDetail!=nil) {
        [intripperMap showMarker:coordinate floor:level title:[areaDetail objectForKey:@"store"]];
        self.vwStoreDetail.hidden=FALSE;
        self.lblStoreName.text=[areaDetail objectForKey:@"store"];
 //       self.lblStoreTime.text=[self toCheckStoreIsOpen:[areaDetail objectForKey:@"hours"]];
        int strFloor=[[areaDetail objectForKey:@"floor"] intValue];
        singleTapPoint=CGMakeMapPoint(coordinate.latitude, coordinate.longitude, strFloor);
        [self hideMapAsset:TRUE];
        [self animateStoreBand];
    }
    else {
        self.vwStoreDetail.hidden=TRUE;
        self.lblStoreName.text=@"Store";
        self.lblStoreTime.text=@"Time";
    }
}

-(void)intripper:(id)mapView didChangeCameraPosition:(float)zoomLevel
{
    
}

-(void) intripper:(id )mapView didTapInfoWindowOfMarker:(NSDictionary *)markerDetail{
    CLLocation *location = [markerDetail objectForKey:@"location"];
    CGIndoorMapPoint userLocation=[intripperMap userLocation];
    CGIndoorMapPoint destinationPoint =CGMakeMapPoint(location.coordinate.latitude, location.coordinate.longitude, [[markerDetail objectForKey:@"level"] intValue]);
    [intripperMap FindRoute:userLocation destination:destinationPoint uptoDoor:FALSE];
    NSString *store=[markerDetail objectForKey:@"title"];
    NSRange range = [store rangeOfString:@" in "];
    NSString *displayTitle;
    if (range.length==NSNotFound) {
        displayTitle=store;
    }
    else{
        NSArray *splitArray=[store componentsSeparatedByString:@" in "];
        displayTitle=splitArray[0];
    }
    self.vwStoreDetail.hidden = TRUE;
    self.lblStoreName.text=displayTitle;
    self.lblEndPoint.text=[NSString stringWithFormat:@"To %@", self.lblStoreName.text];
    [self ShowNavigationDetail:YES animation:YES];
    [self changeTopBarForNavigation];
}

-(void)intripper:(id)mapView enterFloorChangeRegion:(NSDictionary *)region{
    
    
    CGRect frameEsc = self.vwChangeFloor.frame;
    if (self.vwStoreDetail.hidden==FALSE)
    {
        frameEsc.origin.y=self.view.frame.size.height-(2*self.vwStoreDetail.frame.size.height);
        self.vwChangeFloor.frame=frameEsc;
        self.vwChangeFloor.hidden=FALSE;
        [self hideMapAsset:TRUE];
    }
    else if (intripperMap.CurrentMapMode==NavigationMode_None)
    {
        frameEsc.origin.y=self.view.frame.size.height-self.vwChangeFloor.frame.size.height;
        self.vwChangeFloor.frame=frameEsc;
        self.vwChangeFloor.hidden=FALSE;
        [self hideMapAsset:TRUE];
    }
    else if (intripperMap.CurrentMapMode==NavigationMode_TurnByTurn )
    {
        frameEsc.origin.y=self.view.frame.size.height-(2*self.vwStoreDetail.frame.size.height);
        self.vwChangeFloor.frame=frameEsc;
        self.vwChangeFloor.hidden=FALSE;
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self HideEscalatorBand];
    });
    
}

-(void) intripper:(id)mapView enterPromoZone:(NSDictionary *)Zone promotion:(NSArray *)offers{
    [self showNotificationBand:offers];
}


#pragma mark Floor Change

-(IBAction)onCloseBandForChangingFloors:(UIButton *)sender
{
    self.vwChangeFloor.hidden=TRUE;
    hideBandForCertainTime=TRUE;
    if(intripperMap.CurrentMapMode==NavigationMode_None && self.vwStoreDetail.hidden==TRUE)
    {
        [self hideMapAsset:FALSE];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ChangeBoolValueForFloorBand];
    });
}

- (void)HideEscalatorBand{
    self.vwChangeFloor.hidden=TRUE;
    hideBandForCertainTime=TRUE;
    if(intripperMap.CurrentMapMode==NavigationMode_None && self.vwStoreDetail.hidden==TRUE)
    {
        [self hideMapAsset:FALSE];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ChangeBoolValueForFloorBand];
    });
}

- (void)ChangeBoolValueForFloorBand{
    
    hideBandForCertainTime=FALSE;
}


#pragma mark Floor Picker

-(void)intripper:(id)mapView floorChange:(int)level
{
    [self.floorMenu setSelected:level];
    CGRect fm=self.lblSelectedFloorTitle.frame;
    fm.size=CGSizeMake(150, 40);
    self.lblSelectedFloorTitle.frame=fm;
    self.lblSelectedFloorTitle.text=[NSString stringWithFormat:@"LEVEL %@", [[floorList objectAtIndex:level] objectForKey:@"Title"]];
    [self.lblSelectedFloorTitle sizeToFit];
    CGPoint ptlbl=self.lblSelectedFloorTitle.center;
    ptlbl.y=self.floorMenu.startPoint.y;
    self.lblSelectedFloorTitle.center=ptlbl;
}

-(void)intripper:(id)mapView activeFloorList:(NSArray *)levels
{
    floorList=levels;
    NSOrderedSet *uniqueFloors = [NSOrderedSet orderedSetWithArray:levels];
    NSEnumerator *enumerator = [uniqueFloors objectEnumerator];
    if (uniqueFloors.count>0) {
        AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                                           highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                                                               ContentImage:[UIImage imageNamed:@"icon-plus.png"]
                                                    highlightedContentImage:[UIImage imageNamed:@"icon-plus.png"]];
        
        NSMutableArray *menus=[[NSMutableArray alloc] init];
        NSDictionary *item = nil;
        while (item = [enumerator nextObject]) {
            UIImage *MenuItemImage = [UIImage imageNamed:@"bg-floorback.png"];
            UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-floorback.png"];
            NSString *stringText=[item objectForKey:@"Title"];
            
            AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:MenuItemImage
                                                                   highlightedImage:storyMenuItemImagePressed
                                                                      selectedImage:[UIImage imageNamed:@"bg-menuitem-selected.png"]
                                                                       ContentImage:[self FloorName:stringText withSize:12]
                                                               selectedContentImage:[self FloorNameWhite:stringText withSize:12]
                                                            highlightedContentImage:nil];
            [menus addObject:starMenuItem1];
        }
        self.floorMenu= [[AwesomeMenu alloc] initWithFrame:self.vwMap.bounds startItem:startItem optionMenus:menus];
        self.floorMenu.delegate = self;
        
        self.floorMenu.menuWholeAngle = -M_PI_2;
        self.floorMenu.rotateAngle=M_PI_4;
        self.floorMenu.farRadius = 120.0f;
        self.floorMenu.endRadius = 120.0f;
        self.floorMenu.nearRadius = 120.0f;
        
        self.floorMenu.animationDuration = 0.4f;
        CGRect ct=self.view.frame;
        CGRect ctMap=self.vwMap.frame;
        CGPoint pt=self.btnGetDirection.center;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.floorMenu.startPoint = CGPointMake(28, 90);
        }
        else{
            self.floorMenu.startPoint = CGPointMake(ct.size.width-30, ctMap.origin.y+30);
        }
        
        self.lblSelectedFloorTitle=[[THLabel alloc] initWithFrame:CGRectMake(50, pt.y-10, 150, 40)];
        self.lblSelectedFloorTitle.font=[UIFont fontWithName:@"Arial" size:12];
        self.lblSelectedFloorTitle.textColor=[UIColor colorWithRed:0.239 green:0.220 blue:0.204 alpha:1.00];
        self.lblSelectedFloorTitle.numberOfLines=0;
        self.lblSelectedFloorTitle.textAlignment=NSTextAlignmentLeft;
        [self.view insertSubview:self.floorMenu belowSubview:self.btnGetDirection];
        [self.floorMenu setSelected:0];
        self.lblSelectedFloorTitle.text=[NSString stringWithFormat:@"LEVEL %@", [[floorList objectAtIndex:0] objectForKey:@"Title"]];
        CGRect fm=self.lblSelectedFloorTitle.frame;
        fm.size=CGSizeMake(150, 40);
        [self.lblSelectedFloorTitle sizeToFit];
        [self.view insertSubview:self.lblSelectedFloorTitle belowSubview:self.btnGetDirection];
        CGPoint ptlbl=self.lblSelectedFloorTitle.center;
        ptlbl.y= self.floorMenu.startPoint.y;
        self.lblSelectedFloorTitle.center=ptlbl;
    }
}

-(UIImage *)FloorName:(NSString *)nm withSize:(float)fontSize{
    THLabel *lblFloorName=[[THLabel alloc] init];
    lblFloorName.strokeSize=1.0;
    lblFloorName.strokeColor=[UIColor colorWithRed:0.918 green:0.914 blue:0.890 alpha:1.00];
    
    lblFloorName.font=[UIFont fontWithName:@"Arial" size:fontSize];
    lblFloorName.textColor=[UIColor colorWithRed:0.239 green:0.220 blue:0.204 alpha:1.00];
    lblFloorName.numberOfLines=0;
    
    CGRect fm=lblFloorName.frame;
    fm.size=CGSizeMake(150, 30);
    lblFloorName.frame=fm;
    lblFloorName.text=nm;
    [lblFloorName sizeToFit];
    //Center Text
    lblFloorName.textAlignment=NSTextAlignmentCenter;
    
    return [IntripperEnvironment imageWithView:lblFloorName];
}

-(UIImage *)FloorNameWhite:(NSString *)nm withSize:(float)fontSize{
    THLabel *lblFloorName=[[THLabel alloc] init];
    lblFloorName.font=[UIFont fontWithName:@"Arial" size:fontSize];
    lblFloorName.textColor=[UIColor whiteColor];
    lblFloorName.numberOfLines=0;
    CGRect fm=lblFloorName.frame;
    fm.size=CGSizeMake(150, 30);
    lblFloorName.frame=fm;
    lblFloorName.text=nm;
    [lblFloorName sizeToFit];
    //Center Text
    lblFloorName.textAlignment=NSTextAlignmentCenter;
    return [IntripperEnvironment imageWithView:lblFloorName];
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"floor tap once");
    tapTwiceFloor=NO;
    IntripperFloorButton *tapfloor=[[IntripperFloorButton alloc] initWithFrame:CGRectZero];
    tapfloor.tag=idx;
    [intripperMap changeFloor:idx];
    [menu setSelected:(int)idx];
    CGRect fm=self.lblSelectedFloorTitle.frame;
    fm.size=CGSizeMake(150, 40);
    self.lblSelectedFloorTitle.frame=fm;
    self.lblSelectedFloorTitle.text=[NSString stringWithFormat:@"LEVEL %@", [[floorList objectAtIndex:idx] objectForKey:@"Title"]];
    [self.lblSelectedFloorTitle sizeToFit];
    CGPoint ptlbl=self.lblSelectedFloorTitle.center;
    ptlbl.y=self.floorMenu.startPoint.y;
    self.lblSelectedFloorTitle.center=ptlbl;
}

-(NSString *)FloorName:(int)ioFloor{
    NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(iofloor = %d)", ioFloor];
    NSArray *resultArray=[floorList filteredArrayUsingPredicate:filterFor];
    if ([resultArray count]>0) {
        return [resultArray[0] objectForKey:@"name"];
    }
    return [NSString stringWithFormat:@"%d",ioFloor];
}

- (void)awesomeMenuDoubleTap:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx{
    NSLog(@"Double Tap");
    [menu setSelected:(int)idx];
    CGRect fm=self.lblSelectedFloorTitle.frame;
    fm.size=CGSizeMake(150, 40);
    self.lblSelectedFloorTitle.frame=fm;
    self.lblSelectedFloorTitle.text=[NSString stringWithFormat:@"LEVEL %@", [[floorList objectAtIndex:idx] objectForKey:@"Title"]];
    [self.lblSelectedFloorTitle sizeToFit];
    CGPoint ptlbl=self.lblSelectedFloorTitle.center;
    ptlbl.y=self.floorMenu.startPoint.y;
    self.lblSelectedFloorTitle.center=ptlbl;
    IntripperFloorButton *tapfloor=[[IntripperFloorButton alloc] initWithFrame:CGRectZero];
    if (tapfloor!=nil) {
        tapfloor.tag=idx;
        currentFloor = (int)idx;
        [intripperMap changeFloor:(int) idx];
        isLocationServiceStoped=NO;
        [self ConfigIndoorAtlasForFloor];
    }
}

- (void)awesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu {
    //NSLog(@"Menu was closed!");
}
- (void)awesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu {
    //NSLog(@"Menu is open!");
}


#pragma mark On Instruction

-(void)intripper:(id)mapView instruction:(NSUInteger)pathIndex pathInfo:(NSDictionary *)routeInfo;
{
    if([instructArray count]==0)
        return;
    NSMutableDictionary *data=[instructArray objectAtIndex:pathIndex];
    BOOL isTurn=NO;
    NSString *f1=[[data objectForKey:@"properties"] objectForKey:@"instruction"];
    if(pathIndex==[instructArray count]-1){
        NSRange range = [f1 rangeOfString:@"your destination"];
        if (range.location == NSNotFound) {
            f1=[NSString stringWithFormat:@"%@ and arrive at your destination",f1];
        }
    }
    self.lblTurnInfo.text=f1;
    if (isVolOn==TRUE) {
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.lblTurnInfo.text];
        float systemVersion=[[[UIDevice currentDevice] systemVersion] floatValue];
        NSLog(@"%f",systemVersion);
        if(systemVersion>=9){
            utterance.rate =0.45f;
        }
        else{
            utterance.rate = 0.1f;
        }
        
        AVSpeechSynthesisVoice *voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"en-uk"];
        if (voice==nil) {
            NSLog(@"Bad Voice");
        }
        
        utterance.voice =voice;
        utterance.preUtteranceDelay = 0.2f;
        utterance.postUtteranceDelay = 0.2f;
        [synthesizer speakUtterance:utterance];
        
    }
    CGRect orignal=self.lblTurnInfo.frame;
    [self.lblTurnInfo sizeToFit];
    CGRect resize=self.lblTurnInfo.frame;
    resize.size.width=orignal.size.width;
    self.lblTurnInfo.frame=resize;
    //Text center align with ontent
    CGPoint centerLable =self.lblTurnInfo.center;
    centerLable.y=self.vwTurnDetail.frame.size.height/2;
    self.lblTurnInfo.center=centerLable;
    
    NSRange range = [f1 rangeOfString:@"left"];
    NSString *imageicon=@"";
    if (pathIndex==0) {
        imageicon=@"turn_start_white.png";
    }
    else if(pathIndex==[instructArray count]-1){
        imageicon=@"finish_flag_white.png";
    }
    else{
        if (range.location != NSNotFound) {
            imageicon=@"turn_left_white.png";
            isTurn=YES;
        }
        else{
            range = [f1 rangeOfString:@"right"];
            if (range.location!= NSNotFound) {
                imageicon=@"turn_right_white.png";
                isTurn=YES;
            }
            else{
                range = [f1 rangeOfString:@"destination"];
                if (range.location!= NSNotFound) {
                    imageicon=@"turn_destination_white.png";
                }
                else{
                    imageicon=@"turn_straight_white.png";
                }
            }
        }
    }
    
    self.imgTurn.image=[UIImage imageNamed:imageicon];
    self.btnPreviousRoute.tag =pathIndex-1;
    self.btnNextRoute.tag =pathIndex+1;
    self.btnPreviousRoute.hidden=self.btnPreviousRoute.tag==-1?YES:NO;
    self.btnNextRoute.hidden=self.btnNextRoute.tag==[instructArray count]?YES:NO;

}

- (void)onNavigationswipeLeft:(UITapGestureRecognizer *)recognizer {
    [self onTapNext:self.btnNextRoute];
}

- (void)onNavigationswipeRight:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle swipe right
    [self onTapPrevious:self.btnPreviousRoute];
}

- (IBAction)onTapNext:(UIButton *)sender {
    if (sender.hidden==NO) {
        CATransition *objTransition = [CATransition animation];
        [objTransition setDuration:0.2];
        [objTransition setType:kCATransitionMoveIn];
        [objTransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        objTransition.subtype = kCATransitionFromRight;
        [[self.vwTurnDetail layer] addAnimation:objTransition forKey:kCATransitionMoveIn];
        [intripperMap NextStepInstruction];
        
    }
    
}

- (IBAction)onTapPrevious:(UIButton *)sender {
    if (sender.hidden==NO) {
        CATransition *objTransition = [CATransition animation];
        [objTransition setDuration:0.2];
        [objTransition setType:kCATransitionMoveIn];
        [objTransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        objTransition.subtype = kCATransitionFromLeft;
        [[self.vwTurnDetail layer] addAnimation:objTransition forKey:kCATransitionMoveIn];
        [intripperMap PreviousStepInstruction];
    }
}

-(void)intripper:(id)mapView route:(NSArray *)routeList;
{
    instructArray=[[NSMutableArray alloc] init];
    double totalDistance=0;
    for (NSDictionary *row in routeList) {
        [instructArray removeAllObjects];
        instructArray=[[NSMutableArray alloc] initWithArray:[row objectForKey:@"features"]];
        
    }
    for (NSDictionary *feature in instructArray) {
        NSDictionary *properties= [feature objectForKey:@"properties"];
        totalDistance=totalDistance+[[properties objectForKey:@"distance"] doubleValue];
    }
    NSDictionary *startFrom=[instructArray firstObject];
    NSDictionary *EndTo=[instructArray lastObject];
    
    [self buildNavBandUI:[[[startFrom objectForKey:@"properties"] objectForKey:@"level"] intValue] endFloor:[[[EndTo objectForKey:@"properties"] objectForKey:@"level"] intValue] totalDistance:totalDistance];
    if (reroutingEnable==YES) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [intripperMap  StepToInstruction:0];
        });
        
    }
    reroutingEnable=NO;
    
}


#pragma mark Navigation

- (IBAction)startTurnByTurnNavi:(id)sender{
    self.vwStoreDetail.hidden=TRUE;
    CGIndoorMapPoint userLocation=[intripperMap userLocation];
    [intripperMap FindRoute:userLocation destination:singleTapPoint uptoDoor:TRUE];
    self.lblEndPoint.text=[NSString stringWithFormat:@"To %@", self.lblStoreName.text];
    [self ShowNavigationDetail:YES animation:YES];
    [self changeTopBarForNavigation];
}

-(void)ShowNavigationDetail:(BOOL)show animation:(BOOL)withAnimation{
    if (CGAffineTransformIsIdentity(self.vwRouteDetail.transform)) {
        if (!show) {
            CGRect frameLocation=self.vwRouteDetail.frame;
            CGAffineTransform ct=CGAffineTransformMakeTranslation(0, frameLocation.size.height+30);
            if (withAnimation) {
                [UIView animateWithDuration:.3f animations:^{
                    self.vwRouteDetail.transform=ct;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else{
                self.vwRouteDetail.transform=ct;
            }
                   self.panRectCoord=self.vwRouteDetail.frame; // Added to prevent route detail band bug staying at some events.
        }
    }
    else{
        
        if (show) {
                     self.panRectCoord=self.vwRouteDetail.frame;
                      NSLog(@"position %f,%f",self.panRectCoord.origin.x,self.panRectCoord.origin.y);
            CGAffineTransform ct=CGAffineTransformIdentity;
            if (withAnimation) {
                [UIView animateWithDuration:.3f animations:^{
                    self.vwRouteDetail.transform=ct;
                } completion:^(BOOL finished) {
                                     [self hideMapAsset:TRUE];
                                    self.panRectCoord=self.vwRouteDetail.frame;
                }];
            }
            else{
                self.vwRouteDetail.transform=ct;
                            self.panRectCoord=self.vwRouteDetail.frame;
            }
        }
        
        
    }
    
}

- (IBAction)onTapStartNavigation:(UIButton *)sender {
    [self ShowTurnDetail:YES animation:YES];
    self.vwTopBar.hidden=TRUE;
    self.btnVolume.hidden=FALSE;
    [self hideMapAsset:TRUE];
        if(newLocationController!=Nil)
        {
            [self closeSeachLocation:newLocationController];
    
        }
    
    self.btnStartNavigation.hidden = YES;
    self.imgNavigation.hidden = YES;
    self.btnStartNavigation.userInteractionEnabled = NO;
    self.btnCloseNavigation.hidden = NO;
    self.imgCloseNavi.hidden = NO;
    self.btnCloseNavigation.userInteractionEnabled = YES;
    //TODO ADD Instruction here
    [intripperMap StepToInstruction:0];
    //Animate Path to 1 to 15
        self.vwRouteDetail.frame=self.panRectCoord;
        if (routeListWindow!=nil) {
            [routeListWindow.view removeFromSuperview];
            routeListWindow=nil;
      }
    
}

- (IBAction)onTapCancelNavigation:(UIButton *)sender {
    
    [intripperMap exitNavigation];
    self.vwTopBar.hidden=FALSE;
    [self resetTopBarUI];
    [self hideMapAsset:FALSE];
    self.btnVolume.hidden=TRUE;
    [self removeMarkers];
    [self ShowNavigationDetail:NO animation:YES];
    [self ShowTurnDetail:NO animation:NO];
    self.btnStartNavigation.hidden=NO;
    self.btnStartNavigation.hidden = NO;
    self.imgNavigation.hidden = NO;
    self.btnStartNavigation.userInteractionEnabled = YES;
    
    self.btnCloseNavigation.hidden = YES;
    self.imgCloseNavi.hidden = YES;
    self.btnCloseNavigation.userInteractionEnabled = NO;
    
    CGRect placeControlFrame=self.vwTopBar.frame;
    if (CGAffineTransformIsIdentity(self.txtSearchOption.transform) ) {
        
        CGAffineTransform searchShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform cancelShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform searchButtonShift=CGAffineTransformIdentity;
        self.txtSearchOption.transform=searchShift;
        self.btnSearch.transform=searchButtonShift;
        
        [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.txtSearchOption.alpha=0;
            self.btnCancel.transform=cancelShift;
            
        } completion:^(BOOL finished) {
            [self.txtSearchOption resignFirstResponder];
            self.btnSearch.alpha = 1;
            self.lblVenueName.alpha = 1;
            self.btnGoBack.alpha = 1;
            self.btnCancel.alpha = 0;
            self.btnGoBack.userInteractionEnabled = YES;
            self.btnSearch.userInteractionEnabled=YES;
            self.btnGoToMap.alpha = 0;
            self.btnGoToMap.userInteractionEnabled = NO;
            self.vwStoreDetail.hidden = YES;
            
            
            
        }];
        self.txtSearchOption.text=@"";
        
    }
}

-(void)ShowTurnDetail:(BOOL)show animation:(BOOL)withAnimation{
    isNavigationStarted=show;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    
    if (show) {
     
    }
    else{
        //Set Zoom to scale
    }
    [CATransaction commit];
    if (CGAffineTransformIsIdentity(self.vwTurnByTurn.transform)) {
        if (!show) {
            CGRect frameLocation=self.vwTurnByTurn.frame;
            CGAffineTransform ct=CGAffineTransformMakeTranslation(0, -(frameLocation.size.height+frameLocation.origin.y));
            if (withAnimation) {
                [UIView animateWithDuration:.1f animations:^{
                    self.vwTurnByTurn.transform=ct;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else{
                self.vwTurnByTurn.transform=ct;
            }
            
        }
    }
    else{
        
        if (show) {
            CGAffineTransform ct=CGAffineTransformIdentity;
            if (withAnimation) {
                [UIView animateWithDuration:.3f animations:^{
                    self.vwTurnByTurn.transform=ct;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else{
                self.vwTurnByTurn.transform=ct;
            }
        }
        
        
    }
    
}

-(void)intripper:(id)mapView endNavigation:(BOOL)navigationState{

    alertViewForExitNavigation = [[CustomMallAlertView alloc] init];
    alertViewForExitNavigation.diaplogPositionMode= DialogBootom;
    alertViewForExitNavigation.object=nil;
    NSBundle *bundle = [NSBundle mainBundle];
    demoview = [[ArriveToDestinationViewController alloc]initWithNibName:@"ArriveToDestinationViewController" bundle:bundle ];
    demoview.view.hidden = NO; //calls viewDidLoad
    demoview.delegate = self;
    //[demoview fillDetails:payLoad];
    //                mixIsJourneyCompleted=TRUE;
    //                mixIsjourneyAborted=FALSE;
    [alertViewForExitNavigation setContainerView:demoview.vwExitNavPopup];
    //[alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Exit Navigation",nil]];
    [alertViewForExitNavigation setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
    [alertViewForExitNavigation setOnButtonTouchUpInside:^(CustomMallAlertView *alertView, int buttonIndex)
     {
         //NSDictionary *payloaddata= alertView.object;
         //NSArray *zoneData=[payloaddata objectForKey:@"id"];
         switch (buttonIndex) {
             case 0://Dismiss view
                 [self onTapCancelNavigation:self.btnCloseNavigation];
                 
                 [alertViewForExitNavigation close];
                 
                 break;
             default:
                 break;
         }
         
         
     }];
    
    // And launch the dialog
    [alertViewForExitNavigation show];
}

-(void)HideExitNavigation{
    if (demoview.vwExitNavPopup.superview!=nil) {
        [self onTapCancelNavigation:self.btnCloseNavigation];
        [alertViewForExitNavigation close];
    }
    
}

-(void)intripper:(id)mapView reRouteWithLocation:(CLLocationCoordinate2D)coordinate floor:(int)level
{
    CustomMallAlertView *rerouteAlertView = [[CustomMallAlertView alloc] init];
    rerouteAlertView.diaplogPositionMode=DialogBootom;
    rerouteAlertView.object=[NSDictionary dictionaryWithObjectsAndKeys:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude],@"location",[NSNumber numberWithInt:level],@"level", nil];
    NSBundle *bundle = [NSBundle mainBundle];
    
    RerouteViewController *rerouteView = [[RerouteViewController alloc]initWithNibName:@"RerouteViewController" bundle:bundle ];
    rerouteView.view.hidden = NO; //calls viewDidLoad
    
    [rerouteAlertView setContainerView:rerouteView.view];
    [rerouteAlertView setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
    [rerouteAlertView setOnButtonTouchUpInside:^(CustomMallAlertView *alertView, int buttonIndex)
     {
         NSDictionary *payloaddata= rerouteAlertView.object;
         CLLocation *loc=[payloaddata objectForKey:@"location"];
         int strLevel=[[payloaddata objectForKey:@"level"] intValue];
         switch (buttonIndex) {
             case 0://Dismiss view
                 
                 break;
             case 2:
                 [self abundantNavigation];
                 break;
             case 1:
                 [intripperMap ReRoute:loc.coordinate floor:strLevel];
                 reroutingEnable=YES;
                 break;
             default:
                 break;
         }
         if (buttonIndex==0) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             });
         }
         [alertView close];
     }];
    
    // And launch the dialog
    [rerouteAlertView show];
}

-(void)abundantNavigation{
    [self onTapCancelNavigation:self.btnCloseNavigation];
}


#pragma mark Store Detail

-(void)animateStoreBand
{
    [UIView transitionWithView:self.vwStoreDetail
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.vwStoreDetail.frame=CGRectMake(0, self.view.frame.size.height-self.vwStoreDetail.frame.size.height, self.vwStoreDetail.frame.size.width, self.vwStoreDetail.frame.size.height);
                    }
                    completion:nil];
}

-(NSString *) toCheckStoreIsOpen:(NSString *)storeTime
{
    NSString *isBetween;
    NSArray* dateArray = [storeTime componentsSeparatedByString: @","];
    NSString *storeTimeForArray=[dateArray objectAtIndex:1];
    NSArray* arrStoreTime = [storeTimeForArray componentsSeparatedByString: @"-"];
    NSString* startTimeString=[[arrStoreTime objectAtIndex:0] uppercaseString];
    NSString* endTimeString =[[arrStoreTime objectAtIndex:1] uppercaseString];
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"hh:mma"];
    
    NSString *nowTimeString = [formatter stringFromDate:[NSDate date]];
    
    int startTime   = [self minutesSinceMidnight:[formatter dateFromString:startTimeString]];
    int endTime     = [self minutesSinceMidnight:[formatter dateFromString:endTimeString]];
    int nowTime     = [self minutesSinceMidnight:[formatter dateFromString:nowTimeString]];;
    
    
    if (startTime <= nowTime && nowTime <= endTime)
    {
        NSLog(@"Time is between");
        isBetween= @"Open Now";
    }
    else {
        NSLog(@"Time is not between");
        isBetween= @"Closed Now";
    }
    return isBetween;
}

-(int) minutesSinceMidnight:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    return 60 * (int)[components hour] + (int)[components minute];
}

-(void)buildNavBandUI:(int) startFloor endFloor:(int)endFloor totalDistance:(double) totalDistance {
    if (self.lblEstimatedTime!=Nil)
    {
        [self.lblEstimatedTime removeFromSuperview];
        [self.vwSeparatorOne removeFromSuperview];
        [self.lblDistanceinFt removeFromSuperview];
        [self.vwSeparatorTwo removeFromSuperview];
        [self.lblLevels removeFromSuperview];
    }
    self.lblEstimatedTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 120, 20)];
    
    self.lblEstimatedTime.font=[UIFont fontWithName:@"Helvetica-Light" size:13];
    self.lblEstimatedTime.textColor = [UIColor whiteColor];
    self.lblEstimatedTime.text = [[IntripperEnvironment instance] convertFeetToTimeCustom:totalDistance];
    estimatedTimeLabelSize = [self.lblEstimatedTime.text sizeWithFont:self.lblEstimatedTime.font constrainedToSize:self.lblEstimatedTime.bounds.size
                                                   lineBreakMode:self.lblEstimatedTime.lineBreakMode];
    self.vwSeparatorOne = [[UIView alloc] initWithFrame:CGRectMake(estimatedTimeLabelSize.width+5, 11, 8, 8)];
    self.vwSeparatorOne.backgroundColor = [UIColor whiteColor];
    [IntripperEnvironment circleView:self.vwSeparatorOne];
    
    
    self.lblDistanceinFt = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 120, 20)];
    
    distanceinFtFrame= self.lblDistanceinFt.frame;
    distanceinFtFrame.origin.x = self.vwSeparatorOne.frame.origin.x + self.vwSeparatorOne.frame.size.width + 5;
    distanceinFtFrame.origin.y = 5;
    distanceinFtFrame.size.width = 80;
    distanceinFtFrame.size.height = 20;
    self.lblDistanceinFt.frame = distanceinFtFrame;
    
    self.lblDistanceinFt.font=[UIFont fontWithName:@"Helvetica-Light" size:13];
    self.lblDistanceinFt.textColor = [UIColor colorWithRed:0.043 green:0.78 blue:0.706 alpha:1];
    totalDistance = totalDistance * 3.28;
    self.lblDistanceinFt.text = [NSString stringWithFormat:@"%.0f feet",totalDistance];
    
    [self.vwStoreTimeFeet addSubview:self.lblEstimatedTime];
    [self.vwStoreTimeFeet addSubview:self.vwSeparatorOne];
    [self.vwStoreTimeFeet addSubview:self.lblDistanceinFt];
    
    if(endFloor > startFloor){
        estimatedDistanceLabelSize = [self.lblDistanceinFt.text sizeWithFont:self.lblDistanceinFt.font constrainedToSize:self.lblDistanceinFt.bounds.size
                                                          lineBreakMode:self.lblDistanceinFt.lineBreakMode];
        self.vwSeparatorTwo = [[UIView alloc] initWithFrame:CGRectMake(self.lblDistanceinFt.frame.origin.x + estimatedDistanceLabelSize.width+5, 11, 8, 8)];
        self.vwSeparatorTwo.backgroundColor = [UIColor whiteColor];
        [IntripperEnvironment circleView:self.vwSeparatorTwo];
        
        [self.vwStoreTimeFeet addSubview:self.vwSeparatorTwo];
        
        self.lblLevels = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 120, 20)];
        
        CGRect levelsFrame = self.lblLevels.frame;
        levelsFrame.origin.x = self.vwSeparatorTwo.frame.origin.x + self.vwSeparatorTwo.frame.size.width + 5;
        levelsFrame.origin.y = 5;
        levelsFrame.size.width = 100;
        levelsFrame.size.height = 20;
        self.lblLevels.frame = levelsFrame;
        
        self.lblLevels.font=[UIFont fontWithName:@"Helvetica-Light" size:13];
        self.lblLevels.textColor = [UIColor colorWithRed:0.227 green:0.604 blue:0.851 alpha:1];
        if(endFloor == 1){
            self.lblLevels.text = [NSString stringWithFormat:@"%d level up",endFloor];
        }
        else{
            self.lblLevels.text = [NSString stringWithFormat:@"%d levels up",endFloor];
        }
        [self.vwStoreTimeFeet addSubview:self.lblLevels];
    }
    else if (endFloor < startFloor){
        estimatedDistanceLabelSize = [self.lblDistanceinFt.text sizeWithFont:self.lblDistanceinFt.font constrainedToSize:self.lblDistanceinFt.bounds.size
                                                          lineBreakMode:self.lblDistanceinFt.lineBreakMode];
        self.vwSeparatorTwo = [[UIView alloc] initWithFrame:CGRectMake(self.lblDistanceinFt.frame.origin.x + estimatedDistanceLabelSize.width+5, 11, 8, 8)];
        self.vwSeparatorTwo.backgroundColor = [UIColor whiteColor];
        [IntripperEnvironment circleView:self.vwSeparatorTwo];
        [self.vwStoreTimeFeet addSubview:self.vwSeparatorTwo];
        
        self.lblLevels = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 120, 20)];
        
        CGRect levelsFrame = self.lblLevels.frame;
        levelsFrame.origin.x = self.vwSeparatorTwo.frame.origin.x + self.vwSeparatorTwo.frame.size.width + 5;
        levelsFrame.origin.y = 5;
        levelsFrame.size.width = 100;
        levelsFrame.size.height = 20;
        self.lblLevels.frame = levelsFrame;
        
        self.lblLevels.font=[UIFont fontWithName:@"Helvetica-Light" size:13];
        self.lblLevels.textColor = [UIColor colorWithRed:0.227 green:0.604 blue:0.851 alpha:1];
        int levelToTravel = startFloor - endFloor;
        if(levelToTravel == 1){
            self.lblLevels.text = [NSString stringWithFormat:@"%d level down",levelToTravel];
        }
        else{
            self.lblLevels.text = [NSString stringWithFormat:@"%d levels down",levelToTravel];
        }
        [self.vwStoreTimeFeet addSubview:self.lblLevels];
    }
}


#pragma mark Top Bar

-(void)resetTopBarUI{
        self.vwRouteDetail.frame=self.panRectCoord;
        if (routeListWindow!=nil) {
            [routeListWindow.view removeFromSuperview];
            routeListWindow=nil;
        }
    self.vwTopBarContainer.backgroundColor = [UIColor colorWithRed:0.043 green:0.78 blue:0.706 alpha:1]; /*#0bc7b4*/
    self.lblVenueName.text = @"High Street Phoenix";
    self.btnSearch.hidden = NO;
    self.btnCancel.hidden = YES;
    self.txtSearchOption.text=@"";
    self.txtSearchOption.alpha = 0;
    self.lblVenueName.alpha = 1;
    self.btnGoToMap.alpha = 0;
    self.btnGoToMap.userInteractionEnabled = NO;
    self.btnGoBack.alpha = 1;
    self.btnGoBack.userInteractionEnabled = YES;
    
}

-(void) changeTopBarForNavigation{
    self.vwTopBarContainer.backgroundColor = [UIColor colorWithRed:0.239 green:0.306 blue:0.396 alpha:1];
    self.lblVenueName.text = @"Route Preview";
    self.btnSearch.hidden = YES;
    self.btnCancel.hidden = YES;
    self.txtSearchOption.text=@"";
    self.txtSearchOption.alpha = 0;
    self.lblVenueName.alpha = 1;
    self.btnGoToMap.alpha = 1;
    self.btnGoToMap.userInteractionEnabled = YES;
    self.btnGoBack.alpha = 0;
    self.btnGoBack.userInteractionEnabled = NO;
}


#pragma mark Get Direction

- (IBAction)onTapManualDirection:(UIButton *)sender {
    if (newLocationController==nil){
        CGIndoorMapPoint userLocation=[intripperMap userLocation];
        if (CGIndoorMapPointIsEmpty(userLocation)) {
            newLocationController=[[LocateViewController alloc]initWithNibName:@"LocateViewController" bundle:[NSBundle mainBundle]
                                                                  fromLocation:CGMakeMapPointEmpty() fromLocationText:@""
                                                                    toLocation:CGMakeMapPointEmpty() toLocationText:@"" ];
        }
        else{
            newLocationController=[[LocateViewController alloc]initWithNibName:@"LocateViewController" bundle:[NSBundle mainBundle]
                                                                  fromLocation:userLocation fromLocationText:@"My Location"
                                                                    toLocation:CGMakeMapPointEmpty() toLocationText:@"" ];
            [self NewStartLocation:@"My Location"];

        }
        newLocationController.delegate=self;
        
    }
    [self.view addSubview:newLocationController.view];
    [self hideMapAsset:YES];
    if (CGAffineTransformIsIdentity(self.vwStoreDetail.transform)) {
        CGRect placeControlFrame=self.vwStoreDetail.frame;
        CGAffineTransform storeInfoShift=CGAffineTransformMakeTranslation(0, placeControlFrame.size.height);
        [UIView animateWithDuration:.3f animations:^{
            self.vwStoreDetail.transform=storeInfoShift;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)closeSeachLocation:(LocateViewController *)sender{
    [newLocationController.view removeFromSuperview];
    newLocationController=nil;
    if(intripperMap.CurrentMapMode==NavigationMode_Preview || intripperMap.CurrentMapMode==NavigationMode_TurnByTurn)
    {
        [self hideMapAsset:TRUE];
    }
    else
    {
        [self hideMapAsset:FALSE];
    }
    
}

-(void)closeSeachLocationWithBarAndPath:(LocateViewController *)sender{
    [newLocationController.view removeFromSuperview];
    [self onTapCancelNavigation:self.btnCloseNavigation];
    newLocationController=nil;
    if(intripperMap.CurrentMapMode==NavigationMode_Preview || intripperMap.CurrentMapMode==NavigationMode_TurnByTurn)
    {
        [self hideMapAsset:TRUE];
    }
    else
    {
        [self hideMapAsset:FALSE];
    }
}

-(void)NewStartLocation:(NSString *)text{
    UILabel *fromLabel = [UILabel alloc];
    [fromLabel setAttributedText:nil];
    fromLabel.text=[NSString stringWithFormat:@"From: %@", text];
    [fromLabel boldSubstring:text];
}

-(void)NewEndLocation:(NSString *)text{
    [self.lblEndPoint setAttributedText:nil];
    self.lblEndPoint.text=[NSString stringWithFormat:@"To %@", text];
    [self.lblEndPoint boldSubstring:text];
}

-(void)getSeachLocation:(NSString *)searchBy{
    NSArray * test=[intripperMap AllStoreInformation];
    
    NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(store CONTAINS[cd] %@)", searchBy];
    NSArray *resultArray=[test filteredArrayUsingPredicate:filterFor];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"store" ascending:YES];
    NSArray *sortedArray=[resultArray sortedArrayUsingDescriptors:@[sort]];
    if ([sortedArray count]>4) {
        NSArray *smallArray = [sortedArray subarrayWithRange:NSMakeRange(0, 4)];
        //Format markers;
        [newLocationController setSeachLocation:smallArray];
    }
    else{
        [newLocationController setSeachLocation:sortedArray];
    }
    NSLog(@"type kit %@", searchBy);
    
}

-(void)locatePathOnMap:(LocateViewController *)sender{
    CLLocationCoordinate2D currentLocation=CLLocationCoordinate2DMake(sender.start.lat, sender.start.lng);
    CLLocationCoordinate2D lastLocation=CLLocationCoordinate2DMake(sender.destination.lat, sender.destination.lng);
    NSLog(@"%d and %d",sender.start.floor,sender.destination.floor);
     [intripperMap FindRoute:CGMakeMapPoint(currentLocation.latitude, currentLocation.longitude, sender.start.floor) destination:CGMakeMapPoint(lastLocation.latitude, lastLocation.longitude, sender.destination.floor) uptoDoor:TRUE];
    [self ShowNavigationDetail:YES animation:YES];
    self.btnStartNavigation.hidden=NO;
    [self hideMapAsset:TRUE];
}


#pragma mark Indoor Atlas

- (void)IAlocation:(IANavigation *)manager didUpdateLocation:(CGPoint)newLocation andLatLng:(CGIndoorMapPoint) geoPoint accuracy:(double)radius heading:(double)direction{
    CLLocationCoordinate2D SDKLocation=CLLocationCoordinate2DMake(geoPoint.lat, geoPoint.lng);
    CLLocation *newUserLocation=[[CLLocation alloc] initWithCoordinate:SDKLocation altitude:1 horizontalAccuracy:3.0f verticalAccuracy:1.0 timestamp:[NSDate date]];

    if (geoPoint.floor==currentFloor) {
        [intripperMap setBlueDot:newUserLocation onFloor: geoPoint.floor];
       
    }
}

- (void)discoveringUserLocation:(IANavigation *)manager{
}

- (void)calibrationDone:(IANavigation *)manager isBackground:(BOOL)onBackground{
}

- (void)calibrationFailed:(IANavigation *)manager isBackground:(BOOL)onBackground{
}

- (void)fatalError:(IANavigation *)manager error:(NSString *)errorapi{
    isLocationServiceStoped=YES;
}

- (void)walkToFixLocation:(IANavigation *)manager info:(NSString *)infostring{
}

- (void)IAlocationUnavailable:(IANavigation *)manager error:(NSString *)errorapi{
    isLocationServiceStoped=YES;
}

- (void)IAlocationAvailable:(IANavigation *)manager{
    isLocationServiceStoped=NO;
}

-(void)indoorAtlasNorthHeading:(double)northHead{
}

- (void)conversionDone:(IANavigation *)manager{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isConvergenceDone=YES;
        locationStabilize=YES;
        [self HideNewConvergenceBand:YES];
        [intripperMap centerBlueDot];
    });
}

- (void)conversionBegin:(IANavigation *)manager{
    
    isConvergenceDone=NO;
    locationReadingCount=0;
    
    //Show Conversion Screen
    self.InterActiveMap=TRUE;
    
    [self ShowNewConvergenceBand];
    
    //[self stopIdealTimer];
}

- (void)calibrationFinish:(IANavigation *)manager{
}

- (void)convergenceStatus:(IANavigation *)manager info:(NSString *)infostring{
    NSLog(@"convergenceStatus: %@",infostring);
    [self setConvergenceMsg:infostring];
}

-(void)ConfigIndoorAtlasForFloor{
    @try {
        //start positioning for location Floor
        
        
        NSNumber *positionFloor;
        positionFloor = [NSNumber numberWithInt:currentFloor];
        
        NSDictionary *apidata=[NSDictionary dictionaryWithObjectsAndKeys:
                               [intripperMap LocationFloorRef:[positionFloor intValue]],@"graphicID",
                               @"0,0",@"padding",
                               positionFloor,@"floor", nil];
        
        NSString *graphicID=[apidata objectForKey:@"graphicID"];
        BOOL serviceActive=NO;
        if (![graphicID isEqualToString:@""]) {
            if (locator==nil) {
                locator=[[IANavigation alloc] init:[intripperMap IAAPIapikey] hash:[intripperMap IAAPIapiSecret] floorids:[intripperMap LocationFloorRefID]];
                locator.Delegate=self;
                
            }
            else{
                if (locator.floorNumber!=[positionFloor intValue]) {
                    
                }
                else{
                    if (tapTwiceFloor==YES) {
                        
                    }
                    else{
                        if ([locator isServiceActive]) {
                            serviceActive=YES;
                        }
                        
                    }
                }
            }
            if (serviceActive==NO) {
                [locator StartInDoorAtlas:12 andmap:[intripperMap.VenueID intValue] andApi:apidata];
            }
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Not initialize cat");
    }
    @finally {
        
    }
}


#pragma mark Conversion UI

-(void)setConvergenceMsg:(NSString *)msg{
    if (conversionBand.vwConvergence.superview!=nil) {
        conversionBand.lblConMessage.text=NSLocalizedString(msg, @"Conversion");
        [self slideAnimation:conversionBand.lblConMessage];
    }
}

- (CALayer *)addedmaskLayer:(UIView *)viewlayer {
    for (CALayer *layer in [viewlayer.layer sublayers]) {
        
        if ([[layer name] isEqualToString:@"maskslide"]) {
            return layer;
        }
    }
    return nil;
}

-(void)HideConvergenceDialog{
    
}

- (void)slideAnimation:(UILabel *)targetframe {
    
    CALayer *temp=[self addedmaskLayer:targetframe.superview];
    if (temp!=nil ) {
        [temp removeFromSuperlayer];
        targetframe.hidden=NO;
    }
    UIGraphicsBeginImageContextWithOptions(targetframe.frame.size, NO, 2*[[UIScreen mainScreen] scale]);
    [targetframe.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    targetframe.hidden=YES;
    CGFloat textWidth = textImage.size.width;
    CGFloat textHeight = textImage.size.height;
    CALayer *textLayer = [CALayer layer];
    textLayer.contents = (id)[textImage CGImage];
    textLayer.frame = targetframe.frame;
    [textLayer setName:@"maskslide"];
    CALayer *maskLayer = [CALayer layer];
    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
    maskLayer.contents = (id)[[UIImage imageNamed:@"MaskSlide.png"] CGImage];
    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.frame = CGRectMake(-textWidth, 0.0f, textWidth * 2, textHeight);
    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    maskAnim.byValue = [NSNumber numberWithFloat:textWidth];
    maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 1.0f;
    [maskLayer addAnimation:maskAnim forKey:@"slideAnim"];
    
    textLayer.mask = maskLayer;
    [targetframe.superview.layer addSublayer:textLayer];
}

-(void)ShowNewConvergenceBand{
    if (!self.InterActiveMap) {
        return;
    }
    
    if (conversionBand.view.superview==nil) {
        alertView = [[CustomMallAlertView alloc] init];
        alertView.diaplogPositionMode=DialogTop;
        alertView.object=nil;
        NSBundle *bundle = [NSBundle mainBundle];
        conversionBand=[[Conversion alloc]initWithNibName:@"Conversion" bundle:bundle];
        conversionBand.view.hidden = NO; //calls viewDidLoad
        [IntripperEnvironment circleView:conversionBand.vwOuterCircle];
        [IntripperEnvironment circleView:conversionBand.vwInnerCircle];
        conversionBand.lblConvoTitle.text=NSLocalizedString(@"keep walking my friend", @"ConversionTitle");
        conversionBand.imgActionDone.alpha = 0;
        conversionBand.imgNeedle.alpha = 1;
        conversionBand.delegate = self;
        [alertView setContainerView:conversionBand.vwConvergence];
        alertView.displayCloseDialog=YES;
        [alertView setButtonTitles:[[NSMutableArray alloc] init]];
        [alertView setOnButtonTouchUpInside:^(CustomMallAlertView *alertView1, int buttonIndex)
         {
             switch (buttonIndex) {
                 case 0://Dismiss view
                     
                     break;
                 case 2:
                     //Change Floor to next
    
                     break;
                 case 1:
                     
                     
                     break;
                 default:
                     break;
             }
             [alertView1 close];
             
         }];
        conversionBand.lblConvoTitle.hidden=YES;
        // And launch the dialog
        [alertView show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self slideAnimation:conversionBand.lblConMessage];
            
        });
    }
}

-(void)HideNewConvergenceBand:(BOOL)animated{
    if (conversionBand.vwConvergence.superview!=nil) {
        [conversionBand.lblConvoTitle.layer removeAllAnimations];
        [conversionBand cancelAnimation];
        conversionBand.lblConvoTitle.alpha = 0;
        conversionBand.lblConMessage.text=NSLocalizedString(@"We found you", @"Conversion");
        if (animated){
            conversionBand.lblConvoTitle.hidden=YES;
            [UIView animateWithDuration:3.0 animations:^{
                conversionBand.vwConvergenceBottomBar.backgroundColor=[UIColor colorWithRed:0.227 green:0.604 blue:0.851 alpha:1];
                conversionBand.vwInnerCircle.backgroundColor = [UIColor colorWithRed:0.043 green:0.78 blue:0.706 alpha:1];
                conversionBand.imgNeedle.alpha = 0;
                conversionBand.imgActionDone.alpha = 1;
            } completion:^(BOOL finished) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alertView close];
                    
                    
                });
                
            }];
            
        }
        
    }
}


#pragma mark Promo Notifications

-(void)showNotificationBand:(NSArray *)payLoad{
    if(offerBand!=nil){
        [offerBand.view removeFromSuperview];
        offerBand = nil;
    }
    offerBand=[[OfferBand alloc]initWithNibName:@"OfferBand" bundle:[NSBundle mainBundle]];
    UISwipeGestureRecognizer *onNavigationswipeRight = [[UISwipeGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(onOfferBandSwipeRight:)];
    [onNavigationswipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [offerBand.view addGestureRecognizer:onNavigationswipeRight];
    //offerBand.delegate = self;
    CGRect parentFrame=self.vwTopBar.frame;
    CGRect frameKey=offerBand.view.frame;
    
    
    if(self.btnVolume.isHidden == YES){
        frameKey.origin.y = parentFrame.origin.y + parentFrame.size.height + 10;
    }
    else{
        
        CGRect volumeFRame = self.btnVolume.frame;
        frameKey.origin.y = volumeFRame.origin.y + volumeFRame.size.height + 10;
    }
    frameKey.origin.x = self.view.frame.size.width + 30;
    offerBand.view.frame = frameKey;
    CGRect newFrame = offerBand.view.frame;
    [offerBand.btnOfferBand addTarget:self
                               action:@selector(onNavigationBandTapped:)
     
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:offerBand.view];
    newFrame.origin.x = self.view.frame.size.width - frameKey.size.width;
    
    promoData = payLoad;
    NSArray *imageNameArray = [[NSArray alloc] initWithObjects:@"offer_band_blue.png", @"offer_band_orange.png", @"offer_band_pink.png", @"offer_band_purple.png", nil];
    
    NSArray *promoMessage = [[NSArray alloc] initWithObjects:@"awesome offers nearby", @"great offers nearby", @"exciting offers nearby", @"awesome deals nearby", @"great deals nearby",@"exciting deals nearby", nil];
    int nextColorSet=arc4random_uniform((uint32_t)[imageNameArray count]);
    do{
        nextColorSet=arc4random_uniform((uint32_t)[imageNameArray count]);
    }while (nextColorSet==nextOfferColorset);
    nextOfferColorset=nextColorSet;
    UIImage *image = [UIImage imageNamed:[imageNameArray objectAtIndex:nextColorSet]];
    NSString *strChoseTitle = [promoMessage objectAtIndex:arc4random_uniform((uint32_t)[promoMessage count])];
    
    [offerBand.btnOfferBand setBackgroundImage:image forState:UIControlStateNormal];
    if(promoData.count == 1){
        strChoseTitle  = [strChoseTitle stringByReplacingOccurrencesOfString:@"offers" withString:@"offer"];
        strChoseTitle  = [strChoseTitle stringByReplacingOccurrencesOfString:@"deals" withString:@"deal"];
    }
    if(promoData.count>1){
        offerBand.lblOfferTitle.text = [NSString stringWithFormat:@"%d %@", (int)promoData.count,strChoseTitle];
    }
    else{
        offerBand.lblOfferTitle.text = [NSString stringWithFormat:@"%d %@", (int)promoData.count,strChoseTitle];
    }
    
    [UIView animateWithDuration:0.3f  animations:^{
        offerBand.view.frame=newFrame;
    } completion:^(BOOL finished) {
        
        double delayInSeconds = 10.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self hideNavigationBand];
                       });
    }];
    
    
    
    IntripperEnvironment *en=[IntripperEnvironment instance];
    for(NSDictionary *offer in promoData){
        [en addinpushoffers:offer];
    }
   
}

- (void)onOfferBandSwipeRight:(UITapGestureRecognizer *)recognizer {
    [self hideNavigationBand];
}

-(void)hideNavigationBand{
       CGRect hideFrame = offerBand.view.frame;
    hideFrame.origin.x = 350;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        offerBand.view.frame = hideFrame;
    } completion:^(BOOL finished) {
        [offerBand.view removeFromSuperview];
    }];
    
}

- (IBAction)onNavigationBandTapped:(UIButton *)sender {
   
    //[self showDetails];
}


#pragma  mark Search Operations

-(void)sendSearchRequest:(NSString *)typedString{
    if(searchlist !=nil){
        [searchlist startSearch:typedString];
    }
    
}

-(void)setAmenitiesText:(NSString *)searchText{
    self.txtSearchOption.text = searchText;
    self.btnSearch.alpha = 0;
    self.btnCancel.alpha = 1;
    self.btnSearch.userInteractionEnabled=NO;
    self.btnCancel.userInteractionEnabled = YES;
}

-(void)ShowTextSearch:(id)sender andText:(NSString *)search{
    if (searchlist==nil) {
        UIStoryboard *pageUI = [UIStoryboard storyboardWithName:@"MapMain" bundle:nil];
        searchlist = [pageUI instantiateViewControllerWithIdentifier:@"ID_SEARCH"];
        searchlist.txtSearchTerm = search;
        searchlist.areaSearchdelegate = self;
        UIView *callingView=(UIView *)sender;
        CGRect callingFrame=callingView.frame;
        CGPoint locationin=[callingView.superview convertPoint:callingFrame.origin toView:self.view];
        CGRect newViewSystem=self.view.frame;
        newViewSystem.origin.y=locationin.y+callingView.frame.size.height+12;
        if (newViewSystem.origin.y<0) {
            searchlist=nil;
            return;
        }
        newViewSystem.size.height=newViewSystem.size.height- newViewSystem.origin.y;
        searchlist.view.frame=newViewSystem;
        searchlist.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:searchlist.view];
        [searchlist openAnimation];
        
    }
    else{
        if (searchlist.view.superview==nil) {
            [self.view addSubview:searchlist.view];
            
            [searchlist openAnimation];
            searchlist.txtSearchTerm = search;
            [searchlist startSearch:self.txtSearchOption.text];
            
        }
        else{
            searchlist.txtSearchTerm = search;
            [searchlist startSearch:search];
        }
        
    }
}

- (IBAction)onSearchTap:(id)sender {
    self.txtSearchOption.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.txtSearchOption becomeFirstResponder];
    CGAffineTransform searchShift=CGAffineTransformIdentity;
    CGAffineTransform cancelShift=CGAffineTransformIdentity;
    self.txtSearchOption.alpha=0;
    self.txtSearchOption.transform=searchShift;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.txtSearchOption.alpha=1;
        self.btnCancel.alpha = 0;
        self.btnCancel.transform=cancelShift;
        
    } completion:^(BOOL finished) {
        self.btnSearch.userInteractionEnabled=NO;
        self.lblVenueName.alpha = 0;
        self.btnGoBack.alpha = 0;
        self.btnGoBack.userInteractionEnabled = NO;
        self.btnGoToMap.alpha = 1;
        self.btnGoToMap.userInteractionEnabled = YES;
        [self ShowTextSearch:self.txtSearchOption andText:@""];
    }];
}

- (IBAction)onCancelAction:(id)sender {
    self.txtSearchOption.text=@"";
    self.btnCancel.alpha = 0;
    self.btnSearch.alpha = 1;
    self.btnCancel.userInteractionEnabled = NO;
    [self ShowTextSearch:self.txtSearchOption andText:@""];
    self.vwStoreDetail.hidden=TRUE;
    [self removeMarkers];
    self.txtSearchOption.userInteractionEnabled = YES;
    return;
    CGRect placeControlFrame=self.vwTopBar.frame;
    if (CGAffineTransformIsIdentity(self.txtSearchOption.transform) ) {
        
        CGAffineTransform searchShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform cancelShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform searchButtonShift=CGAffineTransformIdentity;
        self.txtSearchOption.transform=searchShift;
        self.btnSearch.transform=searchButtonShift;
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.txtSearchOption.alpha=0;
            self.btnCancel.transform=cancelShift;
            
        } completion:^(BOOL finished) {
            [self.txtSearchOption resignFirstResponder];
            self.btnSearch.alpha = 1;
            self.lblVenueName.alpha = 1;
            self.btnGoBack.alpha = 1;
            self.btnCancel.alpha = 0;
            self.btnGoBack.userInteractionEnabled = YES;
            self.btnSearch.userInteractionEnabled=YES;
        }];
        [self CloseSearchList];
        self.txtSearchOption.text=@"";
    }
}

-(void)CloseSearchList{
    if (searchlist.view.superview!=nil) {
        [searchlist closeAnimation];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [searchlist.view removeFromSuperview];
            searchlist=nil;
            
        });
    }
}

- (IBAction)searchEntered:(UITextField *)sender {
    self.btnSearch.alpha = 0;
    self.btnCancel.alpha = 1;
    self.btnSearch.userInteractionEnabled=NO;
    self.btnCancel.userInteractionEnabled = YES;
    
    if(searchlist !=nil){
        searchlist.txtSearchTerm = sender.text;
        searchlist.storeTable.userInteractionEnabled = NO;
        if(sender.text.length > 1){
            [self performSelector:@selector(sendSearchRequest:) withObject:sender.text afterDelay:0.8f];
        }
        else if([sender.text isEqualToString:@""]){
            [self performSelector:@selector(sendSearchRequest:) withObject:sender.text afterDelay:0.8f];
        }
        
    }
}

- (IBAction)onMoveBack:(UIButton *)sender {
    
}

- (IBAction)goBackToMap:(UIButton *)sender {
    CGRect placeControlFrame=self.vwTopBar.frame;
    [self hideMapAsset:NO];
    if (CGAffineTransformIsIdentity(self.txtSearchOption.transform) ) {
        
        CGAffineTransform searchShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform cancelShift=CGAffineTransformMakeTranslation(placeControlFrame.size.width-self.txtSearchOption.frame.origin.x,0);
        CGAffineTransform searchButtonShift=CGAffineTransformIdentity;
        self.txtSearchOption.transform=searchShift;
        self.btnSearch.transform=searchButtonShift;
        
        [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.txtSearchOption.alpha=0;
            self.btnCancel.transform=cancelShift;
            
        } completion:^(BOOL finished) {
            [self.txtSearchOption resignFirstResponder];
            self.btnSearch.alpha = 1;
            self.lblVenueName.alpha = 1;
            self.btnGoBack.alpha = 1;
            self.btnCancel.alpha = 0;
            self.btnGoBack.userInteractionEnabled = YES;
            self.btnSearch.userInteractionEnabled=YES;
            self.btnGoToMap.alpha = 0;
            self.btnGoToMap.userInteractionEnabled = NO;
           
        }];
        [self CloseSearchList];
        
        self.txtSearchOption.text=@"";
        self.txtSearchOption.userInteractionEnabled = YES;
    }
    [self resetTopBarUI];
    self.vwStoreDetail.hidden=TRUE;
    [self ShowNavigationDetail:NO animation:YES];
    [intripperMap exitNavigation];
    [self removeMarkers];
}

-(void)hideKeyBoardWhenScolling{
    [self.txtSearchOption resignFirstResponder];
}

-(void)loadGoogleMapForSearch:(NSString*) storeName storeTime:(NSString *)storeTime storeURL:(NSString *) storeURL storeLevel:(int) storelevel data:(NSMutableDictionary*) data{
    NSString *centeOfArea=[data valueForKey:@"center"];
    NSArray *splitCenter=[centeOfArea componentsSeparatedByString:@","];
    CLLocationCoordinate2D point;
    
    int storeLevel=[[data objectForKey:@"floor"] intValue];
    NSString *store=[data objectForKey:@"store"];
        if(searchlist !=nil){
    
            [self.txtSearchOption resignFirstResponder];
            [searchlist.view removeFromSuperview];
            searchlist = nil;
        }
    if([[data objectForKey:@"origin"] isEqualToString:@"store_match"]){
        point= CLLocationCoordinate2DMake([splitCenter[0] floatValue], [splitCenter[1] floatValue]);
        [intripperMap FindAreaOnMap:point floor:storeLevel];
    }
    else{
        point= CLLocationCoordinate2DMake([splitCenter[0] floatValue], [splitCenter[1] floatValue]);
        [intripperMap FindAreaOnMap:point floor:storeLevel title:store];
    }
}


#pragma mark Slide Up Menu

-(void)addPan{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.vwRouteDetail addGestureRecognizer:panRecognizer];
    self.panRectCoord=self.vwRouteDetail.frame;
}

-(void)dragging:(UIPanGestureRecognizer *)gesture
{
    // Check if this is the first touch
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        // Store the initial touch so when we change positions we do not snap
        self.panCoord = [gesture locationInView:gesture.view];
        [self.view bringSubviewToFront:gesture.view];
        if (routeListWindow==nil) {
            routeListWindow=[[RouteListWindow alloc]initWithNibName:@"RouteListWindow" bundle:[NSBundle mainBundle]];
            routeListWindow.view.frame=CGRectMake(self.panRectCoord.origin.x, self.panRectCoord.origin.y+self.panRectCoord.size.height, self.panRectCoord.size.width, self.panRectCoord.origin.y-64);
            [routeListWindow setData:instructArray];
            [self.vwRouteDetail.superview addSubview:routeListWindow.view];
        }
        
        
    }
    else if(gesture.state == UIGestureRecognizerStateEnded){
        CGPoint newCoord = [gesture locationInView:gesture.view];
        
        // Create the frame offsets to use our finger position in the view.
        float dY = newCoord.y-self.panCoord.y;
        CGRect movePosition;
        NSLog(@"Move with %f",(gesture.view.frame.origin.y+dY));
        if ((gesture.view.frame.origin.y+dY)<=(self.panRectCoord.origin.y/2)) {
            //Shift Up
            movePosition=CGRectMake(self.panRectCoord.origin.x,
                                    64,
                                    gesture.view.frame.size.width,
                                    gesture.view.frame.size.height);
            routeListWindow.view.frame = CGRectMake(movePosition.origin.x,
                                                    movePosition.origin.y+movePosition.size.height,
                                                    routeListWindow.view.frame.size.width,
                                                    routeListWindow.view.frame.size.height);
            
        }
        else{
            //Shift Down;
            movePosition=self.panRectCoord;
            [routeListWindow.view removeFromSuperview];
            routeListWindow=nil;
        }
        [UIView animateWithDuration:.3f animations:^{
            gesture.view.frame=movePosition;
        }];
        
        
    }
    else if(gesture.state ==UIGestureRecognizerStateChanged){
        CGPoint newCoord = [gesture locationInView:gesture.view];
        
        // Create the frame offsets to use our finger position in the view.
        float dY = newCoord.y-self.panCoord.y;
        
        
        gesture.view.frame = CGRectMake(gesture.view.frame.origin.x,
                                        gesture.view.frame.origin.y+dY,
                                        gesture.view.frame.size.width,
                                        gesture.view.frame.size.height);
        routeListWindow.view.frame = CGRectMake(gesture.view.frame.origin.x,
                                                gesture.view.frame.origin.y+dY+gesture.view.frame.size.height,
                                                routeListWindow.view.frame.size.width,
                                                routeListWindow.view.frame.size.height);
        
    }
    
    
}
@end
