//
//  AssignTagViewController.m
//  WhereNow
//
//  Created by Admin on 12/4/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AssignTagViewController.h"
#import "UIManager.h"

@interface AssignTagViewController ()
{
    UIBarButtonItem* btnBack;
}

@end

@implementation AssignTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btnBack = [UIManager defaultBackButton:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;    
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

- (IBAction)onBack :(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
    return;
}

@end
