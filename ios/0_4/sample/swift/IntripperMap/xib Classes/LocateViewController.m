//
//  LocateViewController.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 01/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "LocateViewController.h"
#import "LocateTableViewCell.h"
#import "UIColor+Expanded.h"
#import "IntripperEnvironment.h"
#import "UIView+Font.h"

@interface LocateViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
      NSString *startTitle,*endTitle;
    BOOL taptoClose;
    CGRect fullScreenView;
    UITextField *anchorView;
}
@property (strong, nonatomic) IBOutlet UITextField *txtFromLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtToLocation;
@property (strong, nonatomic) IBOutlet UITableView *tblSearchResult;
@property (retain, nonatomic)  NSMutableArray *listSearchResult;
@property (strong, nonatomic) IBOutlet UIView *vwBackground;
@property (strong, nonatomic) IBOutlet UIView *vwIcon;
@property (strong, nonatomic) IBOutlet UIView *vwLine;
@property (strong, nonatomic) IBOutlet UIButton *btnTapToNavigate;

@end

@implementation LocateViewController
@synthesize startPoint,endPoint;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fromLocation:(CGIndoorMapPoint)f fromLocationText:(NSString *)from  toLocation:(CGIndoorMapPoint)t toLocationText:(NSString *)to{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    startPoint=f;
    endPoint=t;
    startTitle=from;
    endTitle=to;
    taptoClose=NO;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.txtFromLocation.text=startTitle;
    self.txtToLocation.text=endTitle;
    self.vwBackground.transform=CGAffineTransformMakeTranslation(0, -(self.vwBackground.frame.size.height+self.vwBackground.frame.origin.y));
    self.vwIcon.alpha=0;
    self.vwLine.alpha=0;
    self.btnTapToNavigate.alpha=0;
    if (CGIndoorMapPointIsEmpty( startPoint)) {
        [self.txtFromLocation becomeFirstResponder];
    }
    else{
        [self.txtToLocation becomeFirstResponder];
    }
    
    [UIView ChangeAppFont:self.view];
    self.tblSearchResult.layer.borderColor=[UIColor colorWithHexString:iBORDERCOLOR].CGColor;
    self.tblSearchResult.layer.borderWidth=1.0f;
    self.tblSearchResult.layer.masksToBounds=YES;
    [IntripperEnvironment circleButton:self.btnTapToNavigate withColor:[UIColor whiteColor]];
    fullScreenView=self.view.frame;
    CGRect newSize=self.view.frame;
    newSize.size.height=self.vwBackground.frame.size.height;
    self.view.frame=newSize;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:.3f animations:^{
        self.vwBackground.transform=CGAffineTransformIdentity;
        self.vwIcon.alpha=1;
        self.vwLine.alpha=1;
        self.btnTapToNavigate.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGIndoorMapPoint) destination {
    return endPoint;
}
- (CGIndoorMapPoint) start {
    return startPoint;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)onTapShowNavigation{
    if (CGIndoorMapPointIsEmpty(startPoint)||CGIndoorMapPointIsEmpty(endPoint)) {
        //Not fill all destination
        
    }
    else{
       [self.txtFromLocation resignFirstResponder];
       [self.txtToLocation resignFirstResponder];
        [self.delegate locatePathOnMap:self];
    }
}

- (void)setSeachLocation:(NSArray *)searchResult{
    self.view.frame=fullScreenView;
    [self.listSearchResult removeAllObjects];
    self.listSearchResult=[NSMutableArray arrayWithArray:searchResult];
    if ([searchResult count]>0) {
        if (self.tblSearchResult.hidden==YES) {
            if ([self.txtFromLocation isFirstResponder]) {
                CGRect textLocation=self.txtFromLocation.frame;
                textLocation.origin.y=textLocation.origin.y+textLocation.size.height-2;
                textLocation.size.height=self.tblSearchResult.frame.size.height;
                textLocation.size.width=self.view.frame.size.width;
                textLocation.origin.x=0;
                self.tblSearchResult.frame=textLocation;
            }
            else if ([self.txtToLocation isFirstResponder]) {
                CGRect textLocation=self.txtToLocation.frame;
                textLocation.origin.y=textLocation.origin.y+textLocation.size.height;
                textLocation.size.height=self.tblSearchResult.frame.size.height;
                textLocation.size.width=self.view.frame.size.width;
                textLocation.origin.x=0;
                self.tblSearchResult.frame=textLocation;
            }
            
        }
        self.tblSearchResult.hidden=NO;
        [self.tblSearchResult reloadData];
        
    }
    else{
        self.tblSearchResult.hidden=YES;
    }
}

#pragma mark Text View Events
- (BOOL)textField:(UITextField *)sender shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString: @"\n"])
    {
        [sender resignFirstResponder];
        if (taptoClose==NO) {
            if (CGIndoorMapPointIsEmpty(startPoint)||CGIndoorMapPointIsEmpty(endPoint)) {
                
            }
            else{
                [self.delegate locatePathOnMap:self];
            }
            
        }
        return NO;
    }
    
    NSString *typedString = [sender.text stringByReplacingCharactersInRange: range
                                                                 withString: string];
    if (typedString.length > 0)
    {
        [self.delegate getSeachLocation:typedString];
    }
    else{
        self.tblSearchResult.hidden=YES;
    }
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.tblSearchResult.hidden=YES;
    CGRect newSize=self.view.frame;
    newSize.size.height=self.vwBackground.frame.size.height;
    self.view.frame=newSize;
    
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listSearchResult.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"searchCell";
    LocateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        //NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"IntripperBundle" withExtension:@"bundle"]];
        [tableView registerNib:[UINib nibWithNibName:@"LocateTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    NSDictionary *itemToDisplay=[self.listSearchResult objectAtIndex:indexPath.row];
    
    cell.lblStoreName.text = [itemToDisplay objectForKey:@"store"];
    NSString *FloorName=[itemToDisplay objectForKey:@"floor"];//[[IndoorMapProperties instance] FloorName:[[itemToDisplay objectForKey:@"floor"] intValue]];
    cell.lblOnFloor.text = [NSString stringWithFormat:@"Level %@",FloorName];
    
    //NSString *logo=[itemToDisplay objectForKey:@"logo"];
    //[self.imgStore setImage:[UIImage imageNamed:@"wsf.png"]];
    //[self.imgStoreNavImage setImage:[UIImage imageNamed:@"wsf.png"]];
    cell.imgImage.image=[UIImage imageNamed:@"generic_shop_green.png"];
    /*ImageCacheManager *objICM = [[ImageCacheManager alloc] init];
    UIImage *imgLogo = [objICM getCachedImage:logo];
    
    if(imgLogo)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [cell.imgImage setImage:imgLogo];
                           
                       });
    }*/

    
    [UIView ChangeAppFont:cell];
    NSLog(@"%@",itemToDisplay);
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemToDisplay=[self.listSearchResult objectAtIndex:indexPath.row];
    NSString *coordinate=[itemToDisplay objectForKey:@"center"];
    NSArray *splitCoordinate=[coordinate componentsSeparatedByString:@","];
    float xSum, ySum;
    xSum=[splitCoordinate[1] floatValue];
    ySum=[splitCoordinate[0] floatValue];
    
    if ([self.txtFromLocation isFirstResponder]) {
        self.txtFromLocation.text=[itemToDisplay objectForKey:@"store"];
        startTitle=self.txtFromLocation.text;
        startPoint=CGMakeMapPoint(xSum, ySum, [[itemToDisplay objectForKey:@"floor"] floatValue]);
        if ([self.delegate respondsToSelector:@selector(NewStartLocation:)]) {
            [self.delegate NewStartLocation:[itemToDisplay objectForKey:@"store"]];
        }
    }
    else if ([self.txtToLocation isFirstResponder]) {
        
        NSString *myString = [@"to " stringByAppendingString:[itemToDisplay objectForKey:@"store"]];
        //Create mutable string from original one
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
        
        //Fing range of the string you want to change colour
        //If you need to change colour in more that one place just repeat it
        NSRange range = [myString rangeOfString:@"to "];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
        
        //Add it to the label - notice its not text property but it's attributeText
        self.txtToLocation.attributedText = attString;
        
        endTitle=self.txtToLocation.text;
        endPoint=CGMakeMapPoint(xSum, ySum, [[itemToDisplay objectForKey:@"floor"] floatValue]);
        if ([self.delegate respondsToSelector:@selector(NewEndLocation:)]) {
            [self.delegate NewEndLocation:[itemToDisplay objectForKey:@"store"]];
        }
    }
    tableView.hidden=YES;
    [self onTapShowNavigation];
}

- (IBAction)onTapCloseView:(UIButton *)sender {
    taptoClose=YES;
    [self.delegate closeSeachLocationWithBarAndPath:self];
}
-(void)startSelectingOnMap{
   if ([self.txtFromLocation isFirstResponder]) {
       anchorView=self.txtFromLocation;
       [self.txtFromLocation resignFirstResponder];
    }
   else if ([self.txtToLocation isFirstResponder]) {
       anchorView=self.txtToLocation;
       [self.txtToLocation resignFirstResponder];
   }
}
-(void)SelectedOnMap:(CGIndoorMapPoint)t toLocationText:(NSString *)to{
    if (anchorView!=nil) {
        if ([anchorView isEqual:self.txtFromLocation]) {
            startPoint=t;
             startTitle=to;
            self.txtFromLocation.text=startTitle;
            if ([self.delegate respondsToSelector:@selector(NewStartLocation:)]) {
                [self.delegate NewStartLocation:startTitle];
            }
        }
        else if ([anchorView isEqual:self.txtToLocation]) {
           endPoint=t;
            endTitle=to;
            
            NSString *myString = [@"to " stringByAppendingString:endTitle];
            //Create mutable string from original one
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
            
            //Fing range of the string you want to change colour
            //If you need to change colour in more that one place just repeat it
            NSRange range = [myString rangeOfString:@"to "];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
            
            //Add it to the label - notice its not text property but it's attributeText
            self.txtToLocation.attributedText = attString;
            if ([self.delegate respondsToSelector:@selector(NewEndLocation:)]) {
                [self.delegate NewEndLocation:endTitle];
            }

        }
        
        anchorView=nil;
    }
    [self onTapShowNavigation];
}


@end
