//
//  ViewController.m
//  Ramping_ObjectiveC_Application
//
//  Created by Steven Hurtado on 5/3/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    int labelWidth = 96;
    int labelHeight = 48;
    UILabel * myLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width/labelWidth/2, self.view.frame.size.height/2-labelHeight/2, labelWidth, labelHeight)];
    myLabel.text = @"Hello, World!";
    [[self view] addSubview: myLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
