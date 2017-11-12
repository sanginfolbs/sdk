//
//  AwesomeMenuItem.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AwesomeMenuItemDelegate;

@interface AwesomeMenuItem : UIImageView
{
    UIImageView *_contentImageView;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _nearPoint; // near
    CGPoint _farPoint; // far
    
    id<AwesomeMenuItemDelegate> __weak _delegate;
}

@property (nonatomic, strong, readonly) UIImageView *contentImageView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UIImage *selectedContentImage;
@property (nonatomic, strong) UIImage *backContentImage;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, weak) id<AwesomeMenuItemDelegate> delegate;

- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg;

- (id)initWithImage:(UIImage *)img
   highlightedImage:(UIImage *)himg
  selectedImage:(UIImage *)simg
       ContentImage:(UIImage *)cimg
selectedContentImage:(UIImage *)csimg
highlightedContentImage:(UIImage *)hcimg;

-(void)setSelected:(BOOL)isSelected;
@end

@protocol AwesomeMenuItemDelegate <NSObject>
- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item;
- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item;

- (void)AwesomeMenuItemSingleTap:(AwesomeMenuItem *)item;
- (void)AwesomeMenuItemDoubleTap:(AwesomeMenuItem *)item;
@end