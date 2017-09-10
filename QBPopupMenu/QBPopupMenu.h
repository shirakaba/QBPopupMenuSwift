//
//  QBPopupMenu.h
//  QBPopupMenu
//
//  Created by Tanaka Katsuma on 2013/11/22.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBPopupMenu;
@class QBPopupMenuItemView;
@class QBPopupMenuPagenatorView;
typedef NS_ENUM(NSInteger, QBPopupMenuArrowDirection);

@protocol QBPopupMenuDelegate <NSObject>

@optional
- (void)popupMenuWillAppear:(QBPopupMenu *)popupMenu;
- (void)popupMenuDidAppear:(QBPopupMenu *)popupMenu;
- (void)popupMenuWillDisappear:(QBPopupMenu *)popupMenu;
- (void)popupMenuDidDisappear:(QBPopupMenu *)popupMenu;

@end

@interface QBPopupMenu : UIView

@property (nonatomic, weak) id<QBPopupMenuDelegate> delegate;

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat arrowSize;
@property (nonatomic, assign) QBPopupMenuArrowDirection arrowDirection;
@property (nonatomic, assign) UIEdgeInsets popupMenuInsets;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) CGRect targetRect;

+ (instancetype)popupMenuWithItems:(NSArray *)items;
- (instancetype)initWithItems:(NSArray *)items;

- (void)showInView:(UIView *)view targetRect:(CGRect)targetRect animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
- (void)updateWithTargetRect:(CGRect)targetRect;

- (CGMutablePathRef)arrowPathInRect:(CGRect)rect direction:(QBPopupMenuArrowDirection)direction CF_RETURNS_RETAINED;
- (CGMutablePathRef)headPathInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius CF_RETURNS_RETAINED;
- (CGMutablePathRef)tailPathInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius CF_RETURNS_RETAINED;
- (CGMutablePathRef)bodyPathInRect:(CGRect)rect CF_RETURNS_RETAINED;

- (void)drawArrowAtPoint:(CGPoint)point arrowSize:(CGFloat)arrowSize arrowDirection:(QBPopupMenuArrowDirection)arrowDirection highlighted:(BOOL)highlighted;
- (void)drawArrowInRect:(CGRect)rect direction:(QBPopupMenuArrowDirection)direction highlighted:(BOOL)highlighted;
- (void)drawHeadInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted;
- (void)drawTailInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted;
- (void)drawBodyInRect:(CGRect)rect firstItem:(BOOL)firstItem lastItem:(BOOL)lastItem highlighted:(BOOL)highlighted;

@end
