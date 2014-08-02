//
//  GuideUserSignUpViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideUserSignUpViewController.h"

@interface GuideUserSignUpViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *passwordAgain;

@end

@implementation GuideUserSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    
    // set up the additional Field
    self.passwordAgain = [[UITextField alloc] init];
    self.passwordAgain.placeholder = @"Confirm Password";
    self.passwordAgain.secureTextEntry = YES;
    self.passwordAgain.defaultTextAttributes = self.signUpView.passwordField.defaultTextAttributes;
    self.passwordAgain.delegate = self;

    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.passwordAgain.layer;
    layer.shadowOpacity = 0.0;

    
    // Set field text color
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.passwordAgain setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.signUpView addSubview:self.passwordAgain];
    
    [self.passwordAgain setFrame:CGRectMake(35.0f, 275.0f, 250.0f, 50.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(35.0f, 319.0f, 250.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 375.0f, 250.0f, 40.0f)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.signUpView.usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITextField delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.passwordAgain]) {
        if ( (textField.text.length != 0) && ([textField.text isEqualToString:self.signUpView.passwordField.text]) )
        {
            NSLog(@"password good to go");
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Passwords do not match"
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
    }

}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.signUpView.passwordField becomeFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
