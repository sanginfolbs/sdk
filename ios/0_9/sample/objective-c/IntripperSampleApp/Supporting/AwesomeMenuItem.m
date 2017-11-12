//
//  AwesomeMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenuItem.h"
static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}
@implementation AwesomeMenuItem

@synthesize contentImageView = _contentImageView;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = _delegate;
@synthesize selectedImage  = _selectedImage;
@synthesize backImage  = _backImage;
@synthesize selectedContentImage  = _selectedContentImage;
@synthesize backContentImage  = _backContentImage;

#pragma mark - initialization & cleaning up
- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg;
{
    if (self = [super init]) 
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        self.backImage=img;
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        self.backContentImage=cimg;
        _contentImageView.highlightedImage = hcimg;
        [self addSubview:_contentImageView];
    }
    return self;
}

- (id)initWithImage:(UIImage *)img
   highlightedImage:(UIImage *)himg
      selectedImage:(UIImage *)simg
       ContentImage:(UIImage *)cimg
 selectedContentImage:(UIImage *)csimg
highlightedContentImage:(UIImage *)hcimg{
    if (self = [super init])
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        self.backImage=img;
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        self.backContentImage=cimg;
        _contentImageView.highlightedImage = hcimg;
        self.selectedImage=simg;
        self.selectedContentImage=csimg;
        [self addSubview:_contentImageView];
    }
    return self;
}
#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        //This will cancel the singleTap action
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    
    self.highlighted = YES;
    if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesBegan:)])
    {
       [_delegate AwesomeMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    
    UITouch *touch = [touches anyObject];
    
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if (touch.tapCount == 1) {
            //this is the single tap action being set on a delay
            [self performSelector:@selector(singleTaponMenuItem) withObject:nil afterDelay:0.3];
            
        } else if (touch.tapCount == 2) {
            //this is the double tap action
            if ([_delegate respondsToSelector:@selector(AwesomeMenuItemDoubleTap:)])
            {
                [_delegate AwesomeMenuItemDoubleTap:self];
            }
        }
    }
}
-(void)singleTaponMenuItem{
    if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesEnd:)])
    {
        [_delegate AwesomeMenuItemTouchesEnd:self];
    }
    if ([_delegate respondsToSelector:@selector(AwesomeMenuItemSingleTap:)])
    {
        [_delegate AwesomeMenuItemSingleTap:self];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}

-(void)setSelected:(BOOL)isSelected{
    if (isSelected) {
        [self setImage:self.selectedImage];
        [_contentImageView setImage:self.selectedContentImage];
    }
    else{
          [self setImage:self.backImage];
        [_contentImageView setImage:self.backContentImage];
    
    }
    
}

@end
