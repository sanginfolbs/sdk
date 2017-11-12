//
//  WaitViewController.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 28/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "WaitViewController.h"
#import "IntripperEnvironment.h"

@interface WaitViewController ()
@property (strong, nonatomic) IBOutlet UIView *vwBackground;
@end

@implementation WaitViewController
static WaitViewController *_WaitClient = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.vwBackground setBackgroundColor:[UIColor clearColor]];
    [IntripperEnvironment AddRoundedCorners:self.vwBackground];
    /*
    NSArray *imageNames = @[@"0-blue-GIF.png", @"1-blue-GIF.png",@"2-blue-GIF.png",@"3-blue-GIF.png",@"4-blue-GIF.png",@"5-blue-GIF.png",@"6-blue-GIF.png",@"7-blue-GIF.png",@"8-blue-GIF.png",@"9-blue-GIF.png",@"10-blue-GIF.png",@"11-blue-GIF.png",@"12-blue-GIF.png",@"13-blue-GIF.png",@"14-blue-GIF.png",@"15-blue-GIF.png",@"16-blue-GIF.png",@"17-blue-GIF.png",@"18-blue-GIF.png",@"19-blue-GIF.png",@"20-blue-GIF.png",@"21-blue-GIF.png",
                            
                           @"1-orange-GIF.png",@"2-orange-GIF.png",@"3-orange-GIF.png",@"4-orange-GIF.png",@"5-orange-GIF.png",@"6-orange-GIF.png",@"7-orange-GIF.png",@"8-orange-GIF.png",@"9-orange-GIF.png",@"10-orange-GIF.png",@"11-orange-GIF.png",@"12-orange-GIF.png",@"13-orange-GIF.png",@"14-orange-GIF.png",@"15-orange-GIF.png",@"16-orange-GIF.png",@"17-orange-GIF.png",@"18-orange-GIF.png",@"19-orange-GIF.png",@"20-orange-GIF.png",@"21-orange-GIF.png",
                            
                            @"1-green-GIF.png",@"2-green-GIF.png",@"3-green-GIF.png",@"4-green-GIF.png",@"5-green-GIF.png",@"6-green-GIF.png",@"7-green-GIF.png",@"8-green-GIF.png",@"9-green-GIF.png",@"10-green-GIF.png",@"11-green-GIF.png",@"12-green-GIF.png",@"13-green-GIF.png",@"14-green-GIF.png",@"15-green-GIF.png",@"16-green-GIF.png",@"17-green-GIF.png",@"18-green-GIF.png",@"19-green-GIF.png",@"20-green-GIF.png",@"21-green-GIF.png",
                            
                            @"1-purple-GIF.png",@"2-purple-GIF.png",@"3-purple-GIF.png",@"4-purple-GIF.png",@"5-purple-GIF.png",@"6-purple-GIF.png",@"7-purple-GIF.png",@"8-purple-GIF.png",@"9-purple-GIF.png",@"10-purple-GIF.png",@"11-purple-GIF.png",@"12-purple-GIF.png",@"13-purple-GIF.png",@"14-purple-GIF.png",@"15-purple-GIF.png",@"16-purple-GIF.png",@"17-purple-GIF.png",@"18-purple-GIF.png",@"19-purple-GIF.png",@"20-purple-GIF.png",@"21-purple-GIF.png"];
    */
    NSArray *imageNames = @[@"Preloader_1_00000.png",
                            @"Preloader_1_00001.png",
                            @"Preloader_1_00002.png",
                            @"Preloader_1_00003.png",
                            @"Preloader_1_00004.png",
                            @"Preloader_1_00005.png",
                            @"Preloader_1_00006.png",
                            @"Preloader_1_00007.png",
                            @"Preloader_1_00008.png",
                            @"Preloader_1_00009.png",
                            @"Preloader_1_00010.png",
                            @"Preloader_1_00011.png",
                            @"Preloader_1_00012.png",
                            @"Preloader_1_00013.png",
                            @"Preloader_1_00014.png",
                            @"Preloader_1_00015.png",
                            @"Preloader_1_00016.png",
                            @"Preloader_1_00017.png",
                            @"Preloader_1_00018.png",
                            @"Preloader_1_00019.png",
                            @"Preloader_1_00020.png",
                            @"Preloader_1_00021.png",
                            @"Preloader_1_00022.png",
                            @"Preloader_1_00023.png",
                            @"Preloader_1_00024.png",
                            @"Preloader_1_00025.png",
                            @"Preloader_1_00026.png",
                            @"Preloader_1_00027.png",
                            @"Preloader_1_00028.png",
                            @"Preloader_1_00029.png",
                            @"Preloader_1_00030.png",
                            @"Preloader_1_00031.png",
                            @"Preloader_1_00032.png",
                            @"Preloader_1_00033.png",
                            @"Preloader_1_00034.png",
                            @"Preloader_1_00035.png",
                            @"Preloader_1_00036.png",
                            @"Preloader_1_00037.png",
                            @"Preloader_1_00038.png",
                            @"Preloader_1_00039.png",
                            @"Preloader_1_00040.png",
                            @"Preloader_1_00041.png",
                            @"Preloader_1_00042.png",
                            @"Preloader_1_00043.png",
                            @"Preloader_1_00044.png",
                            @"Preloader_1_00045.png",
                            @"Preloader_1_00046.png",
                            @"Preloader_1_00047.png",
                            @"Preloader_1_00048.png",
                            @"Preloader_1_00049.png",
                            @"Preloader_1_00050.png",
                            @"Preloader_1_00051.png",
                            @"Preloader_1_00052.png",
                            @"Preloader_1_00053.png",
                            @"Preloader_1_00054.png",
                            @"Preloader_1_00055.png",
                            @"Preloader_1_00056.png",
                            @"Preloader_1_00057.png",
                            @"Preloader_1_00058.png",
                            @"Preloader_1_00059.png",
                            @"Preloader_1_00060.png",
                            @"Preloader_1_00061.png",
                            @"Preloader_1_00062.png",
                            @"Preloader_1_00063.png",
                            @"Preloader_1_00064.png",
                            @"Preloader_1_00065.png",
                            @"Preloader_1_00066.png",
                            @"Preloader_1_00067.png",
                            @"Preloader_1_00068.png",
                            @"Preloader_1_00069.png",
                            @"Preloader_1_00070.png",
                            @"Preloader_1_00071.png",
                            @"Preloader_1_00072.png",
                            @"Preloader_1_00073.png",
                            @"Preloader_1_00074.png",
                            @"Preloader_1_00075.png",
                            @"Preloader_1_00076.png",
                            @"Preloader_1_00077.png",
                            @"Preloader_1_00078.png",
                            @"Preloader_1_00079.png",
                            @"Preloader_1_00080.png",
                            @"Preloader_1_00081.png",
                            @"Preloader_1_00082.png",
                            @"Preloader_1_00083.png"
];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    self.imgLoader.animationImages=images;
    self.imgLoader.animationDuration=5;
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

+(void)ShowLoader{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _WaitClient = [[WaitViewController alloc]initWithNibName:@"WaitView" bundle:[NSBundle mainBundle] ];
        _WaitClient.view.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    });
    if ([_WaitClient.view superview]==nil) {
        //[_WaitClient.loader startAnimating];
        [_WaitClient.imgLoader startAnimating];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:_WaitClient.view];
    }
    
}
+(void)ShowLoader:(NSString *)text{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _WaitClient = [[WaitViewController alloc]initWithNibName:@"WaitView" bundle:[NSBundle mainBundle] ];
        _WaitClient.view.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    });
    _WaitClient.lblInfo.text=text;
    if ([_WaitClient.view superview]==nil) {
        //[_WaitClient.loader startAnimating];
        [_WaitClient.imgLoader startAnimating];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:_WaitClient.view];
    }
    
}
+(void)HideLoader{
    [UIView animateWithDuration:.3f animations:^{
        _WaitClient.view.alpha=0;
    } completion:^(BOOL finished) {
        //[_WaitClient.loader stopAnimating];
        [_WaitClient.imgLoader stopAnimating];
        _WaitClient.view.alpha=1;
        [_WaitClient.view removeFromSuperview];
    }];
    
    
}
@end
