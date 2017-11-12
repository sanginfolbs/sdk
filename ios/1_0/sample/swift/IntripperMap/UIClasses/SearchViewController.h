//
//  SearchViewController.h
//  shoppingmall
//
//  Created by Sang.Mac.04 on 22/09/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  SearchViewDelegate<NSObject>

-(void)loadGoogleMapForSearch:(NSString*) storeName storeTime:(NSString *)storeTime storeURL:(NSString *) storeURL storeLevel:(int) storelevel data:(NSMutableDictionary*) data;

-(void)setAmenitiesText:(NSString *)searchText;
-(void)hideKeyBoardWhenScolling;
@optional
-(void)ShowOnMap:(CGPoint )point area:(NSString *)areacover floor:(int)floorid Title:(NSString *)title detail:(NSString *)desc;
- (void)ClickMenu:(id)menu didSelectIndex:(NSInteger)idx;
@end


@interface SearchViewController : UIViewController

@property (nonatomic,retain) NSMutableArray *StoreShoppingPlist;
@property (nonatomic, weak) id <SearchViewDelegate> areaSearchdelegate;
@property (nonatomic, retain) NSNumber *mapid;
@property (nonatomic,retain) UIView *vwDummy;
@property (strong, nonatomic) NSString *txtSearchTerm;
-(void)animateView;
@property (strong, nonatomic) IBOutlet UIView *vwContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblNearby;
@property (strong, nonatomic) IBOutlet UILabel *lblResultsTitle;

@property (strong, nonatomic) IBOutlet UIView *vwAmenities;
@property (weak, nonatomic) IBOutlet UIView *vwNoHistory;

@property (strong, nonatomic) IBOutlet UIView *vwNoResults;
-(IBAction)onAmenitiesTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *storeTable;

-(IBAction)onCloseSearch:(UIButton *)sender;
-(void)openAnimation;
-(void)closeAnimation;
-(void)startSearch:(NSString *) strSearchTerm;
@end
