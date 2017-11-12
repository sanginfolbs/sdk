//
//  RouteListWindow.m
//  shoppingmall
//
//  Created by Sanginfo on 08/01/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import "RouteListWindow.h"
#import "RouteListTableViewCell.h"

@interface RouteListWindow ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblListOptions;

@end

@implementation RouteListWindow
{
    NSMutableArray *instrData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tblListOptions registerNib:[UINib nibWithNibName:@"RouteListTableViewCell" bundle:nil] forCellReuseIdentifier:[RouteListTableViewCell reuseIdentifier]];
    [self.tblListOptions reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [instrData count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 66;
//}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 63;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RouteListTableViewCell *cell = (RouteListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[RouteListTableViewCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[RouteListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[RouteListTableViewCell reuseIdentifier]];
    }
    NSString *instrStr = [[[instrData objectAtIndex:indexPath.row]objectForKey:@"properties"]objectForKey:@"instruction"];
   
    if(indexPath.row==[instrData count]-1){
        NSRange range = [instrStr rangeOfString:@"your destination"];
        if (range.location == NSNotFound) {
            instrStr=[NSString stringWithFormat:@"%@ and arrive at your destination",instrStr];
        }
    }
    NSString *storeAc=[[[instrData objectAtIndex:indexPath.row]objectForKey:@"properties"]objectForKey:@"ac"];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:instrStr];
    NSRange rangeInstr;
    if(storeAc.length>0)
    {
        rangeInstr = [instrStr rangeOfString:storeAc];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.043 green:0.78 blue:0.706 alpha:1] range:rangeInstr];
        UIFont *fontText = [UIFont boldSystemFontOfSize:15];
        NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
        
        //[attString setAttributes:dictBoldText range:rangeInstr];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.043 green:0.78 blue:0.706 alpha:1] range:rangeInstr];
    }
    //Add it to the label - notice its not text property but it's attributeText
    if (rangeInstr.length>0) {
        cell.lblInstr.attributedText = attString;
    }else{
        cell.lblInstr.text=instrStr;
    }
    

    NSString *disInt=[[[[instrData objectAtIndex:indexPath.row]objectForKey:@"properties"]objectForKey:@"distance"] stringValue];
    int intDis = [disInt intValue];
    NSString *dis=[NSString stringWithFormat:@"%d", intDis];
    NSString *disInMeter=[dis stringByAppendingString:@" m"];
    double disInFeet = [disInMeter doubleValue];
    disInFeet = disInFeet*3.28;
    if(intDis==0)
    {
        cell.lblDist.text = Nil;
    }else{
        cell.lblDist.text = [NSString stringWithFormat:@"%.0f feet",disInFeet];
    }
    NSRange range = [cell.lblInstr.text rangeOfString:@"left"];
    NSString *imageicon=@"";
    if (indexPath.row==0) {
        imageicon=@"ic_turn_location_charcoal_grey.png";
        
    }
    else if(indexPath.row==[instrData count]-1){
        imageicon=@"ic_turn_destination_charcoal_grey.png";
    }
    else{
        if (range.location != NSNotFound) {
            imageicon=@"ic_turn_left_white_charcoal_grey.png";
            
        }
        else{
            range = [cell.lblInstr.text rangeOfString:@"right"];
            if (range.location!= NSNotFound) {
                imageicon=@"ic_turn_right_white_charcoal_grey.png";
            }
            else{
                range = [cell.lblInstr.text rangeOfString:@"destination"];
                if (range.location!= NSNotFound) {
                    imageicon=@"ic_turn_destination_charcoal_grey.png";
                }
                else{
                    imageicon=@"ic_turn_straight_charcoal_grey.png";
                }
            }
        }
    }
    cell.imgInstrDir.image =[UIImage imageNamed:imageicon];
    CGRect frameSep = cell.imgSepLine.frame;
    if(indexPath.row==0)
    {frameSep.origin.x=cell.lblInstr.frame.origin.x;
    }else{
        frameSep.origin.x=cell.lblDist.frame.origin.x+cell.lblDist.frame.size.width;
    }
    cell.imgSepLine.frame=frameSep;
        
    return cell;
}

-(void)setData:(NSArray *)ListData{
    instrData=[NSMutableArray arrayWithArray:ListData];
    
    NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
    NSMutableDictionary *data=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Your location",@"instruction", nil];
    [userDictionary setObject:data forKey:@"properties"];
    [instrData insertObject:userDictionary atIndex:0];
}
@end
