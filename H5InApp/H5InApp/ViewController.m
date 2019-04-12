//
//  ViewController.m
//  H5InApp
//
//  Created by Sunny on 12/4/19.
//  Copyright © 2019年 Sunny. All rights reserved.
//

#import "ViewController.h"
#import "H5Controller.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)h5BtnClick:(id)sender {
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    H5Controller *vc = [mainBoard instantiateViewControllerWithIdentifier:@"H5Controller"];
//    vc.url = @"http://www.baidu.com";
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:nil];
    vc.fileUrl = urlStr;
    
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
