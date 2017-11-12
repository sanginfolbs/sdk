//
//  CustomMallAlertView.h
//  CustomMallAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DialogCenter              = 0,
    DialogBootom            = 1,
    DialogTop = 2
} DialogPosition;

@protocol CustomMallAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomMallAlertView : UIView<CustomMallAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, assign) id<CustomMallAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, retain) id object;
@property (nonatomic, assign) DialogPosition diaplogPositionMode;
@property (nonatomic, assign) BOOL displayCloseDialog;
@property (copy) void (^onButtonTouchUpInside)(CustomMallAlertView *alertView, int buttonIndex) ;
+(BOOL)CustomMallOnScreen;
- (id)init;

/*!
 DEPRECATED: Use the [CustomMallAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomMallAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
