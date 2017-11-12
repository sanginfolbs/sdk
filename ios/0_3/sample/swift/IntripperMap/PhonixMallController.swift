//
//  ViewController.swift
//  IntripperMap
//
//  Created by Sang.Mac.04 on 23/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

var alertViewForExitNavigation = CustomMallAlertView()
var intripperMap = IntripperMap()
var newLocationController = LocateViewController?()
var demoview = ArriveToDestinationViewController?()
var searchlist = SearchViewController!()
var routeListWindow = RouteListWindow?()
var conversionBand = Conversion()
var offerBand = OfferBand?()
var locator = IANavigation!()
var reroutingEnable: Bool!
var isConvergenceDone: Bool!
var locationStabilize: Bool!
var locationReadingCount: Int!

@objc class PhonixMallController: UIViewController,IntripperMapDelegate,ArriveToDestinationDelegate,LocateViewDelegate,UIAlertViewDelegate,AwesomeMenuDelegate,IANavigationDelegate,SearchViewDelegate,ConversionBandDelegate{
    
    // MARK: Declarations
    @IBOutlet var vwMap: UIView!
    //Map properties
    @IBOutlet var btnLocate: UIButton!
    @IBOutlet var btnVolume: UIButton!
    @IBOutlet var btnGetDirection: UIButton!
    //Top Bar
    @IBOutlet var vwTopBar: UIView!
    @IBOutlet var vwTopBarContainer: UIView!
    @IBOutlet var lblVenueName: UILabel!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var txtSearchOption: UITextField!
    @IBOutlet var btnGoBack: UIButton!
    @IBOutlet var btnGoToMap: UIButton!
    //Store Bar
    @IBOutlet var vwStoreDetail: UIView!
    @IBOutlet var lblStoreName: UILabel!
    @IBOutlet var lblStoreTime: UILabel!
    @IBOutlet var btnShowPath: UIButton!
    //Instruction Bar
    @IBOutlet var vwTurnByTurn: UIView!
    @IBOutlet var vwTurnDetail: UIView!
    @IBOutlet var imgTurn: UIImageView!
    @IBOutlet var lblTurnInfo: UILabel!
    @IBOutlet var btnNextRoute: UIButton!
    @IBOutlet var btnPreviousRoute: UIButton!
    //Route Detail Bar
    @IBOutlet var vwRouteDetail: UIView!
    @IBOutlet var lblEndPoint: UILabel!
    @IBOutlet var btnStartNavigation: UIButton!
    @IBOutlet var btnCloseNavigation: UIButton!
    @IBOutlet var imgNavigation: UIImageView!
    @IBOutlet var imgCloseNavi: UIImageView!
    @IBOutlet var vwStoreTimeFeet: UIView!
    //Navigation Details
    @IBOutlet var lblEstimatedTime: UILabel!
    @IBOutlet var vwSeparatorOne: UIView!
    @IBOutlet var lblDistanceinFt: UILabel!
    @IBOutlet var vwSeparatorTwo: UIView!
    @IBOutlet var lblLevels: UILabel!
    //Floor Change Bar
    @IBOutlet var vwChangeFloor: UIView!

    var viewUserFloor: NSNumber!
    var viewDesFloor: NSNumber!
    var isNavigationStarted: Bool!
    var estimatedTimeLabelSize: CGSize!
    var distanceinFtFrame: CGRect!
    var estimatedDistanceLabelSize: CGSize!
    var instructArray: NSMutableArray!
    var tapTwiceFloor: Bool!
    var floorList: NSArray!
    var isVolOn: Bool! = true
    var hideBandForCertainTime: Bool! = false
    var allStore: [AnyObject]!
    var isLocationServiceStoped: Bool!
    var currentFloor: Int!
    var promoData: NSArray!
    var nextOfferColorset: Int!
    var singleTapPoint: CGIndoorMapPoint!
    var panCoord: CGPoint!
    var panRectCoord: CGRect!
    var alertView = CustomMallAlertView()
    
    @IBOutlet var floorMenu = AwesomeMenu!()
    var lblSelectedFloorTitle = THLabel()
    var InterActiveMap: Bool!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        intripperMap = IntripperMap()
        intripperMap.view.frame = CGRectMake(0, 0, self.vwMap.bounds.size.width, self.vwMap.bounds.size.height)
        intripperMap.mapdelegate = self
        intripperMap.VenueID = "32"
        intripperMap.useMapboxMap = false
        intripperMap.showStoreDuringNavigation = true;
        intripperMap.floorNumber = 0
        intripperMap.enableFloorSelector = false
        self.vwMap.addSubview(intripperMap.view!)
        intripperMap.autoFit()
        let onNavigationswipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "onNavigationswipeLeft:")
        onNavigationswipeLeft.direction = .Left
        self.vwTurnDetail.addGestureRecognizer(onNavigationswipeLeft)
        let onNavigationswipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "onNavigationswipeRight:")
        onNavigationswipeRight.direction = .Right
        self.vwTurnDetail.addGestureRecognizer(onNavigationswipeRight)
        self.ShowNavigationDetail(false, animation: false)
        self.ShowTurnDetail(false, animation: false)
        IntripperEnvironment.circleButton(self.btnLocate)
        IntripperEnvironment.circleButton(self.btnGetDirection)
        IntripperEnvironment.circleButton(self.btnVolume)
        self.addPan()
        self.imgNavigation.transform = CGAffineTransformMakeRotation(CGFloat( M_PI_4))
        self.btnShowPath.layer.masksToBounds = true;
        self.btnStartNavigation.layer.masksToBounds = true;


    }
    override func viewWillAppear(animated: Bool) {
        nextOfferColorset = -1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
// MARK: Intripper MAP
    func hideMapAsset(Hide: Bool) {
        NSLog("hide Asset %@", Hide ? "Y" : "N")
        if Hide {
            self.btnLocate.hidden=true
            self.btnGetDirection.hidden=true
        }
        else {
            self.btnLocate.hidden=false
            self.btnGetDirection.hidden=false
        }
    }
    
    @IBAction func turnVolOn(sender: UIButton) {
        if self.btnVolume.currentImage!.isEqual(UIImage(named: "ic_volume_on.png")) {
            self.btnVolume.setImage(UIImage(named: "ic_volume_off.png"), forState: .Normal)
            isVolOn = false
        }
        else {
            self.btnVolume.setImage(UIImage(named: "ic_volume_on.png"), forState: .Normal)
            isVolOn = true
        }
    }
    @IBAction func onTapLocateMe(sender : UIButton) {
    
    intripperMap.centerBlueDot()
    }
    
    func removeMarkers() {
        //CLLocationCoordinate2D point = CLLocationCoordinate2DMake(0.0, 0.0);
        //[intripperMap FindAreaOnMap:point floor:-1];
        intripperMap.mapCleanup()
    }
    func intripper(mapView: AnyObject!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D, floor level: Int32) {
        NSLog("Coordinates latitude and longitude are %f and %f", coordinate.latitude, coordinate.longitude)
        let loc: CLLocation = CLLocation(coordinate: coordinate, altitude: 1, horizontalAccuracy: 3.0, verticalAccuracy: 1.0, timestamp: NSDate())
        intripperMap.setBlueDot(loc, onFloor: level)
    }
    
    func intripper(mapView: AnyObject!, didTapAtCoordinate coordinate: CLLocationCoordinate2D, floor level: Int32) {
        NSLog("Coordinates latitude and longitude are %f and %f", coordinate.latitude, coordinate.longitude)
        let tappedPoint: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let areaDetail: NSDictionary! = intripperMap.getTappedAreaInfo(tappedPoint, onFloor: Int32(level))
           if (areaDetail != nil) {
            intripperMap.showMarker(coordinate, floor: Int32(level), title: (areaDetail["store"] as! String))
            self.vwStoreDetail.hidden=false
            self.lblStoreName.text = (areaDetail["store"] as! String)
            self.lblStoreTime.text = self.toCheckStoreIsOpen((areaDetail["hours"] as! String))
            let strFloor: Int = Int((areaDetail["floor"] as! Int))
            singleTapPoint = CGMakeMapPoint(Float(coordinate.latitude),Float(coordinate.longitude),Int32(strFloor))
            self.hideMapAsset(true)
            self.animateStoreBand()
        }
        else {
            self.vwStoreDetail.hidden=true
            self.lblStoreName.text = "Store"
            self.lblStoreTime.text = "Time"
            self.hideMapAsset(false)
        }
    }
    
    
    func intripper(mapView: AnyObject, didTapInfoWindowOfMarker markerDetail: [NSObject : AnyObject]) {
        let markerInfo: NSDictionary! = markerDetail as NSDictionary
        let location: CLLocation = (markerInfo!["location"] as! CLLocation)
        let store: String = (markerInfo["title"] as! String)
        let level: NSNumber = (markerInfo!["level"] as! NSNumber)
        let lInt: Int = Int(level as Int)
        let userLocation: CGIndoorMapPoint = intripperMap.userLocation()
        let destinationPoint: CGIndoorMapPoint! = CGMakeMapPoint(Float(location.coordinate.latitude), Float(location.coordinate.longitude), Int32(lInt))
        intripperMap.FindRoute(userLocation, destination: destinationPoint, uptoDoor: false)
        var displayTitle: String
        if store.rangeOfString(" in ") == nil {
            displayTitle = store
        }
        else {
            var splitArray: [AnyObject] = store.componentsSeparatedByString(" in ")
            displayTitle = splitArray[0] as! String
        }
        self.vwStoreDetail.hidden = true
        self.lblStoreName.text = displayTitle
        self.lblEndPoint.text = "To \(self.lblStoreName.text!)"
        self.ShowNavigationDetail(true, animation: true)
        self.changeTopBarForNavigation()
    }
    
    func intripper(mapView: AnyObject, enterFloorChangeRegion region: [NSObject : AnyObject]) {
        var frameEsc: CGRect = self.vwChangeFloor.frame
        if hideBandForCertainTime! == false
        {
            if self.vwStoreDetail.hidden == false {
                frameEsc.origin.y = self.view.frame.size.height - (2 * self.vwStoreDetail.frame.size.height)
                self.vwChangeFloor.frame = frameEsc
                self.vwChangeFloor.hidden = false
                self.hideMapAsset(true)
            }
            else if intripperMap.CurrentMapMode == NavigationMode_None {
                frameEsc.origin.y = self.view.frame.size.height - self.vwChangeFloor.frame.size.height
                self.vwChangeFloor.frame = frameEsc
                self.vwChangeFloor.hidden = false
                self.hideMapAsset(true)
            }
            else if intripperMap.CurrentMapMode == NavigationMode_TurnByTurn{
                frameEsc.origin.y = self.view.frame.size.height - (2 * self.vwStoreDetail.frame.size.height)
                self.vwChangeFloor.frame = frameEsc
                self.vwChangeFloor.hidden = false
            }
        
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(20 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
             self.HideEscalatorBand()
        }
        }
    }
    
    func intripper(mapView: AnyObject, enterPromoZone Zone: [NSObject : AnyObject], promotion offers: [AnyObject]) {
        self.showNotificationBand(offers)
    }
    
// MARK: Floor Change
    @IBAction func onCloseBandForChangingFloors(sender: UIButton) {
        self.vwChangeFloor.hidden = true
            hideBandForCertainTime=true
        if(intripperMap.CurrentMapMode==NavigationMode_None && self.vwStoreDetail.hidden == true)
        {
            self.hideMapAsset(false)
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), {() -> Void in
                self.ChangeBoolValueForFloorBand()
            })
    }
    
    func HideEscalatorBand() {
        self.vwChangeFloor.hidden = true
        hideBandForCertainTime = true
        if intripperMap.CurrentMapMode == NavigationMode_None && self.vwStoreDetail.hidden == true {
            self.hideMapAsset(false)
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), {() -> Void in
            self.ChangeBoolValueForFloorBand()
        })
    }
    
    func ChangeBoolValueForFloorBand() {
        hideBandForCertainTime = false
    }
    
// MARK: on instruction

    func intripper(mapView: AnyObject!, instruction pathIndex: UInt, pathInfo routeInfo: [NSObject : AnyObject]!) {
            if instructArray.count == 0 {
            return
        }
        let pathInd=Int(pathIndex)
        let data: NSMutableDictionary = instructArray[pathInd] as! NSMutableDictionary
   //     var isTurn: Bool = false
        var f1: NSString = ((data["properties"])!["instruction"] as! String)
        if pathInd == instructArray.count - 1 {
            let range: NSRange = f1.rangeOfString("your destination")
            if range.location == NSNotFound {
                f1 = "\(f1) and arrive at your destination"
            }
        }
        self.lblTurnInfo.text = f1 as String
        if isVolOn == true {
            //        AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc] init];
            //        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.lblTurnInfo.text];
            //        [av speakUtterance:utterance];
            let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
            let utterance: AVSpeechUtterance = AVSpeechUtterance(string: self.lblTurnInfo.text!)
            let systemVersion: Float = CFloat(UIDevice.currentDevice().systemVersion)!
            NSLog("%f", systemVersion)
            if systemVersion >= 9 {
                utterance.rate = 0.45
            }
            else {
                utterance.rate = 0.1
            }
            //0.53f;//
            let voice: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "en-uk")!
            if voice==AVSpeechSynthesisVoice(language: "en-uk") {
                NSLog("Bad Voice")
            }
            utterance.voice = voice
            //en-gb,en-au,en-uk
            //utterance.rate = 0.2f;
            //utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];//en-gb,en-au,en-uk
            utterance.preUtteranceDelay = 0.2
            utterance.postUtteranceDelay = 0.2
            synthesizer.speakUtterance(utterance)
        }
        let orignal: CGRect = self.lblTurnInfo.frame
        self.lblTurnInfo.sizeToFit()
        var resize: CGRect = self.lblTurnInfo.frame
        resize.size.width = orignal.size.width
        self.lblTurnInfo.frame = resize
        //Text center align with ontent
        var centerLable: CGPoint = self.lblTurnInfo.center
        centerLable.y = self.vwTurnDetail.frame.size.height / 2
        self.lblTurnInfo.center = centerLable
        //CGRect centerSize=self.lblPathDetail.frame;
        //centerSize.origin.x=resize.origin.x;
        //centerSize.origin.y=resize.origin.y+10;
        //self.lblPathDetail.frame=centerSize;
        
        var range: NSRange = f1.rangeOfString("left")
        var imageicon: String = ""
        if pathIndex == 0 {
            imageicon = "turn_start_white.png"
        }
        else if pathInd == instructArray.count - 1 {
            imageicon = "finish_flag_white.png"
        }
        else {
            if range.location != NSNotFound {
                imageicon = "turn_left_white.png"
   //             isTurn = true
            }
            else {
                range = f1.rangeOfString("right")
                if range.location != NSNotFound {
                    imageicon = "turn_right_white.png"
    //                isTurn = true
                }
                else {
                    range = f1.rangeOfString("destination")
                    if range.location != NSNotFound {
                        imageicon = "turn_destination_white.png"
                    }
                    else {
                        imageicon = "turn_straight_white.png"
                    }
                }
            }
        }
        
        self.imgTurn.image = UIImage(named: imageicon)
        self.btnPreviousRoute.tag = pathInd - 1
        self.btnNextRoute.tag = pathInd + 1
        self.btnPreviousRoute.hidden = self.btnPreviousRoute.tag == -1 ? true : false
        self.btnNextRoute.hidden = self.btnNextRoute.tag == instructArray.count ? true : false
    }
    
    func onNavigationswipeLeft(recognizer: UITapGestureRecognizer) {
        self.onTapNext(self.btnNextRoute)
    }
    
    func onNavigationswipeRight(recognizer: UITapGestureRecognizer) {
        // Insert your own code to handle swipe right
        self.onTapPrevious(self.btnPreviousRoute)
    }
    
    @IBAction func onTapNext(sender: UIButton) {
        if sender.hidden == false {
            let objTransition: CATransition = CATransition()
            objTransition.duration = 0.2
            objTransition.type = kCATransitionMoveIn
            objTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            objTransition.subtype = kCATransitionFromRight
            self.vwTurnDetail.layer.addAnimation(objTransition, forKey: kCATransitionMoveIn)
            intripperMap.NextStepInstruction()
        }
    }
    
    @IBAction func onTapPrevious(sender: UIButton) {
        if sender.hidden == false {
            let objTransition: CATransition = CATransition()
            objTransition.duration = 0.2
            objTransition.type = kCATransitionMoveIn
            objTransition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
            objTransition.subtype = kCATransitionFromLeft
            self.vwTurnDetail.layer.addAnimation(objTransition, forKey: kCATransitionMoveIn)
            intripperMap.PreviousStepInstruction()
        }
    }
    
    func intripper(mapView: AnyObject!, route routeList: [AnyObject]!) {
    
        instructArray = NSMutableArray()
        var totalDistance: Double = 0
        for row: NSDictionary in routeList as! [NSDictionary] {
            if(instructArray != nil){
            instructArray.removeAllObjects()
            }
            instructArray = row["features"] as! NSMutableArray!
        }
        for feature in instructArray {
            let properties: NSDictionary = (feature["properties"] as! NSDictionary)
            totalDistance = totalDistance + Double((properties["distance"] as! Double))
        }
        let startFrom = instructArray.firstObject!
        let EndTo = instructArray.lastObject!
        self.buildNavBandUI(Int(((startFrom["properties"])!!["level"] as! String))!, endFloor: Int(((EndTo["properties"])!!["level"] as! String))!, totalDistance: totalDistance)
        if (reroutingEnable != nil) {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        intripperMap.StepToInstruction(0)
                    }
                   }
        reroutingEnable = false
    }
// MARK: Store Detail
    func animateStoreBand() {
        UIView.transitionWithView(self.vwStoreDetail, duration: 0.5, options: .TransitionNone, animations: {() -> Void in
            self.vwStoreDetail.frame = CGRectMake(0, self.view.frame.size.height - self.vwStoreDetail.frame.size.height, self.vwStoreDetail.frame.size.width, self.vwStoreDetail.frame.size.height)
            }, completion: { _ in })
    }
    //-(void) setStoreData:(NSString *) storename{
    //    for(int intI = 0; intI < [self.storeList count]; intI++)
    //    {
    //        NSDictionary *dictStore = [self.storeList objectAtIndex:intI];
    //        NSString *strSection = [dictStore objectForKey:@"section"];
    //        if([[strSection lowercaseString] isEqualToString:[storename lowercaseString] ]){
    //            self.previousPageData = [NSMutableDictionary dictionaryWithDictionary:dictStore];
    //            NSDictionary *dictStoreDetails = [dictStore objectForKey:@"more"];
    //            NSString *timeString=[dictStore objectForKey:@"detail"];
    //
    //            if (timeString.length!=0) {
    //                [self toCheckStoreIsOpen:timeString];
    //            }
    //            else{
    //                self.lblStoreTime.text = @"Open Now";
    //            }
    //
    //            NSString * strURL = [NSString stringWithFormat:@"%@%@",[[Enviroment instance] getStoreImagePath],[dictStoreDetails objectForKey:@"section_logo"] ];
    //            self.StoreImg.image = [UIImage  imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]]];
    //
    //            //      [notificationbar.btnStoreIcon setBackgroundImage:self.StoreImg.image forState:normal];
    //            break;
    //
    //        }
    //
    //    }
    //
    //}
    
    func toCheckStoreIsOpen(storeTime: String) -> String {
        var isBetween: String
        let dateArray: NSArray = storeTime.componentsSeparatedByString(",")
        let storeTimeForArray: NSString = dateArray[1] as! NSString
        let arrStoreTime: NSArray = storeTimeForArray.componentsSeparatedByString("-")
        let startTimeString: NSString = arrStoreTime[0].uppercaseString
        let endTimeString: NSString = arrStoreTime[1].uppercaseString
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "hh:mma"
        let nowTimeString: String = formatter.stringFromDate(NSDate())
        let startTime: Int = self.minutesSinceMidnight(formatter.dateFromString(startTimeString as String)!)
        let endTime: Int = self.minutesSinceMidnight(formatter.dateFromString(endTimeString as String)!)
        let nowTime: Int = self.minutesSinceMidnight(formatter.dateFromString(nowTimeString)!)
        if startTime <= nowTime && nowTime <= endTime {
            NSLog("Time is between")
            //      self.lblStoreTime.text = @"Open Now";
            isBetween = "Open Now"
        }
        else {
            NSLog("Time is not between")
            //     self.lblStoreTime.text = @"Closed Now";
            isBetween = "Closed Now"
        }
        return isBetween
    }
    
    func minutesSinceMidnight(date: NSDate) -> Int {
        let components: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: date)
        return 60 * Int(components.hour) + Int(components.minute)
    }
    
    func buildNavBandUI(startFloor: Int, endFloor: Int, var totalDistance: Double) {
        if self.lblEstimatedTime != nil {
            self.lblEstimatedTime.removeFromSuperview()
            self.vwSeparatorOne.removeFromSuperview()
            self.lblDistanceinFt.removeFromSuperview()
            if self.vwSeparatorTwo != nil {
            self.vwSeparatorTwo.removeFromSuperview()
            self.lblLevels.removeFromSuperview()
            }
        }
        self.lblEstimatedTime = UILabel(frame: CGRectMake(0, 5, 120, 20))
        self.lblEstimatedTime.font = UIFont(name: "Helvetica-Light", size: 13)
        self.lblEstimatedTime.textColor = UIColor.whiteColor()
        self.lblEstimatedTime.text = IntripperEnvironment.instance().convertFeetToTimeCustom(totalDistance)
        estimatedTimeLabelSize = self.lblEstimatedTime.textRectForBounds(self.lblEstimatedTime.frame, limitedToNumberOfLines: self.lblEstimatedTime.numberOfLines).size
        self.vwSeparatorOne = UIView(frame: CGRectMake(estimatedTimeLabelSize.width + 5, 11, 8, 8))
        self.vwSeparatorOne.backgroundColor = UIColor.whiteColor()
        IntripperEnvironment.circleView(self.vwSeparatorOne)
        self.lblDistanceinFt = UILabel(frame: CGRectMake(0, 5, 120, 20))
        distanceinFtFrame = self.lblDistanceinFt.frame
        distanceinFtFrame.origin.x = self.vwSeparatorOne.frame.origin.x + self.vwSeparatorOne.frame.size.width + 5
        distanceinFtFrame.origin.y = 5
        distanceinFtFrame.size.width = 80
        distanceinFtFrame.size.height = 20
        self.lblDistanceinFt.frame = distanceinFtFrame
        self.lblDistanceinFt.font = UIFont(name: "Helvetica-Light", size: 13)
        self.lblDistanceinFt.textColor = UIColor(red: 0.043, green: 0.78, blue: 0.706, alpha: 1)
        totalDistance = totalDistance * 3.28
        self.lblDistanceinFt.text = String(format: "%.0f feet", totalDistance)
        self.vwStoreTimeFeet.addSubview(self.lblEstimatedTime)
        self.vwStoreTimeFeet.addSubview(self.vwSeparatorOne)
        self.vwStoreTimeFeet.addSubview(self.lblDistanceinFt)
        if endFloor > startFloor {
            
            estimatedDistanceLabelSize = self.lblDistanceinFt.textRectForBounds(self.lblDistanceinFt.frame, limitedToNumberOfLines: self.lblDistanceinFt.numberOfLines).size
            self.vwSeparatorTwo = UIView(frame: CGRectMake(self.lblDistanceinFt.frame.origin.x + estimatedDistanceLabelSize.width + 5, 11, 8, 8))
            self.vwSeparatorTwo!.backgroundColor = UIColor.whiteColor()
            IntripperEnvironment.circleView(self.vwSeparatorTwo)
            self.vwStoreTimeFeet.addSubview(self.vwSeparatorTwo!)
            self.lblLevels = UILabel(frame: CGRectMake(0, 5, 120, 20))
            var levelsFrame: CGRect = self.lblLevels.frame
            levelsFrame.origin.x = self.vwSeparatorTwo!.frame.origin.x + self.vwSeparatorTwo!.frame.size.width + 5
            levelsFrame.origin.y = 5
            levelsFrame.size.width = 100
            levelsFrame.size.height = 20
            self.lblLevels.frame = levelsFrame
            self.lblLevels.font = UIFont(name: "Helvetica-Light", size: 13)
            self.lblLevels.textColor = UIColor(red: 0.227, green: 0.604, blue: 0.851, alpha: 1)
            if endFloor == 1 {
                self.lblLevels.text = "\(endFloor) level up"
            }
            else {
                self.lblLevels.text = "\(endFloor) levels up"
            }
            self.vwStoreTimeFeet.addSubview(self.lblLevels)
        }
        else if endFloor < startFloor {
            estimatedDistanceLabelSize = self.lblDistanceinFt.textRectForBounds(self.lblDistanceinFt.frame, limitedToNumberOfLines: self.lblDistanceinFt.numberOfLines).size
            self.vwSeparatorTwo = UIView(frame: CGRectMake(self.lblDistanceinFt.frame.origin.x + estimatedDistanceLabelSize.width + 5, 11, 8, 8))
            self.vwSeparatorTwo!.backgroundColor = UIColor.whiteColor()
            IntripperEnvironment.circleView(self.vwSeparatorTwo)
            self.vwStoreTimeFeet.addSubview(self.vwSeparatorTwo!)
            self.lblLevels = UILabel(frame: CGRectMake(0, 5, 120, 20))
            var levelsFrame: CGRect = self.lblLevels.frame
            levelsFrame.origin.x = self.vwSeparatorTwo!.frame.origin.x + self.vwSeparatorTwo!.frame.size.width + 5
            levelsFrame.origin.y = 5
            levelsFrame.size.width = 100
            levelsFrame.size.height = 20
            self.lblLevels.frame = levelsFrame
            self.lblLevels.font = UIFont(name: "Helvetica-Light", size: 13)
            self.lblLevels.textColor = UIColor(red: 0.227, green: 0.604, blue: 0.851, alpha: 1)
            let levelToTravel: Int = startFloor - endFloor
            if levelToTravel == 1 {
                self.lblLevels.text = "\(levelToTravel) level down"
            }
            else {
                self.lblLevels.text = "\(levelToTravel) levels down"
            }
            self.vwStoreTimeFeet.addSubview(self.lblLevels)
        }
        
    }
  // MARK: Navigation
    @IBAction func startTurnByTurnNavi(sender: AnyObject) {
        self.vwStoreDetail.hidden = true
        let userLocation: CGIndoorMapPoint = intripperMap.userLocation()
        intripperMap.FindRoute(userLocation, destination: singleTapPoint, uptoDoor: true)
        self.lblEndPoint.text = "To \(self.lblStoreName.text!)"
        self.ShowNavigationDetail(true, animation: true)
        self.changeTopBarForNavigation()
        
    }
    
    func ShowNavigationDetail(show: Bool, animation withAnimation: Bool) {
        if CGAffineTransformIsIdentity(self.vwRouteDetail.transform) {
            if !show {
                let frameLocation: CGRect = self.vwRouteDetail.frame
                let ct: CGAffineTransform = CGAffineTransformMakeTranslation(0, frameLocation.size.height + 30)
                if withAnimation {
                    UIView.animateWithDuration(0.3, animations: {() -> Void in
                        self.vwRouteDetail.transform = ct
                        }, completion: {(finished: Bool) -> Void in
                    })
                }
                else {
                    self.vwRouteDetail.transform = ct
                }
                self.panRectCoord = self.vwRouteDetail.frame
                // Added to prevent route detail band bug staying at some events.
            }
        }
        else {
            if show {
                self.panRectCoord = self.vwRouteDetail.frame
                NSLog("position %f,%f", self.panRectCoord.origin.x, self.panRectCoord.origin.y)
                let ct: CGAffineTransform = CGAffineTransformIdentity
                if withAnimation {
                    UIView.animateWithDuration(0.3, animations: {() -> Void in
                        self.vwRouteDetail.transform = ct
                        }, completion: {(finished: Bool) -> Void in
                            self.hideMapAsset(true)
                            self.panRectCoord = self.vwRouteDetail.frame
                    })
                }
                else {
                    self.vwRouteDetail.transform = ct
                    self.panRectCoord = self.vwRouteDetail.frame
                }
            }
        }
    }
    
    @IBAction func onTapStartNavigation(sender: UIButton) {
        self.ShowTurnDetail(true, animation: true)
        self.vwTopBar.hidden = true
        self.btnVolume.hidden = false
        self.hideMapAsset(true)
        if newLocationController != nil {
            self.closeSeachLocation(newLocationController!)
        }
        self.btnStartNavigation.hidden = true
        self.imgNavigation.hidden = true
        self.btnStartNavigation.userInteractionEnabled = false
        self.btnCloseNavigation.hidden = false
        self.imgCloseNavi.hidden = false
        self.btnCloseNavigation.userInteractionEnabled = true
        //TODO ADD Instruction here
        intripperMap.StepToInstruction(0)
        //Animate Path to 1 to 15
        //    [self animatePathWidth:_navigationRouteForCurrentFloor];
        self.vwRouteDetail.frame = self.panRectCoord
        if routeListWindow != nil {
            routeListWindow!.view!.removeFromSuperview()
            routeListWindow = nil
        }
    }
    
    @IBAction func onTapCancelNavigation(sender: UIButton) {
        intripperMap.exitNavigation()
        self.vwTopBar.hidden = false
        self.resetTopBarUI()
        self.hideMapAsset(false)
        self.btnVolume.hidden = true
        self.removeMarkers()
        self.ShowNavigationDetail(false, animation: true)
        self.ShowTurnDetail(false, animation: false)
        self.btnStartNavigation.hidden = false
        self.btnStartNavigation.hidden = false
        self.imgNavigation.hidden = false
        self.btnStartNavigation.userInteractionEnabled = true
        self.btnCloseNavigation.hidden = true
        self.imgCloseNavi.hidden = true
        self.btnCloseNavigation.userInteractionEnabled = false
        let placeControlFrame: CGRect = self.vwTopBar.frame
        if CGAffineTransformIsIdentity(self.txtSearchOption.transform) {
            let searchShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
            let cancelShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
            let searchButtonShift: CGAffineTransform = CGAffineTransformIdentity
            self.txtSearchOption.transform = searchShift
            self.btnSearch.transform = searchButtonShift
            UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseInOut, animations: {() -> Void in
                self.txtSearchOption.alpha = 0
                self.btnCancel.transform = cancelShift
                }, completion: {(finished: Bool) -> Void in
                    self.txtSearchOption.resignFirstResponder()
                    self.btnSearch.alpha = 1
                    self.lblVenueName.alpha = 1
                    self.btnGoBack.alpha = 1
                    self.btnCancel.alpha = 0
                    self.btnGoBack.userInteractionEnabled = true
                    self.btnSearch.userInteractionEnabled = true
                    self.btnGoToMap.alpha = 0
                    self.btnGoToMap.userInteractionEnabled = false
                    self.vwStoreDetail.hidden = true
            })
            self.txtSearchOption.text = ""
        }
    }
    
    func ShowTurnDetail(show: Bool, animation withAnimation: Bool) {
        isNavigationStarted = show
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        if show {
            //   [mapView_ animateToViewingAngle:tiltAngle];
        }
        else {
            //    [mapView_ animateToViewingAngle:0];
            //Set Zoom to scale
            //   [mapView_ animateToZoom:zoomRef];
        }
        CATransaction.commit()
        if CGAffineTransformIsIdentity(self.vwTurnByTurn.transform) {
            if !show {
                let frameLocation: CGRect = self.vwTurnByTurn.frame
                let ct: CGAffineTransform = CGAffineTransformMakeTranslation(0, -(frameLocation.size.height + frameLocation.origin.y))
                if withAnimation {
                    UIView.animateWithDuration(0.1, animations: {() -> Void in
                        self.vwTurnByTurn.transform = ct
                        }, completion: {(finished: Bool) -> Void in
                    })
                }
                else {
                    self.vwTurnByTurn.transform = ct
                }
            }
        }
        else {
            if show {
                let ct: CGAffineTransform = CGAffineTransformIdentity
                if withAnimation {
                    UIView.animateWithDuration(0.3, animations: {() -> Void in
                        self.vwTurnByTurn.transform = ct
                        }, completion: {(finished: Bool) -> Void in
                    })
                }
                else {
                    self.vwTurnByTurn.transform = ct
                }
            }
        }
    }
    
    func intripper(mapView: AnyObject, endNavigation navigationState: Bool) {
        alertViewForExitNavigation = CustomMallAlertView()
        alertViewForExitNavigation.diaplogPositionMode = DialogBootom
        alertViewForExitNavigation.object = nil
        let bundle: NSBundle = NSBundle.mainBundle()
        demoview = ArriveToDestinationViewController(nibName: "ArriveToDestinationViewController", bundle: bundle)
        demoview!.view.hidden = false
        demoview!.delegate = self
        alertViewForExitNavigation.containerView = demoview!.vwExitNavPopup
        alertViewForExitNavigation.buttonTitles = []
        alertViewForExitNavigation.onButtonTouchUpInside = {(alertView: CustomMallAlertView!, buttonIndex: Int32) -> Void in
            
            switch buttonIndex {
            case 0:
                //Dismiss view
                self.onTapCancelNavigation(self.btnCloseNavigation)
                alertViewForExitNavigation.close()
            default:
                break
            }
            
        }
        // And launch the dialog
        alertViewForExitNavigation.show()
    }
    
    func HideExitNavigation() {
        if demoview!.vwExitNavPopup.superview != nil {
            self.onTapCancelNavigation(self.btnCloseNavigation)
            alertViewForExitNavigation.close()
        }
    }
    func intripper(mapView: AnyObject!, reRouteWithLocation coordinate: CLLocationCoordinate2D, floor level: Int32) {
       
        let rerouteAlertView: CustomMallAlertView = CustomMallAlertView()
        rerouteAlertView.diaplogPositionMode = DialogBootom
        rerouteAlertView.object = [
            "location" : CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "level" : Int(level)
        ]
        
        let bundle: NSBundle = NSBundle.mainBundle()
        let rerouteView: RerouteViewController = RerouteViewController(nibName: "RerouteViewController", bundle: bundle)
        rerouteView.view.hidden = false
        //calls viewDidLoad
        //[demoview fillDetails:pageData];
        rerouteAlertView.containerView = rerouteView.view!
        rerouteAlertView.buttonTitles = []
        rerouteAlertView.onButtonTouchUpInside = {(alertView: CustomMallAlertView!, buttonIndex: Int32) -> Void in
            var payloaddata: [NSObject : AnyObject] = rerouteAlertView.object as! [NSObject : AnyObject]
            let loc: CLLocation = (payloaddata["location"] as! CLLocation)
            let strLevel: Int = Int((payloaddata["level"] as! Int))
            switch buttonIndex {
            case 0:
                //Dismiss view
                break
            case 2:
                self.abundantNavigation()
                break
            case 1:
                intripperMap.ReRoute(loc.coordinate, floor: Int32(strLevel))
                reroutingEnable = true
                break
            default:
                break
            }
            
            if buttonIndex == 0 {
                
            }
            alertView.close()
        }
        // And launch the dialog
        rerouteAlertView.show()

    }
    
    func abundantNavigation() {
        self.onTapCancelNavigation(self.btnCloseNavigation)
    }
    
    // MARK: Top Bar
    func resetTopBarUI() {
        self.vwRouteDetail.frame = self.panRectCoord
        if routeListWindow != nil {
            routeListWindow!.view!.removeFromSuperview()
            routeListWindow = nil
        }
        self.vwTopBarContainer.backgroundColor = UIColor(red: 0.043, green: 0.78, blue: 0.706, alpha: 1)
        /*#0bc7b4*/
        self.lblVenueName.text = "High Street Phoenix"
        self.btnSearch.hidden = false
        self.btnCancel.hidden = true
        self.txtSearchOption.text = ""
        self.txtSearchOption.alpha = 0
        self.lblVenueName.alpha = 1
        self.btnGoToMap.alpha = 0
        self.btnGoToMap.userInteractionEnabled = false
        self.btnGoBack.alpha = 1
        self.btnGoBack.userInteractionEnabled = true
    }
    
    func changeTopBarForNavigation() {
        self.vwTopBarContainer.backgroundColor = UIColor(red: 0.239, green: 0.306, blue: 0.396, alpha: 1)
        self.lblVenueName.text = "Route Preview"
        self.btnSearch.hidden = true
        self.btnCancel.hidden = true
        self.txtSearchOption.text = ""
        self.txtSearchOption.alpha = 0
        self.lblVenueName.alpha = 1
        self.btnGoToMap.alpha = 1
        self.btnGoToMap.userInteractionEnabled = true
        self.btnGoBack.alpha = 0
        self.btnGoBack.userInteractionEnabled = false
    }
   // MARK: get Direction
    @IBAction func onTapManualDirection(sender: UIButton) {
        if newLocationController == nil {
            let userLocation: CGIndoorMapPoint = intripperMap.userLocation()
            if CGIndoorMapPointIsEmpty(userLocation) {
                newLocationController = LocateViewController(nibName: "LocateViewController", bundle: NSBundle.mainBundle(), fromLocation: CGMakeMapPointEmpty(), fromLocationText: "", toLocation: CGMakeMapPointEmpty(), toLocationText: "")
            }
            else {
                newLocationController = LocateViewController(nibName: "LocateViewController", bundle: NSBundle.mainBundle(), fromLocation: userLocation, fromLocationText: "My Location", toLocation: CGMakeMapPointEmpty(), toLocationText: "")
                self.NewStartLocation("My Location")
            }
            newLocationController!.delegate = self
            //newLocationController.view.frame=self.view.bounds;
            //        newLocationController.view.hidden=NO;
            //        CGRect st=newLocationController.view.frame;
            //        NSLog(@"sameer");
        }
        //    [self stopIdealTimer];
        self.view!.addSubview(newLocationController!.view!)
        self.hideMapAsset(true)
        if CGAffineTransformIsIdentity(self.vwStoreDetail.transform) {
            let placeControlFrame: CGRect = self.vwStoreDetail.frame
            let storeInfoShift: CGAffineTransform = CGAffineTransformMakeTranslation(0, placeControlFrame.size.height)
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.vwStoreDetail.transform = storeInfoShift
                }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    
    func closeSeachLocation(sender: LocateViewController) {
        newLocationController!.view!.removeFromSuperview()
        newLocationController = nil
        if(intripperMap.CurrentMapMode==NavigationMode_Preview || intripperMap.CurrentMapMode==NavigationMode_TurnByTurn)
        {
            self.hideMapAsset(true)
        }
        else
        {
            self.hideMapAsset(false)
        }
    }
    
    func closeSeachLocationWithBarAndPath(sender: LocateViewController) {
        newLocationController!.view!.removeFromSuperview()
        self.onTapCancelNavigation(self.btnCloseNavigation)
        newLocationController = nil
        if(intripperMap.CurrentMapMode==NavigationMode_Preview || intripperMap.CurrentMapMode==NavigationMode_TurnByTurn)
        {
            self.hideMapAsset(true)
        }
        else
        {
            self.hideMapAsset(false)
        }
    }
    
    func NewStartLocation(text: String) {
        let fromLabel: UILabel!
        fromLabel = UILabel()
        fromLabel.attributedText = nil
        fromLabel.text = "From: \(text)"
        fromLabel.boldSubstring(text)
    }
    
    func NewEndLocation(text: String) {
        self.lblEndPoint.attributedText = nil
        self.lblEndPoint.text = "To \(text)"
        self.lblEndPoint.boldSubstring(text)
    }
    
    func getSeachLocation(searchBy: String) {
        //NSArray *test=[[NSArray alloc] init];
        let test: NSArray = intripperMap.AllStoreInformation()
        let filterFor: NSPredicate = NSPredicate(format: "(store CONTAINS[cd] %@)", searchBy)
        let resultArray: NSArray = test.filteredArrayUsingPredicate(filterFor)
        let sort: NSSortDescriptor = NSSortDescriptor(key: "store", ascending: true)
        let sortedArray: NSArray = resultArray.sortedArrayUsingDescriptors([sort])
        if sortedArray.count > 4 {
            let smallArray: [AnyObject] = sortedArray.subarrayWithRange(NSMakeRange(0, 4))
            //Format markers;
            newLocationController?.setSeachLocation(smallArray)
        }
        else {
             newLocationController?.setSeachLocation(sortedArray as [AnyObject])
        }
        NSLog("type kit %@", searchBy)
    }
    
    func locatePathOnMap(sender: LocateViewController) {
        let currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(sender.startPoint.lat) , Double(sender.startPoint.lng))
        let lastLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(sender.endPoint.lat),Double(sender.endPoint.lng))
        NSLog("%d and %d", sender.startPoint.floor, sender.endPoint.floor)
        
//        intripperMap.FindRoute(CGMakeMapPoint(Float(currentLocation.latitude), Float(currentLocation.longitude), sender.startPoint.floor), destination: CGMakeMapPoint(Float(lastLocation.latitude), Float(lastLocation.longitude), sender.endPoint.floor), uptoDoor: true)
        intripperMap.FindRoute(CGMakeMapPoint(Float(lastLocation.latitude), Float(lastLocation.longitude), sender.endPoint.floor), destination: CGMakeMapPoint(Float(currentLocation.latitude), Float(currentLocation.longitude), sender.startPoint.floor), uptoDoor: true)
        self.ShowNavigationDetail(true, animation: true)
        self.btnStartNavigation.hidden = false
        self.hideMapAsset(true)
        //  [self closeSeachLocation:sender];
    }
    
    // MARK: Floor Picker
    
    func intripper(mapView: AnyObject!, floorChange level: Int32) {
        self.floorMenu.setSelected(level)
        var fm: CGRect = self.lblSelectedFloorTitle.frame
 //       var pt: CGPoint = self.btnGetDirection.center
        fm.size = CGSizeMake(150, 40)
        self.lblSelectedFloorTitle.frame = fm
        self.lblSelectedFloorTitle.text = "LEVEL \(floorList[Int(level)]["Title"] as! String)"
        self.lblSelectedFloorTitle.sizeToFit()
        var ptlbl: CGPoint = self.lblSelectedFloorTitle.center
        ptlbl.y = self.floorMenu.startPoint.y
        self.lblSelectedFloorTitle.center = ptlbl

    }
    
    func intripper(mapView: AnyObject!, activeFloorList levels: [AnyObject]!) {
   
        floorList = levels
        let uniqueFloors: NSOrderedSet = NSOrderedSet(array: levels)
   //     let enumerator: NSEnumerator = uniqueFloors.objectEnumerator()
        if uniqueFloors.count > 0 {
            let startItem: AwesomeMenuItem = AwesomeMenuItem(image: UIImage(named: "bg-addbutton.png"), highlightedImage: UIImage(named: "bg-addbutton-highlighted.png"), contentImage: UIImage(named: "icon-plus.png"), highlightedContentImage: UIImage(named: "icon-plus.png"))
            let menus: NSMutableArray = NSMutableArray()
            var item:NSDictionary! = nil
            for var i = 0; i < uniqueFloors.count; i++ {
                item = uniqueFloors.objectAtIndex(i) as! NSDictionary
                let MenuItemImage: UIImage = UIImage(named: "bg-floorback.png")!
                let storyMenuItemImagePressed: UIImage = UIImage(named: "bg-floorback.png")!
                let stringText: String = (item!["Title"] as! String)
                let starMenuItem1: AwesomeMenuItem = AwesomeMenuItem(image: MenuItemImage, highlightedImage: storyMenuItemImagePressed, selectedImage: UIImage(named: "bg-menuitem-selected.png"), contentImage: self.FloorName(stringText, withSize: 12), selectedContentImage: self.FloorNameWhite(stringText, withSize: 12), highlightedContentImage: nil)
                menus.addObject(starMenuItem1)
            }
            self.floorMenu = AwesomeMenu(frame: self.vwMap.bounds, startItem: startItem, optionMenus: menus as [AnyObject])
            self.floorMenu!.delegate = self
            self.floorMenu!.menuWholeAngle = CGFloat(-M_PI_2)
            self.floorMenu!.rotateAngle = CGFloat(M_PI_4)
            self.floorMenu!.farRadius = 120.0
            self.floorMenu!.endRadius = 120.0
            self.floorMenu!.nearRadius = 120.0
            self.floorMenu!.animationDuration = 0.4
            let ct: CGRect = self.view.frame
            let ctMap: CGRect = self.vwMap.frame
            let pt: CGPoint = self.btnGetDirection.center
            if UIScreen.mainScreen().respondsToSelector("scale") && UIScreen.mainScreen().scale == 2.0 {
                self.floorMenu!.startPoint = CGPointMake(28, 90)
            }
            else {
                self.floorMenu!.startPoint = CGPointMake(ct.size.width - 30, ctMap.origin.y + 30)
            }
            self.lblSelectedFloorTitle = THLabel(frame: CGRectMake(50, pt.y - 10, 150, 40))
            self.lblSelectedFloorTitle.font = UIFont(name: "Arial", size: 12)
            self.lblSelectedFloorTitle.textColor = UIColor(red: 0.239, green: 0.220, blue: 0.204, alpha: 1.00)
            self.lblSelectedFloorTitle.numberOfLines = 0
            self.lblSelectedFloorTitle.textAlignment = .Left
            self.view!.insertSubview(self.floorMenu!, belowSubview: self.btnGetDirection)
            self.floorMenu!.setSelected(0)
            self.lblSelectedFloorTitle.text = "LEVEL \(floorList[0]["Title"] as! String)"
            var fm: CGRect = self.lblSelectedFloorTitle.frame
            fm.size = CGSizeMake(150, 40)
            //self.lblSelectedFloorTitle.text=@"sameer";
            self.lblSelectedFloorTitle.sizeToFit()
            self.view!.insertSubview(self.lblSelectedFloorTitle, belowSubview: self.btnGetDirection)
            var ptlbl: CGPoint = self.lblSelectedFloorTitle.center
            ptlbl.y = self.floorMenu!.startPoint.y
            self.lblSelectedFloorTitle.center = ptlbl
        }
    }
    
    func FloorName(nm: String, withSize fontSize: Float) -> UIImage {
        let lblFloorName: THLabel = THLabel()
        lblFloorName.strokeSize = 1.0
        lblFloorName.strokeColor = UIColor(red: 0.918, green: 0.914, blue: 0.890, alpha: 1.00)
        lblFloorName.font = UIFont(name: "Arial", size: CGFloat(fontSize))
        //[UIFont systemFontOfSize:fontSize];
        lblFloorName.textColor = UIColor(red: 0.239, green: 0.220, blue: 0.204, alpha: 1.00)
        //[[UIColor alloc] initWithWhite:.30f alpha:1];
        lblFloorName.numberOfLines = 0
        var fm: CGRect = lblFloorName.frame
        fm.size = CGSizeMake(150, 30)
        lblFloorName.frame = fm
        lblFloorName.text = nm
        lblFloorName.sizeToFit()
        //Center Text
        lblFloorName.textAlignment = .Center
        return IntripperEnvironment.imageWithView(lblFloorName)
    }
    
    func FloorNameWhite(nm: String, withSize fontSize: Float) -> UIImage {
        let lblFloorName: THLabel = THLabel()
        //lbl.strokeSize=1.0;
        //lbl.strokeColor=[UIColor colorWithRed:0.918 green:0.914 blue:0.890 alpha:1.00];
        lblFloorName.font = UIFont(name: "Arial", size:CGFloat(fontSize))
        //[UIFont systemFontOfSize:fontSize];
        lblFloorName.textColor = UIColor.whiteColor()
        //[[UIColor alloc] initWithWhite:.30f alpha:1];
        lblFloorName.numberOfLines = 0
        var fm: CGRect = lblFloorName.frame
        fm.size = CGSizeMake(150, 30)
        lblFloorName.frame = fm
        lblFloorName.text = nm
        lblFloorName.sizeToFit()
        //Center Text
        lblFloorName.textAlignment = .Center
        return IntripperEnvironment.imageWithView(lblFloorName)
    }
    
    func awesomeMenu(menu: AwesomeMenu, didSelectIndex idx: Int) {
        NSLog("Single Tap")
        NSLog("floor tap once")
        tapTwiceFloor = false
        let tapfloor: IntripperFloorButton = IntripperFloorButton(frame: CGRectZero)
        tapfloor.tag = idx
        //   [self onChangeFloorWithOutPositioning:tapfloor];
        intripperMap.changeFloor(Int32(idx))
        menu.setSelected(Int32(idx))
        var fm: CGRect = self.lblSelectedFloorTitle.frame
        //CGPoint pt=self.btngetdirection.center;
        fm.size = CGSizeMake(150, 40)
        self.lblSelectedFloorTitle.frame = fm
        self.lblSelectedFloorTitle.text = "LEVEL \(floorList[idx]["Title"] as! String)"
        self.lblSelectedFloorTitle.sizeToFit()
        var ptlbl: CGPoint = self.lblSelectedFloorTitle.center
        ptlbl.y = self.floorMenu!.startPoint.y
        self.lblSelectedFloorTitle.center = ptlbl
        //    shortcutMenuSelected=[self.MenuList objectAtIndex:idx];
        //    NSString *strTag= [NSString stringWithString:[shortcutMenuSelected objectForKey:@"tag"]];
        //
        //    [self.objInDoorMap ShowNearBy:strTag];//@"unknown"];
    }
    
    func FloorName(ioFloor: Int) -> String {
        let filterFor: NSPredicate = NSPredicate(format: "(iofloor = %d)", ioFloor)
        var resultArray: [AnyObject] = floorList.filteredArrayUsingPredicate(filterFor)
        if resultArray.count > 0 {
            return (resultArray[0]["name"] as! String)
        }
        return "\(ioFloor)"
    }
    
    func awesomeMenuDoubleTap(menu: AwesomeMenu, didSelectIndex idx: Int) {
        NSLog("Double Tap")
        menu.setSelected(Int32(idx))
        var fm: CGRect = self.lblSelectedFloorTitle.frame
        fm.size = CGSizeMake(150, 40)
        self.lblSelectedFloorTitle.frame = fm
        self.lblSelectedFloorTitle.text = "LEVEL \(floorList[idx]["Title"] as! String)"
        self.lblSelectedFloorTitle.sizeToFit()
        var ptlbl: CGPoint = self.lblSelectedFloorTitle.center
        ptlbl.y = self.floorMenu.startPoint.y
        self.lblSelectedFloorTitle.center = ptlbl
        let tapfloor: IntripperFloorButton = IntripperFloorButton(frame: CGRectZero)
        if tapfloor.isEqual(nil){
           
            
        }else {
            tapfloor.tag = idx
            tapTwiceFloor = true
            currentFloor = Int(idx)
            intripperMap.changeFloor(Int32(idx))
            isLocationServiceStoped = false
            self.ConfigIndoorAtlasForFloor()
        }
    }
    
    func awesomeMenuDidFinishAnimationClose(menu: AwesomeMenu) {
        //NSLog(@"Menu was closed!");
    }
    
    func awesomeMenuDidFinishAnimationOpen(menu: AwesomeMenu) {
        //NSLog(@"Menu is open!");
    }
    
    // MARK: Indoor Atlas
    
    func IAlocation(manager: IANavigation, didUpdateLocation newLocation: CGPoint, andLatLng geoPoint: CGIndoorMapPoint, accuracy radius: Double, heading direction: Double) {
        let SDKLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double (geoPoint.lat), Double(geoPoint.lng))
        let newUserLocation: CLLocation = CLLocation(coordinate: SDKLocation, altitude: 1, horizontalAccuracy: 3.0, verticalAccuracy: 1.0, timestamp: NSDate())
        //    userNewPosition=SDKLocation;
        if geoPoint.floor == Int32(currentFloor) {
            intripperMap.setBlueDot(newUserLocation, onFloor: geoPoint.floor)
            //[intripperMap  centerBlueDot];
        }
    }
    
    func discoveringUserLocation(manager: IANavigation) {
    }
    
    func calibrationDone(manager: IANavigation, isBackground onBackground: Bool) {
    }
    
    func calibrationFailed(manager: IANavigation, isBackground onBackground: Bool) {
    }
    
    func fatalError(manager: IANavigation, error errorapi: String) {
        isLocationServiceStoped = true
        //    [self HideConvergenceBand:YES];
        //    Toast *toast = [Toast toastWithMessage:errorapi showBottom:40];
        //    [toast showOnView:self.view];
    }
    
    func walkToFixLocation(manager: IANavigation, info infostring: String) {
    }
    
    func IAlocationUnavailable(manager: IANavigation, error errorapi: String) {
        isLocationServiceStoped = true
    }
    
    func IAlocationAvailable(manager: IANavigation) {
        isLocationServiceStoped = false
    }
    
    func indoorAtlasNorthHeading(northHead: Double) {
    }
    
    func conversionDone(manager: IANavigation) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {() -> Void in
            isConvergenceDone = true
            locationStabilize = true
            self.HideNewConvergenceBand(true)
            intripperMap.centerBlueDot()
        })
    }
    
    func conversionBegin(manager: IANavigation) {
        isConvergenceDone = false
        locationReadingCount = 0
        //Show Conversion Screen
        self.InterActiveMap = true
        self.ShowNewConvergenceBand()
        //[self stopIdealTimer];
    }
    
    func calibrationFinish(manager: IANavigation) {
    }
    
    func convergenceStatus(manager: IANavigation, info infostring: String) {
        NSLog("convergenceStatus: %@", infostring)
        self.setConvergenceMsg(infostring)
    }
    
    func ConfigIndoorAtlasForFloor() {
        do {
            var positionFloor: Int
            positionFloor = Int(currentFloor)
            var apidata: [NSObject : AnyObject] = [
                "graphicID" : intripperMap.LocationFloorRef(CInt(positionFloor)),
                "padding" : "0,0",
                "floor" : positionFloor
            ]
            
            let graphicID: String = (apidata["graphicID"] as! String)
            var serviceActive: Bool = false
            if !(graphicID == "") {
                if locator == nil {
                    locator = IANavigation.init(intripperMap.IAAPIapikey(), hash: intripperMap.IAAPIapiSecret(), floorids: intripperMap.LocationFloorRefID())
                    locator!.Delegate = self
            
                }
                    
                else {
//                    if locator.floorNumber != positionFloor {
//                        //[atlasNavigation StopInDoorAtlas];
//                    }
//                    else {
                        if tapTwiceFloor == true {
                            //[atlasNavigation StopInDoorAtlas];
                        }
                        else {
                            if locator!.isServiceActive() {
                                serviceActive = true
                            }
                      //  }
                    }
                }
                if serviceActive == false {
                    locator!.StartInDoorAtlas(12, andmap: CInt(intripperMap.VenueID)!, andApi: apidata)
                }
               
            }
            
        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//        }
    }
    //MARK: Conversion UI
    func HideConvergenceDialog() {
        
    }
    func setConvergenceMsg(msg: String) {
        if conversionBand.vwConvergence.superview != nil {
            conversionBand.lblConMessage!.text = NSLocalizedString(msg,comment: "Conversion")
            self.slideAnimation(conversionBand.lblConMessage!)
        }
    }
    
    func addedmaskLayer(viewlayer: UIView) -> CALayer! {
        for layer: CALayer in viewlayer.layer.sublayers! {
            if (layer.name == "maskslide") {
                return layer
            }
        }
        return nil

    }
    
    func slideAnimation(targetframe: UILabel) {
        let temp: CALayer! = self.addedmaskLayer(targetframe.superview!)
        if temp != nil {
            temp.removeFromSuperlayer()
            targetframe.hidden = false
        }
        UIGraphicsBeginImageContextWithOptions(targetframe.frame.size, false, 2 * UIScreen.mainScreen().scale)
        targetframe.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let textImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        targetframe.hidden = true
        let textWidth: CGFloat = textImage.size.width
        let textHeight: CGFloat = textImage.size.height
        let textLayer: CALayer = CALayer()
        textLayer.contents = (textImage.CGImage as! AnyObject)
        textLayer.frame = targetframe.frame
        textLayer.name = "maskslide"
        let maskLayer: CALayer = CALayer()
        // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
        // to the same value so the layer can extend the mask image.
        maskLayer.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).CGColor
        maskLayer.contents = (UIImage(named: "MaskSlide.png")!.CGImage as! AnyObject)
        // Center the mask image on twice the width of the text layer, so it starts to the left
        // of the text layer and moves to its right when we translate it by width.
        maskLayer.contentsGravity = kCAGravityCenter
        maskLayer.frame = CGRectMake(-textWidth, 0.0, textWidth * 2, textHeight)
        // Animate the mask layer's horizontal position
        let maskAnim: CABasicAnimation = CABasicAnimation(keyPath: "position.x")
        maskAnim.byValue = Int(textWidth)
        maskAnim.repeatCount = .infinity
        maskAnim.duration = 1.0
        maskLayer.addAnimation(maskAnim, forKey: "slideAnim")
        textLayer.mask = maskLayer
        targetframe.superview!.layer.addSublayer(textLayer)
    }
    
    func ShowNewConvergenceBand() {
        if !self.InterActiveMap {
            return
        }
        if conversionBand.view!.superview == nil {
            alertView = CustomMallAlertView()
            alertView.diaplogPositionMode = DialogTop
            alertView.object = nil
            let bundle: NSBundle = NSBundle.mainBundle()
            conversionBand = Conversion(nibName: "Conversion", bundle: bundle)
            //    FloorChangeDetected.selectFloor=[payLoad objectForKey:@"f"];
            conversionBand.view.hidden = false
            //calls viewDidLoad
            //    [FloorChangeDetected fillDetails:payLoad];
            IntripperEnvironment.circleView(conversionBand.vwOuterCircle)
            IntripperEnvironment.circleView(conversionBand.vwInnerCircle)
            //        conversionBand.lblConMessage.text=NSLocalizedString(@"keep walking my friend", @"ConversionTitle");
            conversionBand.lblConvoTitle!.text = NSLocalizedString("keep walking my friend",comment: "ConversionTitle")
            conversionBand.imgActionDone!.alpha = 0
            conversionBand.imgNeedle!.alpha = 1
            conversionBand.delegate = self
            //conversionBand.imgNeedle.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * (_angle/ 180.0));
            //conversionBand.imgNeedle.layer.anchorPoint = CGPointMake(0.5,0.5);  // Set anchor to top middle.
            alertView.containerView = conversionBand.vwConvergence
            alertView.displayCloseDialog = true
            alertView.buttonTitles = [AnyObject]()
            alertView.onButtonTouchUpInside = {(alertView1: CustomMallAlertView!, buttonIndex: Int32) -> Void in
                //NSDictionary *payloaddata= alertView.object;
                //NSArray *zoneData=[payloaddata objectForKey:@"id"];
                switch buttonIndex {
                case 0: break
                    //Dismiss view
                    
                case 2: break
                    //Change Floor to netxt
                    //                 if (FloorChangeDetected!=nil) {
                    //                     [mapSpace setViewLevel:[FloorChangeDetected.selectFloor intValue]];
                    //                     FloorChangeDetected=nil;
                    //                 }
                    
                case 1:
                    break
                default:
                    break
                }
                
                alertView1.close()
            }
            conversionBand.lblConvoTitle!.hidden = true
            // And launch the dialog
            alertView.show()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() -> Void in
                //[self slideAnimation:conversionBand.lblConvoTitle];
                self.slideAnimation(conversionBand.lblConMessage!)
            })
        }
    }
    
    func HideNewConvergenceBand(animated: Bool) {
        if conversionBand.vwConvergence.superview != nil {
            conversionBand.lblConvoTitle!.layer.removeAllAnimations()
            conversionBand.cancelAnimation()
            conversionBand.lblConvoTitle!.alpha = 0
            conversionBand.lblConMessage!.text = NSLocalizedString("We found you", comment: "Conversion")
            if animated{
                conversionBand.lblConvoTitle!.hidden = true
                UIView.animateWithDuration(3.0, animations: {() -> Void in
                    conversionBand.vwConvergenceBottomBar!.backgroundColor = UIColor(red: 0.227, green: 0.604, blue: 0.851, alpha: 1)
                    conversionBand.vwInnerCircle!.backgroundColor = UIColor(red: 0.043, green: 0.78, blue: 0.706, alpha: 1)
                    conversionBand.imgNeedle!.alpha = 0
                    conversionBand.imgActionDone!.alpha = 1
                    }, completion: {(finished: Bool) -> Void in
                        //            [venueMapView setIntermediateLocationReading:NO];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() -> Void in
                            self.alertView.close()
                            //[self onTapLocateMe:self.btnLocate];
                        })
                })
            }
        }
    }
    
    //MARK: Promo Notification
    
    func showNotificationBand(payLoad: [AnyObject]) {
        if offerBand != nil {
            offerBand!.view!.removeFromSuperview()
            offerBand = nil
        }
        offerBand = OfferBand(nibName: "OfferBand", bundle: NSBundle.mainBundle())
        let onNavigationswipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "onOfferBandSwipeRight:")
        onNavigationswipeRight.direction = .Right
        offerBand!.view!.addGestureRecognizer(onNavigationswipeRight)
        //offerBand.delegate = self;
        let parentFrame: CGRect = self.vwTopBar.frame
        var frameKey: CGRect = offerBand!.view.frame
        if self.btnVolume.hidden == true {
            //        if(mapView_.camera.bearing == 0){
            //
            //            frameKey.origin.y = parentFrame.origin.y + parentFrame.size.height + 10;
            //        }
            //        else{
            //            frameKey.origin.y = parentFrame.origin.y + parentFrame.size.height + 60;
            //        }
            frameKey.origin.y = parentFrame.origin.y + parentFrame.size.height + 10
        }
        else {
            let volumeFRame: CGRect = self.btnVolume.frame
            frameKey.origin.y = volumeFRame.origin.y + volumeFRame.size.height + 10
        }
        frameKey.origin.x = self.view.frame.size.width + 30
        //parentFrame.size.width + frameKey.size.width;
        offerBand!.view.frame = frameKey
        var newFrame: CGRect = offerBand!.view.frame
        offerBand!.btnOfferBand!.addTarget(self, action: "onNavigationBandTapped:", forControlEvents: .TouchUpInside)
        self.view!.addSubview(offerBand!.view!)
        //offerBand.view.transform=CGAffineTransformMakeTranslation(30, 0 );
        newFrame.origin.x = self.view.frame.size.width - frameKey.size.width
        promoData = payLoad
        var imageNameArray: [AnyObject] = ["offer_band_blue.png", "offer_band_orange.png", "offer_band_pink.png", "offer_band_purple.png"]
        var promoMessage: [AnyObject] = ["awesome offers nearby", "great offers nearby", "exciting offers nearby", "awesome deals nearby", "great deals nearby", "exciting deals nearby"]
        var nextColorSet: Int = Int(arc4random_uniform(UInt32(imageNameArray.count)))
        repeat {
            nextColorSet = Int(arc4random_uniform(UInt32(imageNameArray.count)))
        } while nextColorSet == nextOfferColorset
        nextOfferColorset = nextColorSet
        let image: UIImage = UIImage(named: imageNameArray[nextColorSet] as! String)!
        var strChoseTitle: String = promoMessage[Int(arc4random_uniform(UInt32(promoMessage.count)))] as! String
        offerBand!.btnOfferBand!.setBackgroundImage(image, forState: .Normal)
        if promoData.count == 1 {
            strChoseTitle = strChoseTitle.stringByReplacingOccurrencesOfString("offers", withString: "offer")
            strChoseTitle = strChoseTitle.stringByReplacingOccurrencesOfString("deals", withString: "deal")
        }
        
        if promoData.count > 1 {
            offerBand!.lblOfferTitle!.text = "\(Int(promoData.count)) \(strChoseTitle)"
        }
        else {
            offerBand!.lblOfferTitle!.text = "\(Int(promoData.count)) \(strChoseTitle)"
        }
        /*
        [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.5 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        offerBand.view.frame=newFrame;
        } completion:^(BOOL finished) {
        //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        double delayInSeconds = 10.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
        {
        [self hideNavigationBand];
        });
        
        }];
        */
        UIView.animateWithDuration(0.3, animations: {() -> Void in
            offerBand!.view.frame = newFrame
            }, completion: {(finished: Bool) -> Void in
                //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                let delayInSeconds: Double = 10.0
                let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue(), {() -> Void in
                    self.hideNavigationBand()
                })
        })
        let en: IntripperEnvironment = IntripperEnvironment.instance()
        for offer: NSDictionary in promoData as! [NSDictionary]{
            en.addinpushoffers(offer as [NSObject : AnyObject])
        }
    }
    
    func onOfferBandSwipeRight(recognizer: UITapGestureRecognizer) {
        self.hideNavigationBand()
    }
    
    func hideNavigationBand() {
        var hideFrame: CGRect = offerBand!.view.frame
        hideFrame.origin.x = 350
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {() -> Void in
            offerBand!.view.frame = hideFrame
            }, completion: {(finished: Bool) -> Void in
                //notificationbar.view.transform=CGAffineTransformIdentity;
                offerBand!.view!.removeFromSuperview()
        })
    }
    
    @IBAction func onNavigationBandTapped(sender: UIButton) {
        //[self showDetails];
    }
    
    
    // MARK: Search Operations
    
    func sendSearchRequest(typedString: String) {
        if searchlist != nil {
            searchlist!.startSearch(typedString)
        }
    }
    
    func setAmenitiesText(searchText: String) {
        self.txtSearchOption.text = searchText
        self.btnSearch.alpha = 0
        self.btnCancel.alpha = 1
        self.btnSearch.userInteractionEnabled = false
        self.btnCancel.userInteractionEnabled = true
    }
    
    func ShowTextSearch(sender: AnyObject, andText search: String) {
        if searchlist == nil {
            let pageUI:UIStoryboard = UIStoryboard(name: "MapMain", bundle: nil)
            searchlist = pageUI.instantiateViewControllerWithIdentifier("ID_SEARCH") as? SearchViewController
            searchlist!.txtSearchTerm = search
            searchlist!.areaSearchdelegate = self
            let callingView: UIView = (sender as! UIView)
            let callingFrame: CGRect = callingView.frame
            let locationin: CGPoint = callingView.superview!.convertPoint(callingFrame.origin, toView: self.view!)
            var newViewSystem: CGRect = self.view.frame
            newViewSystem.origin.y = locationin.y + callingView.frame.size.height + 12
            if newViewSystem.origin.y < 0 {
                searchlist = nil
                return
            }
            newViewSystem.size.height = newViewSystem.size.height - newViewSystem.origin.y
            searchlist!.view.frame = newViewSystem
            //NSLog(@"new system %f,%f,%f, %f",newViewSystem.origin.x,newViewSystem.origin.y,newViewSystem.size.width,newViewSystem.size.height);
            searchlist!.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            self.view!.addSubview(searchlist!.view!)
            searchlist!.openAnimation()
            //[searchlist getFuzzySearchList];
        }
        else {
            if searchlist!.view.superview == nil {
                self.view!.addSubview(searchlist!.view!)
                searchlist!.openAnimation()
                searchlist!.txtSearchTerm = search
                searchlist!.startSearch(self.txtSearchOption.text!)
            }
            else {
                searchlist!.txtSearchTerm = search
                searchlist!.startSearch(search)
            }
        }
    }
    
    @IBAction func onSearchTap(sender: UIButton) {
        self.txtSearchOption.autocorrectionType = .No
        self.txtSearchOption.becomeFirstResponder()
        let searchShift: CGAffineTransform = CGAffineTransformIdentity
        let cancelShift: CGAffineTransform = CGAffineTransformIdentity
        //CGAffineTransform searchButtonShift=CGAffineTransformMakeTranslation(-(self.btnSearch.frame.origin.x),0);
        //self.btnSearch.transform=searchButtonShift;
        self.txtSearchOption.alpha = 0
        self.txtSearchOption.transform = searchShift
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
            self.txtSearchOption.alpha = 1
            self.btnCancel.alpha = 0
            self.btnCancel.transform = cancelShift
            }, completion: {(finished: Bool) -> Void in
                self.btnSearch.userInteractionEnabled = false
                //self.btnSearch.alpha = 0;
                self.lblVenueName.alpha = 0
                self.btnGoBack.alpha = 0
                self.btnGoBack.userInteractionEnabled = false
                self.btnGoToMap.alpha = 1
                self.btnGoToMap.userInteractionEnabled = true
                //if ([self.txtSearchOption.text isEqualToString:@"search"]) {
                self.ShowTextSearch(self.txtSearchOption, andText: "")
                //}
        })
    }
    
    @IBAction func onCancelAction(sender: AnyObject) {
        self.txtSearchOption.text = ""
        self.btnCancel.alpha = 0
        self.btnSearch.alpha = 1
        self.btnCancel.userInteractionEnabled = false
        self.ShowTextSearch(self.txtSearchOption, andText: "")
        self.vwStoreDetail.hidden=true
        self.removeMarkers()
        self.txtSearchOption.userInteractionEnabled=true
        return
//        let placeControlFrame: CGRect = self.vwTopBar.frame
//        if CGAffineTransformIsIdentity(self.txtSearchOption.transform) {
//            let searchShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
//            let cancelShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
//            let searchButtonShift: CGAffineTransform = CGAffineTransformIdentity
//            self.txtSearchOption.transform = searchShift
//            self.btnSearch.transform = searchButtonShift
//            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
//                self.txtSearchOption.alpha = 0
//                self.btnCancel.transform = cancelShift
//                }, completion: {(finished: Bool) -> Void in
//                    self.txtSearchOption.resignFirstResponder()
//                    self.btnSearch.alpha = 1
//                    self.lblVenueName.alpha = 1
//                    self.btnGoBack.alpha = 1
//                    self.btnCancel.alpha = 0
//                    self.btnGoBack.userInteractionEnabled = true
//                    self.btnSearch.userInteractionEnabled = true
//                    
//            })
//            self.CloseSearchList()
//            self.txtSearchOption.text = ""
//        }
    }
    
    func CloseSearchList() {
        //[searchlist clearSearch];
    if searchlist?.view!.superview != nil {
            searchlist!.closeAnimation()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                searchlist!.view!.removeFromSuperview()
                searchlist = nil
            }
        }
    }
    
    @IBAction func searchEntered(sender: UITextField) {
        self.btnSearch.alpha = 0
        self.btnCancel.alpha = 1
        self.btnSearch.userInteractionEnabled = false
        self.btnCancel.userInteractionEnabled = true
        if searchlist != nil {
            searchlist!.txtSearchTerm = sender.text!
            searchlist!.storeTable.userInteractionEnabled = false
            if ((sender.text?.isEmpty) != nil) {
                self.performSelector("sendSearchRequest:", withObject: sender.text!, afterDelay: 0.8)
                //[searchlist startSearch:sender.text];
            }
            else if (sender.text! == "") {
                self.performSelector("sendSearchRequest:", withObject: sender.text!, afterDelay: 0.8)
                //[searchlist startSearch:sender.text];
            }
        }
    }
    
    func hideKeyBoardWhenScolling() {
        self.txtSearchOption.resignFirstResponder()
    }
    
    
    func loadGoogleMapForSearch(storeName: String!, storeTime: String!, storeURL: String!, storeLevel storelevel: Int32, data: NSMutableDictionary!) {
        
        self.txtSearchOption.userInteractionEnabled = false
        let centeOfArea = data["center"]
        var splitCenter: [AnyObject] = centeOfArea!.componentsSeparatedByString(",")
        var point: CLLocationCoordinate2D
        let storeLevel = CInt((data["floor"] as! Int))
        let store: String = (data["store"] as! String)
        let storeID: String = (data["id"] as! String)
        if searchlist != nil {
            self.txtSearchOption.resignFirstResponder()
            searchlist.view!.removeFromSuperview()
            searchlist = nil
        }
        if ((data["origin"] as! String) == "store_match") {
            point = CLLocationCoordinate2DMake(Double(splitCenter[0] as! String)!, Double(splitCenter[1] as! String)!)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() -> Void in
                //[intripperMap FindAreaOnMap:point floor:storeLevel];
                intripperMap.FindAreaOnMap(storeID)
            })
        }
        else {
            point = CLLocationCoordinate2DMake(Double(splitCenter[0] as! String)!, Double(splitCenter[1] as! String)!)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {() -> Void in
                intripperMap.FindAreaOnMap(point, floor: storeLevel, title: store)
            })
        }

        
    }
    
    @IBAction func onMoveBack(sender: UIButton) {
//        self.navigationController!.popViewControllerAnimated(true)
//        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    @IBAction func goBackToMap(sender: UIButton) {
        let placeControlFrame: CGRect = self.vwTopBar.frame
        self.hideMapAsset(false)
        if CGAffineTransformIsIdentity(self.txtSearchOption.transform) {
            let searchShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
            let cancelShift: CGAffineTransform = CGAffineTransformMakeTranslation(placeControlFrame.size.width - self.txtSearchOption.frame.origin.x, 0)
            let searchButtonShift: CGAffineTransform = CGAffineTransformIdentity
            self.txtSearchOption.transform = searchShift
            self.btnSearch.transform = searchButtonShift
            UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseInOut, animations: {() -> Void in
                self.txtSearchOption.alpha = 0
                self.btnCancel.transform = cancelShift
                }, completion: {(finished: Bool) -> Void in
                    self.txtSearchOption.resignFirstResponder()
                    self.btnSearch.alpha = 1
                    self.lblVenueName.alpha = 1
                    self.btnGoBack.alpha = 1
                    self.btnCancel.alpha = 0
                    self.btnGoBack.userInteractionEnabled = true
                    self.btnSearch.userInteractionEnabled = true
                    self.btnGoToMap.alpha = 0
                    self.btnGoToMap.userInteractionEnabled = false
                    //self.StoreDetailView.hidden = YES;
                    //_hittapPoint.map = nil;
            })
            self.CloseSearchList()
            self.txtSearchOption.text = ""
            self.txtSearchOption.userInteractionEnabled = true
        }
        self.resetTopBarUI()
        self.vwStoreDetail.hidden = true
        self.ShowNavigationDetail(false, animation: true)
        intripperMap.exitNavigation()
        self.removeMarkers()
        //[self exitNavigationMode];
    }
    //MARK: Slide up menu
    func addPan() {
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "dragging:")
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.vwRouteDetail.addGestureRecognizer(panRecognizer)
        self.panRectCoord = self.vwRouteDetail.frame
    }
    
    func dragging(gesture: UIPanGestureRecognizer) {
        // Check if this is the first touch
        if gesture.state == .Began {
            // Store the initial touch so when we change positions we do not snap
            self.panCoord = gesture.locationInView(gesture.view!)
            self.view!.bringSubviewToFront(gesture.view!)
            if routeListWindow == nil {
                routeListWindow = RouteListWindow(nibName: "RouteListWindow", bundle: NSBundle.mainBundle())
                routeListWindow!.view.frame = CGRectMake(self.panRectCoord.origin.x, self.panRectCoord.origin.y + self.panRectCoord.size.height, self.panRectCoord.size.width, self.panRectCoord.origin.y - 64)
                //routeListWindow!.setData = instructArray
                routeListWindow?.setData(instructArray  as [AnyObject])
                self.vwRouteDetail.superview!.addSubview(routeListWindow!.view!)
            }
        }
        else if gesture.state == .Ended {
            let newCoord: CGPoint = gesture.locationInView(gesture.view!)
            // Create the frame offsets to use our finger position in the view.
            //float dX = newCoord.x-self.panCoord.x;
            let dY: CGFloat = newCoord.y - self.panCoord.y
            var movePosition: CGRect
            NSLog("Move with %f", (gesture.view!.frame.origin.y + dY))
            if (gesture.view!.frame.origin.y + dY) <= (self.panRectCoord.origin.y / 2) {
                //Shift Up
                movePosition = CGRectMake(self.panRectCoord.origin.x, 64, gesture.view!.frame.size.width, gesture.view!.frame.size.height)
                routeListWindow!.view.frame = CGRectMake(movePosition.origin.x, movePosition.origin.y + movePosition.size.height, routeListWindow!.view.frame.size.width, routeListWindow!.view.frame.size.height)
            }
            else {
                //Shift Down;
                movePosition = self.panRectCoord
                routeListWindow!.view!.removeFromSuperview()
                routeListWindow = nil
            }
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                gesture.view!.frame = movePosition
            })
        }
        else if gesture.state == .Changed {
            let newCoord: CGPoint = gesture.locationInView(gesture.view!)
            // Create the frame offsets to use our finger position in the view.
            //float dX = newCoord.x-self.panCoord.x;
            let dY: CGFloat = newCoord.y - self.panCoord.y
            gesture.view!.frame = CGRectMake(gesture.view!.frame.origin.x, gesture.view!.frame.origin.y + dY, gesture.view!.frame.size.width, gesture.view!.frame.size.height)
            routeListWindow!.view.frame = CGRectMake(gesture.view!.frame.origin.x, gesture.view!.frame.origin.y + dY + gesture.view!.frame.size.height, routeListWindow!.view!.frame.size.width, routeListWindow!.view!.frame.size.height)
        }
        
    }
}


