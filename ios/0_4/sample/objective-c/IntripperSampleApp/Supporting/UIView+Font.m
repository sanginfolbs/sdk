//
//  UIView+Font.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 27/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "UIView+Font.h"


@implementation UIView(Font)
- (NSMutableArray*)allSubViews
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    [arr addObject:self];
    for (UIView *subview in self.subviews)
    {
        [arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
    }
    return arr;
}

+(void)ChangeAppFont:(UIView *) appView{
    //NSString *nameFont= @"Roboto-";//currentFont.fontName;
    //NSString *appFontName= @"Roboto";//currentFont.fontName;
    
    NSString *nameFont= @"OpenSans";//currentFont.fontName;
    NSString *appFontName= @"OpenSans";//currentFont.fontName;
    
    for (UIView *v in [appView allSubViews]) {
        if([v isKindOfClass:[UILabel class]])
        {
            UIFont *currentFont= ((UILabel*)v).font;
            if([@"Details sameer" isEqualToString:((UILabel *)v).text])
            {
                NSLog(@"%@ %@",currentFont.fontName,((UILabel *)v).text);
            }
            NSArray *fontWt=[currentFont.fontName componentsSeparatedByString:@"-"];
            if (![[fontWt objectAtIndex:0] isEqualToString:appFontName]) {
                NSString *applyFont;
                if ([fontWt count]==1) {
                    applyFont=[NSString stringWithFormat:@"%@%@",nameFont,[self NewUIFontName:[fontWt objectAtIndex:0]]];
                }else
                {
                    applyFont=[NSString stringWithFormat:@"%@%@",nameFont,[self NewUIFontName:[fontWt objectAtIndex:1]]];
                }
                ((UILabel*)v).font=[UIFont fontWithName:applyFont size:currentFont.pointSize];
            }
            
        }
        else if([v isKindOfClass:[UIButton class]]){
            UIFont *currentFont= ((UIButton*)v).titleLabel.font;
            
            NSArray *fontWt=[currentFont.fontName componentsSeparatedByString:@"-"];
            if (![[fontWt objectAtIndex:0] isEqualToString:appFontName]) {
                NSString *applyFont;
                if ([fontWt count]==1) {
                    applyFont=[NSString stringWithFormat:@"%@%@",nameFont,[self NewUIFontName:[fontWt objectAtIndex:0]]];
                }else
                {
                    applyFont=[NSString stringWithFormat:@"%@%@",nameFont,[self NewUIFontName:[fontWt objectAtIndex:1]]];
                }
                if ([appFontName isEqualToString:@"HelveticaNeue"]) {
                    ((UIButton*)v).titleLabel.font=[UIFont fontWithName:applyFont size:currentFont.pointSize];
                }
                else{
                    ((UIButton*)v).titleLabel.font=[UIFont fontWithName:applyFont size:currentFont.pointSize];
                }
            }
        }
    }
}
/*OpenSans-ExtraboldItalic
 OpenSans-SemiboldItalic
 OpenSans-Extrabold
 OpenSans-BoldItalic
 OpenSans-Italic
 OpenSans-Semibold
 OpenSans-Light
 OpenSans
 OpenSansLight-Italic
 OpenSans-Bold
 */

+(NSString *)NewUIFontName:(NSString *)scale{
    NSString *nameFont=@"Light";
    if ([scale isEqualToString:@"MediumP4"]) {
        nameFont=@"-Semibold";
    }
    if ([scale isEqualToString:@"Semibold"]) {
        nameFont=@"-Semibold";
    }
    else if ([scale isEqualToString:@"Bold"]) {
        nameFont=@"-Bold";
    }
    else if ([scale isEqualToString:@"Light"]) {
        nameFont=@"-Light";
        
    }
    else if ([scale isEqualToString:@"M3"]) {
        nameFont=@"";
    }
    else if ([scale isEqualToString:@"Medium"]) {
        nameFont=@"";
    }
    else if ([scale isEqualToString:@"Regular"]) {
        nameFont=@"";
    }
    else if([scale isEqualToString:@"HelveticaNeue"]){
        nameFont=@"";
    }
    else{
        NSLog(@"missing api font: %@",scale);
    }
    return nameFont;
}

@end
