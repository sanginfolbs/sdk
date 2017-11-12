//
//  LocateViewController.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 01/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InTripper/InTripper.h>
/**
 *  <<Deprecated>>
 */
@class LocateViewController;

@protocol  LocateViewDelegate<NSObject>
-(void)getSeachLocation:(NSString *)searchBy;
-(void)closeSeachLocation:(LocateViewController *)sender;
-(void)closeSeachLocationWithBarAndPath:(LocateViewController *)sender;
-(void)locatePathOnMap:(LocateViewController *)sender;
@optional
-(void)NewStartLocation:(NSString *)text;
-(void)NewEndLocation:(NSString *)text;

@end

@interface LocateViewController : UIViewController{
  
}
@property(nonatomic,readonly,getter=destination) CGIndoorMapPoint startPoint;
@property(nonatomic,readonly,getter=start) CGIndoorMapPoint endPoint;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fromLocation:(CGIndoorMapPoint)f fromLocationText:(NSString *)from  toLocation:(CGIndoorMapPoint)t toLocationText:(NSString *)to;
@property(weak) id<LocateViewDelegate> delegate;
- (void)setSeachLocation:(NSArray *)searchResult;
-(void)startSelectingOnMap;
-(void)SelectedOnMap:(CGIndoorMapPoint)t toLocationText:(NSString *)to;
@end
