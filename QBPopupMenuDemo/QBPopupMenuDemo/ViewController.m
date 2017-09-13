//
//  ViewController.m
//  QBPopupMenuDemo
//
//  Created by Tanaka Katsuma on 2013/11/22.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "ViewController.h"

#import "QBPopupMenuDemo-Swift.h"

@interface ViewController ()

@property (nonatomic, strong) QBPopupMenu *popupMenu;
//@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QBPopupMenuItem *item1 =  [[QBPopupMenuItem alloc] initWithTitle:@"Hello" image:nil action:^(void){[self action]; }];
    QBPopupMenuItem *item2 =  [[QBPopupMenuItem alloc] initWithTitle:@"Cut" image:nil action:^(void){[self action]; }];
    QBPopupMenuItem *item3 =  [[QBPopupMenuItem alloc] initWithTitle:@"Copy" image:nil action:^(void){[self action]; }];
    QBPopupMenuItem *item4 =  [[QBPopupMenuItem alloc] initWithTitle:@"Delete" image:nil action:^(void){[self action]; }];
    QBPopupMenuItem *item5 =  [[QBPopupMenuItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"clip"] action:^(void){[self action]; }];
    QBPopupMenuItem *item6 =  [[QBPopupMenuItem alloc] initWithTitle:@"Delete" image:[UIImage imageNamed:@"trash"] action:^(void){[self action]; }];
    NSArray *items = @[item1, item2, item3, item4, item5, item6];

    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    self.popupMenu = popupMenu;

//    QBPlasticPopupMenu *plasticPopupMenu = [[QBPlasticPopupMenu alloc] initWithItems:items];
//    plasticPopupMenu.height = 40;
//    self.plasticPopupMenu = plasticPopupMenu;
}


- (IBAction)showPopupMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self.popupMenu showInView:self.view targetRect:button.frame animated:YES];
}

- (IBAction)showPlasticPopupMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
//    [self.plasticPopupMenu showInView:self.view targetRect:button.frame animated:YES];
}

- (void)action
{
    NSLog(@"*** action");
}

@end
