//
//  SearchViewController.m
//  shoppingmall
//
//  Created by Sang.Mac.04 on 22/09/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//
#import <InTripper/InTripper.h>
#import "SearchViewController.h"
#import "StoreCell.h"
#import "BrandMatchCell.h"
#import "CategoryMatchCell.h"

#import "SearchHistoryCell.h"
#import "UIView+Font.h"
#import "UILabel+Boldify.h"
#import "MySearchHistory.h"
#import "MALL+EXTENDEDClass.h"
#import <intripper/intripper.h>
#import "PhonixMallController.h"
#import "FuzzySearchAPI.h"
#import "GradientProgressView.h"
#import "UILabel+Boldify.h"
#import "indoorio.h"
#import "IntripperEnvironment.h"


@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MapSearchDelegate>{
    BOOL DisplayHeaders;
    NSMutableArray *arrFilteredStores;
    int maxVisibleResults;
    GradientProgressView *progressView;
    //Mixpanel *mixpanel;
    MapSearch *poiSearch;
    MapSearch *aminitySearch;
}
@property (strong, nonatomic) IBOutlet UIView *vwSearchPlace;
@property (strong, nonatomic) IBOutlet UISearchBar *storeSearch;

@property (nonatomic,retain) NSMutableArray *storeList;
@property (nonatomic,retain) NSMutableArray *searchedStores;
@property (strong, nonatomic) IBOutlet UIView *vwOptions;
@property (retain, nonatomic)  NSMutableArray *MenuList;
@property (retain, nonatomic)  NSMutableArray *MapAssetList;
@property (retain, nonatomic)  NSMutableArray *SearchHistoryList;
@property (strong, nonatomic) IBOutlet UIView *vwSearchResult;
@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) IBOutlet UIView *vwTitleBox;
@property (strong, nonatomic) IBOutlet UIButton *clearSearchBtn;
@property (strong, nonatomic) IBOutlet UIImageView *imgTitleBox;
@property (strong, nonatomic) IBOutlet UIView *vwBlackBackground;
@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    NSString *name = @"SEARCH_SCREEN";
    
    // The UA-XXXXX-Y tracker ID is loaded automatically from the
    // GoogleService-Info.plist by the `GGLContext` in the AppDelegate.
    // If you're copying this to an app just using Analytics, you'll
    // need to configure your tracking ID here.
    // [START screen_view_hit_objc]
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:name];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    // [END screen_view_hit_objc]
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    mixpanel = [Mixpanel sharedInstance];
    //int mapid=[[Preferences getMap] intValue];
//    self.SearchHistoryList=[NSMutableArray arrayWithArray:[MySearchHistory getSearchHistory:[NSString stringWithFormat:@"areasearch%d",[self.mapid intValue]]]];
    if([self.SearchHistoryList count]>0){
        DisplayHeaders=YES;
    }
    //[self getFilterShoppingList:@""];
    aminitySearch=[[MapSearch alloc] init:Search_Amenity];
    poiSearch=[[MapSearch alloc] init:Search_POI];
    poiSearch.mapSearchDelegate=self;
    aminitySearch.mapSearchDelegate=self;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"SateliteMenu%d",[self.mapid intValue]] ofType:@"plist"];
    self.MenuList=[NSMutableArray arrayWithContentsOfFile:plistPath];
    if ([self.MenuList count]==0) {
        self.vwOptions.hidden=YES;
    }
    self.vwSearchPlace.layer.cornerRadius=5;
    self.vwSearchPlace.layer.masksToBounds=YES;
    /*
     [self.vwSearchPlace.layer setShadowColor:[UIColor blackColor].CGColor];
     [self.vwSearchPlace.layer setShadowOpacity:0.8];
     [self.vwSearchPlace.layer setShadowRadius:1.0];
     [self.vwSearchPlace.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
     
     
     [self.vwSearchResult.layer setShadowColor:[UIColor blackColor].CGColor];
     [self.vwSearchResult.layer setShadowOpacity:0.8];
     [self.vwSearchResult.layer setShadowRadius:1.0];
     [self.vwSearchResult.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
     */
    
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"IntripperBundle" withExtension:@"bundle"]];
    NSString *filePath=[bundle pathForResource:@"direction_box_bg" ofType:@"png"];
    UIImage * backgroundImg = [UIImage imageWithContentsOfFile:filePath];
    backgroundImg = [backgroundImg resizableImageWithCapInsets:UIEdgeInsetsMake(20,20, 20, 20)];
    [self.imgTitleBox setImage:backgroundImg];
    CGRect searchFrame=self.vwSearchPlace.frame;
    CGRect dummyFrame=self.vwDummy.frame;
    searchFrame.origin.x=dummyFrame.origin.x;
    searchFrame.origin.y=dummyFrame.origin.y;
    searchFrame.size.height=dummyFrame.size.height;
    self.vwSearchPlace.frame=searchFrame;
    self.vwSearchPlace.hidden=YES;
    dummyFrame.size.height=dummyFrame.size.height-5;
    self.vwDummy.frame=dummyFrame;
    CGRect amentiesframe = self.vwAmenities.frame;
    CGRect resultsTitleframe = self.lblResultsTitle.frame;
    CGRect nohistoryframe = self.vwNoHistory.frame;
    CGRect noresultsframe = self.vwNoResults.frame;
    
    resultsTitleframe.origin.y=amentiesframe.origin.y+amentiesframe.size.height+10;
    self.lblResultsTitle.frame = resultsTitleframe;
    self.lblResultsTitle.text = @"Recent";

    CGRect tableFrame= self.vwSearchResult.frame;
    //tableFrame.origin.y=searchFrame.origin.y+searchFrame.size.height+10;
    tableFrame.origin.y=resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
    self.vwSearchResult.frame=tableFrame;
    
    nohistoryframe.origin.y = resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
    self.vwNoHistory.frame = nohistoryframe;
    
    noresultsframe.origin.y = resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
    self.vwNoResults.frame = noresultsframe;
    
    if ([self.txtSearchTerm isEqualToString:@""]) {
        NSArray *historyObj=[MySearchHistory getSearchHistory:[NSString stringWithFormat:@"history%@",@"32"]];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"on" ascending:NO];
        NSArray *sortedArray=[historyObj sortedArrayUsingDescriptors:@[sort]];
        arrFilteredStores=[NSMutableArray arrayWithArray:sortedArray];
        self.storeList = arrFilteredStores;
        [self.storeTable reloadData];
        
        float contentHeight;
        maxVisibleResults = 5;
        
        if(arrFilteredStores.count > maxVisibleResults){
            
            //contentHeight = cell.frame.size.height;
            contentHeight=45*maxVisibleResults;
        }
        else{
            contentHeight=45 *[arrFilteredStores count];
        }
        contentHeight = contentHeight + 60;
        if (self.vwSearchResult.bounds.size.height != contentHeight) {
            CGRect Container=self.vwSearchResult.frame;
            Container.size.height=contentHeight;
            self.vwSearchResult.frame=Container;
            //                                              self.storeTable.contentSize = CGSizeMake(self.storeTable.frame.size.width, contentHeight-30);
            self.storeTable.bounces = YES;
        }
        if(arrFilteredStores.count > 0){
            self.vwNoHistory.hidden = YES;
            self.vwSearchResult.hidden = NO;
        }
        else{
            self.vwNoHistory.hidden = NO;
            [self.vwNoHistory setHidden:NO];
            self.vwSearchResult.hidden = YES;
        }
    }
    
    
  //  [self setFilterData];
    [IntripperEnvironment AddBorder:self.vwAmenities];
    [IntripperEnvironment AddBorder:self.vwSearchResult];
    [IntripperEnvironment AddBorder:self.vwNoHistory];
    [IntripperEnvironment AddBorder:self.vwNoResults];
    //[self.txtSearch becomeFirstResponder];
}
-(void)openAnimation{
    self.vwBlackBackground.alpha=1;
    self.view.alpha=0;
    CGRect animateFrame=self.vwBlackBackground.frame;
    CGRect finalanimateFrame=self.vwBlackBackground.frame;
    animateFrame.size.height=0;
    self.vwBlackBackground.frame=animateFrame;
    
    [UIView animateWithDuration:.5f delay:.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.vwBlackBackground.frame=finalanimateFrame;
        self.view.alpha=1;
    } completion:^(BOOL finished) {
        
        //[self getFuzzySearchList];
    }];
    
}
-(void)closeAnimation{
    self.vwBlackBackground.alpha=1;
    CGRect animateFrame=self.vwBlackBackground.frame;
    CGRect finalanimateFrame=self.vwBlackBackground.frame;
    animateFrame.size.height=0;
    [UIView animateWithDuration:0.4f animations:^{
        self.vwBlackBackground.frame=animateFrame;
    } completion:^(BOOL finished) {
        self.vwBlackBackground.alpha=0;
        self.vwBlackBackground.frame=finalanimateFrame;
    }];
}

-(void)animateView{
    [self.view addSubview:self.vwDummy];
    CGRect frameSize=self.vwBlackBackground.frame;
    self.vwBlackBackground.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
    self.vwSearchResult.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
    self.vwOptions.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
    self.vwTitleBox.alpha=0;
    self.vwSearchPlace.alpha=0;
    [UIView animateWithDuration:0.5f animations:^{
        self.vwBlackBackground.transform=CGAffineTransformIdentity;
        self.vwSearchResult.transform=CGAffineTransformIdentity;
        self.vwOptions.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.vwTitleBox.alpha=1;
        self.vwSearchPlace.alpha=1;
        self.vwSearchPlace.hidden=NO;
        [self.vwDummy removeFromSuperview];
    }];
    
    
    
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     self.vwSearchPlace.alpha=1;
     });*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveBack:(UIButton *)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.view addSubview:self.vwDummy];
    self.vwSearchPlace.hidden=YES;
    CGRect frameSize=self.view.frame;
    self.vwTitleBox.alpha=0;
    [UIView animateWithDuration:0.5f animations:^{
        self.vwBlackBackground.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
        self.vwSearchResult.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
        self.vwOptions.transform=CGAffineTransformMakeTranslation(0, frameSize.size.height);
        self.vwDummy.alpha=0;
        
    } completion:^(BOOL finished) {
        self.vwBlackBackground.transform=CGAffineTransformIdentity;
        self.vwSearchResult.transform=CGAffineTransformIdentity;
        self.vwOptions.transform=CGAffineTransformIdentity;
        self.vwTitleBox.alpha=1;
        [self.vwDummy removeFromSuperview];
        [self.view removeFromSuperview];
    }];
    
}
//-(void ) highlightText:(UILabel *)onLabel{
//
//    NSMutableString *textstring=[NSMutableString stringWithString:[onLabel.text lowercaseString]];
//    NSArray *allArray= [[self.txtSearchTerm lowercaseString] componentsSeparatedByString:@" "];
//    for (NSString *item in allArray) {
//        if (![item isEqualToString:@""]) {
//            NSRange range = [textstring rangeOfString:[item lowercaseString]];
//            if (range.location!=NSNotFound) {
//                //Make bold
//                NSString *temp=[onLabel.text substringWithRange:range];
//                //NSLog(@"highlight text for %@",temp);
//                [onLabel boldUnderLineSubstring:temp];
//            }
//        }
//    }
//}


#pragma mark - Table View
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.areaSearchdelegate hideKeyBoardWhenScolling];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.txtSearchTerm isEqualToString:@""]) {
        return 45;
    }
    
    return tableView.rowHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSInteger maxRow=[arrFilteredStores count]>3?3: [arrFilteredStores count];
    return self.storeList.count;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:@"THeader"];
//    if (headerView == nil){
//        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
//    }
//    return headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictStores;
    UITableViewCell *cell;
    
    dictStores = [self.storeList objectAtIndex:indexPath.row];
    NSString *cellType=[dictStores objectForKey:@"origin"];
    if ([cellType isEqualToString:@"category_match"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellInCategory" forIndexPath:indexPath];
        BrandMatchCell *scell=(BrandMatchCell *)cell;
        NSString *titleToDisplay =[NSString stringWithFormat:@"%@",[dictStores valueForKey:@"store"]];
        [scell.lblStoreName setText:titleToDisplay];
        
        
        
        NSString *levelString = [NSString stringWithFormat: @"Level: %@",[[IndoorMapProperties instance] FloorName:[[dictStores valueForKey:@"floor"] intValue]]];
        [scell.lblLevel setText:levelString];
        
        NSString *categoryImage=[[IndoorMapProperties instance] storeCategoryIcon:[dictStores valueForKey:@"id"]];
        UIImage *imgcolor;
        if (categoryImage!=nil) {
            imgcolor=[UIImage imageNamed:[NSString stringWithFormat:@"green-%@",categoryImage]];
        }
        else{
            imgcolor=[UIImage imageNamed:@"green-hanger.png"];
        }
        scell.imgStoreLogo.image=imgcolor;
        
   //     [UIView ChangeAppFont:scell];
        [self highlightText:scell.lblStoreName];
        
        
    }
    else if ([cellType isEqualToString:@"brand_match"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellInCategory" forIndexPath:indexPath];
        BrandMatchCell *scell=(BrandMatchCell *)cell;
        NSString *titleToDisplay =[NSString stringWithFormat:@"%@",[dictStores valueForKey:@"store"]];
        [scell.lblStoreName setText:titleToDisplay];
        
        
        
        NSString *levelString = [NSString stringWithFormat: @"Level: %@",[[IndoorMapProperties instance] FloorName:[[dictStores valueForKey:@"floor"] intValue]]];
        [scell.lblLevel setText:levelString];
        
        NSString *categoryImage=[[IndoorMapProperties instance] storeCategoryIcon:[dictStores valueForKey:@"id"]];
        UIImage *imgcolor;
        if (categoryImage!=nil) {
            imgcolor=[UIImage imageNamed:[NSString stringWithFormat:@"green-%@",categoryImage]];
        }
        else{
            imgcolor=[UIImage imageNamed:@"green-hanger.png"];
        }
        scell.imgStoreLogo.image=imgcolor;
        
   //     [UIView ChangeAppFont:scell];
        [self highlightText:scell.lblStoreName];
        
    }
    else if ([cellType isEqualToString:@"brand_or_category_match"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellInCategory" forIndexPath:indexPath];
        BrandMatchCell *scell=(BrandMatchCell *)cell;
        NSString *titleToDisplay =[NSString stringWithFormat:@"%@",[dictStores valueForKey:@"store"]];
        [scell.lblStoreName setText:titleToDisplay];
        
        
        
        NSString *levelString = [NSString stringWithFormat: @"Level: %@",[[IndoorMapProperties instance] FloorName:[[dictStores valueForKey:@"floor"] intValue]]];
        [scell.lblLevel setText:levelString];
        
        NSString *categoryImage=[[IndoorMapProperties instance] storeCategoryIcon:[dictStores valueForKey:@"id"]];
        UIImage *imgcolor;
        if (categoryImage!=nil) {
            imgcolor=[UIImage imageNamed:[NSString stringWithFormat:@"green-%@",categoryImage]];
        }
        else{
            imgcolor=[UIImage imageNamed:@"green-hanger.png"];
        }
        scell.imgStoreLogo.image=imgcolor;
  //      [UIView ChangeAppFont:scell];
        [self highlightText:scell.lblStoreName];
        //
    }
    else if ([cellType isEqualToString:@"store_match"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"storecell" forIndexPath:indexPath];
        StoreCell *scell=(StoreCell *)cell;
        @try
        {
            //[cell.imgStoreLogo setImage:[UIImage imageNamed:[dictStores valueForKey:@"Icon"]]];
            [scell.lblStoreName setText:[dictStores valueForKey:@"store"]];
            
            NSString *levelString = [NSString stringWithFormat: @"Level: %@",[[IndoorMapProperties instance] FloorName:[[dictStores valueForKey:@"floor"] intValue]]];
            [scell.lblLevel setText:levelString];
            
            NSString *strLogoURL = [dictStores objectForKey:@"logo"];
            scell.strLogoURL = strLogoURL;
            NSString *categoryImage=[[IndoorMapProperties instance] storeCategoryIcon:[dictStores valueForKey:@"id"]];
            UIImage *imgcolor;
            if (categoryImage!=nil) {
                imgcolor=[UIImage imageNamed:[NSString stringWithFormat:@"blue-%@",categoryImage]];
            }
            else{
                imgcolor=[UIImage imageNamed:@"blue-hanger.png"];
            }
            
            scell.imgStoreLogo.image=imgcolor;
            
            
            
    //        [UIView ChangeAppFont:scell];
            [self highlightText:scell.lblStoreName];
        }
        @catch (NSException *exception)
        {
        }
        @finally
        {
        }
    }
    else if ([cellType isEqualToString:@"history"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellInHistory" forIndexPath:indexPath];
        SearchHistoryCell *scell=(SearchHistoryCell *)cell;
        scell.lblsearchText.text=[[dictStores objectForKey:@"result"] objectForKey:@"store"];//[dictStores valueForKey:@"search"];
    //    [UIView ChangeAppFont:scell];
        
    }
    [self stopSearching];
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return DisplayHeaders?tableView.rowHeight:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50;
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    
    //Set the background color of the View
    view.tintColor = [UIColor clearColor];
    
   }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.storeSearch resignFirstResponder];
    NSMutableDictionary *object=[self.storeList objectAtIndex:indexPath.row];
    if (DisplayHeaders) {
        //Show Search with
        self.txtSearch.text=[object objectForKey:@"store"];
        //[self searchChange:self.txtSearch];
    }
    else{if([self.txtSearchTerm isEqualToString:@""]){
        NSMutableDictionary *historyData = [object objectForKey:@"result"];
        NSString *storeName=[historyData objectForKey:@"store"];
        NSString *storeTime=[historyData objectForKey:@"desc"];
        NSString *storeLogo=[historyData objectForKey:@"storelogo"];//[[object
        int storeLevel=[[historyData objectForKey:@"floor"] intValue];
        [self.areaSearchdelegate setAmenitiesText:storeName];
        
        [self.areaSearchdelegate loadGoogleMapForSearch:storeName storeTime:storeTime storeURL:storeLogo storeLevel:storeLevel data:historyData];
        [self moveBack:nil];
    }
    else{
        NSArray *historyObj=[MySearchHistory getSearchHistory:[NSString stringWithFormat:@"history%@",@"32"]];
        NSMutableArray *arry=[NSMutableArray arrayWithArray:historyObj];
        //Remove Duplicate
        NSString *matchString=[object objectForKey:@"store"];
        NSPredicate *containsStoreInfo = [NSPredicate predicateWithBlock: ^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSDictionary* card = evaluatedObject;
            NSDictionary* tagResult = [card objectForKey:@"result"];
            if ([[tagResult objectForKey:@"store"] isEqualToString:matchString]) {
                return YES;
            }
            return NO;
        }];
        
        
        NSArray *resultArray=[arry filteredArrayUsingPredicate:containsStoreInfo];
        if ([resultArray count]>0) {
            [arry removeObjectsInArray:resultArray];
        }
        
        [arry addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"history",@"origin",[self.txtSearchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],@"search",[NSDate date],@"on",object,@"result", nil]];
        if ([arry count]>5) {
            [arry removeObjectAtIndex:0];
        }
        [MySearchHistory SaveHistory:arry WithIdentifier:[NSString stringWithFormat:@"history%@",@"32"]];
        NSString *storeName=[object objectForKey:@"store"];
        NSString *storeTime=[object objectForKey:@"desc"];
        NSString *storeLogo=[object objectForKey:@"storelogo"];//[[object objectForKey:@"more"]objectForKey:@"section_logo"];
        int storeLevel=[[object objectForKey:@"floor"] intValue];
        //NSString *strURL = [NSString stringWithFormat:@"%@%@",defaultStrURL,storeLogo];
//        NSString *storeOrPOI;
//        if ([[object objectForKey:@"origin"] isEqualToString:@"store_match"]) {
//            storeOrPOI=@"Store";
//        }else{
//            storeOrPOI=@"POI";
//        }
        if ([self.txtSearchTerm.lowercaseString isEqualToString:@"restroom"] ||[self.txtSearchTerm.lowercaseString isEqualToString:@"atm"]||[self.txtSearchTerm.lowercaseString isEqualToString:@"cafe"] || [self.txtSearchTerm.lowercaseString isEqualToString:@"info_desk"]) {
            
//            [mixpanel track:@"Amenities Search Event" properties:@{
//                                                       @"Amenity Type": self.txtSearchTerm,
//                                                       @"Selected Amenity name": [object objectForKey:@"store"],
//                                                       @"Searched text": self.txtSearchTerm,
//                                                       @"Was Result Item Selected": @"Yes",
//                                                       @"Match": [object objectForKey:@"origin"],
//                                                       @"Result Count": [NSNumber numberWithInt:self.storeList.count]
//                                                       }];
//           
            }
         else
            {
                /*if ([storeOrPOI isEqualToString:@"Store"]) {
                    [mixpanel track:@"Map Search Event" properties:@{
                                                               @"Searched text": self.txtSearchTerm,
                                                               @"Was Result Item Selected": @"Yes",
                                                               @"Result Count": [NSNumber numberWithInt:self.storeList.count],
                                                               @"Match": [object objectForKey:@"origin"],
                                                               @"Selected Store Name": [object objectForKey:@"store"],
                                                               @"Was Store Selected Or POI": storeOrPOI
                                                               }];
                }
                else{
                     [mixpanel track:@"Map Search Event" properties:@{
                                                                @"Searched text": self.txtSearchTerm,
                                                                @"Was Result Item Selected": @"Yes",
                                                                @"Result Count": [NSNumber numberWithInt:self.storeList.count],
                                                                @"Match": [object objectForKey:@"origin"],
                                                                @"Selected POI Name": [object objectForKey:@"store"],
                                                                @"Was Store Selected Or POI": storeOrPOI
                                                                }];
                    }
                */

            }
        [self.areaSearchdelegate loadGoogleMapForSearch:storeName storeTime:storeTime storeURL:storeLogo storeLevel:storeLevel data:object];
        
        // [self.areaSearchdelegate ShowOnMap:CGPointMake(xSum, ySum) area: [object objectForKey:@"area"] floor:[[object objectForKey:@"level"] intValue] Title:[object objectForKey:@"section"] detail:[object objectForKey:@"detail"]];
        //[self.navigationController popViewControllerAnimated:YES];
        
        //Remove Duplicate
        //            NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(store CONTAINS[c] %@)", self.txtSearch.text];
        //            NSArray *resultArray1=[self.SearchHistoryList filteredArrayUsingPredicate:filterFor];
        //            if ([resultArray1 count]>0) {
        //                [self.SearchHistoryList removeObjectsInArray:resultArray1];
        //            }
        //            NSMutableDictionary *tempObj=[NSMutableDictionary dictionaryWithDictionary:object];
        //            [tempObj setValue:self.txtSearch.text forKey:@"store"];
        //            [self.SearchHistoryList addObject:tempObj];
        //            if ([self.SearchHistoryList count]>3) {
        //                [self.SearchHistoryList removeObjectAtIndex:0];
        //            }
        
        //[MySearchHistory SaveHistory:self.SearchHistoryList WithIdentifier:[NSString stringWithFormat:@"areasearch%d",[self.mapid intValue]]];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self moveBack:nil];
        }
    }
}

#pragma mark search bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //NSLog(@"print %@",searchText);
    if ([searchText isEqualToString:@""]) {
        [searchBar resignFirstResponder];
    }
    [self getFilterShoppingList:searchText];
    [self.storeTable reloadData];
    
}
-(void)getFilterShoppingList:(NSString *)searchFor{
    if ([searchFor isEqualToString:@""]) {
        self.storeList=[NSMutableArray arrayWithArray:[[self.SearchHistoryList mutableCopy] reversedArray]];
        
    }
    else{
        NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(sectionName CONTAINS[cd] %@) OR (SectionDetail CONTAINS[cd] %@) ", searchFor,searchFor];
        NSArray *resultArray=[self.StoreShoppingPlist filteredArrayUsingPredicate:filterFor];
        self.storeList=[NSMutableArray arrayWithArray:resultArray];
    }
    int totalRec=3;
    if ([self.storeList count]<3) {
        totalRec=(int)[self.storeList count];
    }
    CGRect tableFrame= self.storeTable.frame;
    tableFrame.size.height=totalRec*52;
    self.storeTable.frame=tableFrame;
    
    tableFrame= self.vwSearchResult.frame;
    tableFrame.size.height=totalRec*52;
    self.vwSearchResult.frame=tableFrame;
    
    CGRect optionFrame=self.vwOptions.frame;
    
    optionFrame.origin.y= tableFrame.origin.y+tableFrame.size.height+20;
    
    [UIView animateWithDuration:.5f animations:^{
        self.vwOptions.frame=optionFrame;
    }];
    
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    /*for (UIView *searchBarSubview in [searchBar subviews]) {
     if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
     @try {
     
     [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
     [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
     }
     @catch (NSException * e) {
     
     // ignore exception
     }
     }
     }*/
    return YES;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.MenuList.count;
}
/*

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *item=[self.MenuList objectAtIndex:indexPath.row];
    UIImage *starImage = [UIImage imageNamed:[item objectForKey:@"titleImage"]];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    
    recipeImageView.image = starImage;
    UILabel *menuNameView = (UILabel *)[cell viewWithTag:101];
    menuNameView.text=[item objectForKey:@"title"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.areaSearchdelegate ClickMenu:self didSelectIndex:indexPath.row];
    //[self.navigationController popViewControllerAnimated:YES];
    [self moveBack:nil];
    //[self dismissViewControllerAnimated:NO completion:nil];
}
*/
- (IBAction)onAmenitiesTap:(UIButton *)sender {
    switch(sender.tag){
        case 0:
            self.txtSearchTerm = @"restroom";
            [self.areaSearchdelegate setAmenitiesText:@"restroom"];
            break;
        case 1:
            self.txtSearchTerm = @"atm";
            [self.areaSearchdelegate setAmenitiesText:@"atm"];
            break;
        case 2:
            self.txtSearchTerm = @"cafe";
            [self.areaSearchdelegate setAmenitiesText:@"cafe"];
            break;
        case 3:
            self.txtSearchTerm = @"info_desk";
            [self.areaSearchdelegate setAmenitiesText:@"info_desk"];
            break;
    }
    if(sender.tag == 2){
        [self startSearch:self.txtSearchTerm];
    }
    else{
        [self searchAmenities:self.txtSearchTerm];
    }
    
}

-(IBAction)onCloseSearch:(UIButton *)sender{
    
    self.txtSearch.text=Nil;
    NSArray *historyObj=[MySearchHistory getSearchHistory:[NSString stringWithFormat:@"history%@",@"32"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"on" ascending:NO];
    NSArray *sortedArray=[historyObj sortedArrayUsingDescriptors:@[sort]];
    arrFilteredStores=[NSMutableArray arrayWithArray:sortedArray];
    self.storeList = arrFilteredStores;
    [self.storeTable reloadData];
    self.clearSearchBtn.hidden=TRUE;
}


-(void) searchAmenities:(NSString*) strSearchTerm{
    if(strSearchTerm.length > 0){
        DisplayHeaders=NO;
        [aminitySearch searching:[strSearchTerm lowercaseString]];
        
        
//        
//        NSMutableDictionary *req=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"search",@"method",
//                                  @"phoenixmall",@"index",[strSearchTerm lowercaseString],@"amenities",nil];
//        
//        
//        
//        [IntripperApiCall PostData:req result:^(NSArray *posts, NSError *error)
//         {
//             if (error)
//             {
//                 //                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.domain delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
//             }
//             else
//             {
//                 
//                 
//             }
//         }];
    }
}
-(void)startSearch:(NSString *) strSearchTerm{
    self.storeTable.userInteractionEnabled = NO;
    [self.storeList removeAllObjects];
    [arrFilteredStores removeAllObjects];
    
    //dfadsdfs
    //if(strSearchTerm.length > 0){
    
    
    
    
    [self showStartSearching];
    if(strSearchTerm.length > 0){
        DisplayHeaders=NO;
        [poiSearch searching:strSearchTerm];
        
    }
    else{
        [self.storeList removeAllObjects];
        [arrFilteredStores removeAllObjects];
        self.txtSearchTerm = @"";
        NSArray *historyObj=[MySearchHistory getSearchHistory:[NSString stringWithFormat:@"history%@",@"32"]];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"on" ascending:NO];
        NSArray *sortedArray=[historyObj sortedArrayUsingDescriptors:@[sort]];
        arrFilteredStores=[NSMutableArray arrayWithArray:sortedArray];
        self.storeList = arrFilteredStores;
        [self.storeTable reloadData];
        float contentHeight;
        maxVisibleResults = 5;
        
        if(arrFilteredStores.count > maxVisibleResults){
            contentHeight=45*maxVisibleResults;
        }
        else{
            contentHeight=45 *[arrFilteredStores count];
        }
        if (self.vwSearchResult.bounds.size.height != contentHeight) {
            CGRect Container=self.vwSearchResult.frame;
            Container.size.height=contentHeight;
            self.vwSearchResult.frame=Container;
            //                                              self.storeTable.contentSize = CGSizeMake(self.storeTable.frame.size.width, contentHeight-30);
            self.storeTable.bounces = YES;
        }/*
          CGRect amenities=self.vwAmenities.frame;
          amenities.origin.y = self.vwSearchResult.frame.origin.y + self.vwSearchResult.frame.size.height + 20;
          self.vwAmenities.frame = amenities;*/
        self.vwAmenities.hidden = NO;
        self.lblNearby.hidden = NO;
        CGRect amentiesframe = self.vwAmenities.frame;
        CGRect resultsTitleframe = self.lblResultsTitle.frame;
        //CGRect nohistoryframe = self.vwNoHistory.frame;
        
        //nohistoryframe.origin.y = resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
        //self.vwNoHistory.frame = nohistoryframe;
        if(arrFilteredStores.count>0){
            self.vwNoHistory.hidden = YES;
            self.vwSearchResult.hidden = NO;
            self.vwNoResults.hidden = YES;
           
        }
        else{
            self.vwNoHistory.hidden = NO;
            self.vwSearchResult.hidden = NO;
            self.vwNoResults.hidden = YES;
        }
        
        resultsTitleframe.origin.y=amentiesframe.origin.y+amentiesframe.size.height+10;
        self.lblResultsTitle.frame = resultsTitleframe;
        self.lblResultsTitle.text = @"Recent";
        CGRect tableFrame= self.vwSearchResult.frame;
        //tableFrame.origin.y=searchFrame.origin.y+searchFrame.size.height+10;
        tableFrame.origin.y=resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
        self.vwSearchResult.frame=tableFrame;
        [self stopSearching];
    }
}

- (IBAction)searchChange:(UITextField *)sender {
    return;
    
}

-(void)setFilterData{
    return;
    int totalRec=3;
    if ([self.storeList count]<3) {
        totalRec=(int)[self.storeList count];
    }
    int addition=0;
    if (DisplayHeaders) {
        addition=1;
    }
    CGRect tableFrame= self.storeTable.frame;
    tableFrame.size.height=(totalRec+addition)*self.storeTable.rowHeight;
    self.storeTable.frame=tableFrame;
    
    tableFrame= self.vwSearchResult.frame;
    tableFrame.size.height=(totalRec+addition)*self.storeTable.rowHeight;
    self.vwSearchResult.frame=tableFrame;
    
    CGRect optionFrame=self.vwOptions.frame;
    
    optionFrame.origin.y= tableFrame.origin.y+tableFrame.size.height+20;
    
    [UIView animateWithDuration:.5f animations:^{
        self.vwOptions.frame=optionFrame;
    }];
    
}
- (IBAction)exitTextbox:(UITextField *)sender {
    [sender resignFirstResponder];
}

-(void)showStartSearching{
    //    [self.imgLoader setHidden:NO];
    //    [self.imgLoader startAnimating];
    self.storeTable.userInteractionEnabled = NO;
    if(progressView == nil){
        [self setGradientLoader];
    }
    
    [progressView startAnimating];
}
-(void)stopSearching{
    //    [self.imgLoader stopAnimating];
    //    [self.imgLoader setHidden:YES];
    
    //    [progressView stopAnimating];
    //    [progressView removeFromSuperview];
    //    progressView = nil;
    self.storeTable.userInteractionEnabled = YES;
    [progressView stopAnimating];
    [progressView removeFromSuperview];
    progressView = nil;
}

-(void)setGradientLoader{
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 3.0f);
    progressView = [[GradientProgressView alloc] initWithFrame:frame];
    [self.view addSubview:progressView];
    [self simulateProgress];
    
}
- (void)simulateProgress {
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        CGFloat increment = (arc4random() % 5) / 10.0f + 0.1;
        CGFloat progress  = [progressView progress] + increment;
        [progressView setProgress:progress];
        if (progress < 1.0) {
            
            [self simulateProgress];
        }
    });
}
-(void ) highlightText:(UILabel *)onLabel{
    
    NSMutableString *textstring=[NSMutableString stringWithString:[onLabel.text lowercaseString]];
    NSArray *allArray= [[self.txtSearchTerm lowercaseString] componentsSeparatedByString:@" "];
    for (NSString *item in allArray) {
        if (![item isEqualToString:@""]) {
            NSRange range = [textstring rangeOfString:[item lowercaseString]];
            if (range.location!=NSNotFound) {
                //Make bold
                NSString *temp=[onLabel.text substringWithRange:range];
                //NSLog(@"highlight text for %@",temp);
                [onLabel boldUnderLineSubstring:temp];
            }
        }
    }
}

#pragma mark search API
- (void)searchDidStartLoad:(MapSearch *)sender{
     [self showStartSearching];
}
- (void)searchDidFinishLoad:(MapSearch *)sender result:(NSArray *)response{
    [self stopSearching];
    if ([sender isEqual:poiSearch]) {
        //Show POI Result
        if ([response count]>0)
        {
            arrFilteredStores=[NSMutableArray arrayWithArray:response];
            self.storeList = arrFilteredStores;
            
            //        [self.view endEditing:YES];
            /*
             NSSortDescriptor *sortDescriptor;
             sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section"
             ascending:YES];
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             NSArray *sortedArray = [posts sortedArrayUsingDescriptors:sortDescriptors];
             self.storeList=[NSMutableArray arrayWithArray:sortedArray];
             NSLog(@"Store from search %@",self.storeList);
             */
            float contentHeight;
            [self.storeTable reloadData];
            maxVisibleResults = 5;
            
            if(arrFilteredStores.count > maxVisibleResults){
                contentHeight=self.storeTable.rowHeight*maxVisibleResults;
            }
            else{
                contentHeight=self.storeTable.rowHeight *[arrFilteredStores count] ;
            }
            if (self.vwSearchResult.bounds.size.height != contentHeight) {
                CGRect Container=self.vwSearchResult.frame;
                Container.size.height=contentHeight;
                self.vwSearchResult.frame=Container;
                //                                              self.storeTable.contentSize = CGSizeMake(self.storeTable.frame.size.width, contentHeight-30);
                self.storeTable.bounces = YES;
            }/*
              CGRect amenities=self.vwAmenities.frame;
              amenities.origin.y = self.vwSearchResult.frame.origin.y + self.vwSearchResult.frame.size.height + 20;
              self.vwAmenities.frame = amenities;*/
            CGRect resultsTitleframe = self.lblResultsTitle.frame;
            resultsTitleframe.origin.y = 10;
            self.lblResultsTitle.frame = resultsTitleframe;
            CGRect tableFrame= self.vwSearchResult.frame;
            //tableFrame.origin.y=searchFrame.origin.y+searchFrame.size.height+10;
            tableFrame.origin.y=resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
            self.vwSearchResult.frame=tableFrame;
            self.vwAmenities.hidden= YES;
            self.lblNearby.hidden = YES;
            self.lblResultsTitle.text = @"Search Results";
            self.vwSearchResult.hidden = NO;
            [self.storeTable reloadData];
            //   [self setFilterData];
            self.vwNoResults.hidden = YES;
            self.vwNoHistory.hidden = YES;
            self.vwSearchResult.hidden = NO;
        }
        else{
            [self.storeList removeAllObjects];
            [self.storeTable reloadData];
            [self setFilterData];
            [self stopSearching];
            CGRect noresultsframe = self.vwNoResults.frame;
            CGRect resultsTitleframe = self.lblResultsTitle.frame;
            resultsTitleframe.origin.y = 10;
            noresultsframe.origin.y = resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
            self.vwNoResults.frame = noresultsframe;
            self.vwNoResults.hidden = NO;
            //                     [mixpanel track:@"Map Search Event" properties:@{
            //                                                                      @"Result Count": [NSNumber numberWithUnsignedInteger:self.storeList.count],
            //                                                                      @"Searched text": strSearchTerm}];
            //
            self.vwSearchResult.hidden = YES;
            self.vwNoHistory.hidden = NO;

        }
    }
    else{
        if ([response count]>0)
        {
            arrFilteredStores=[NSMutableArray arrayWithArray:response];
            self.storeList = arrFilteredStores;
            
            //        [self.view endEditing:YES];
            /*
             NSSortDescriptor *sortDescriptor;
             sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section"
             ascending:YES];
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             NSArray *sortedArray = [posts sortedArrayUsingDescriptors:sortDescriptors];
             self.storeList=[NSMutableArray arrayWithArray:sortedArray];
             NSLog(@"Store from search %@",self.storeList);
             */
            float contentHeight;
            [self.storeTable reloadData];
            maxVisibleResults = 5;
            
            if(arrFilteredStores.count > maxVisibleResults){
                contentHeight=self.storeTable.rowHeight*maxVisibleResults;
            }
            else{
                contentHeight=self.storeTable.rowHeight *[arrFilteredStores count] ;
            }
            if (self.vwSearchResult.bounds.size.height != contentHeight) {
                CGRect Container=self.vwSearchResult.frame;
                Container.size.height=contentHeight;
                self.vwSearchResult.frame=Container;
                //                                              self.storeTable.contentSize = CGSizeMake(self.storeTable.frame.size.width, contentHeight-30);
                self.storeTable.bounces = YES;
            }/*
              CGRect amenities=self.vwAmenities.frame;
              amenities.origin.y = self.vwSearchResult.frame.origin.y + self.vwSearchResult.frame.size.height + 20;
              self.vwAmenities.frame = amenities;*/
            CGRect resultsTitleframe = self.lblResultsTitle.frame;
            resultsTitleframe.origin.y = 10;
            self.lblResultsTitle.frame = resultsTitleframe;
            CGRect tableFrame= self.vwSearchResult.frame;
            //tableFrame.origin.y=searchFrame.origin.y+searchFrame.size.height+10;
            tableFrame.origin.y=resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
            self.vwSearchResult.frame=tableFrame;
            self.vwAmenities.hidden= YES;
            self.lblNearby.hidden = YES;
            self.lblResultsTitle.text = @"Search Results";
            self.vwSearchResult.hidden = NO;
            [self.storeTable reloadData];
            //   [self setFilterData];
            self.vwNoResults.hidden = YES;
            self.vwNoHistory.hidden = YES;
            self.vwSearchResult.hidden = NO;
        }
        else{
            [self.storeList removeAllObjects];
            [self.storeTable reloadData];
            [self setFilterData];
            [self stopSearching];
            CGRect noresultsframe = self.vwNoResults.frame;
            CGRect resultsTitleframe = self.lblResultsTitle.frame;
            resultsTitleframe.origin.y = 10;
            noresultsframe.origin.y = resultsTitleframe.origin.y+resultsTitleframe.size.height+10;
            self.vwNoResults.frame = noresultsframe;
            self.vwNoResults.hidden = NO;
            //                     [mixpanel track:@"Map Search Event" properties:@{
            //                                                                      @"Result Count": [NSNumber numberWithUnsignedInteger:self.storeList.count],
            //                                                                      @"Searched text": strSearchTerm}];
            //
            self.vwSearchResult.hidden = YES;
            self.vwNoHistory.hidden = NO;
        }
    
    }
}

@end
