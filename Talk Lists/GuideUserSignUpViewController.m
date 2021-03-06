//
//  GuideUserSignUpViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "GuideUserSignUpViewController.h"
#import "TalkListAppDelegate.h"

@interface GuideUserSignUpViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *passwordAgain;
@property (strong,nonatomic) UIColor *fieldBackgroundColor;

@end

@implementation GuideUserSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.fieldBackgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signUpView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kAppBackgroundImageName]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
    
    // configure user name field
    [self.signUpView.usernameField setTextColor:[UIColor blackColor]];
    self.signUpView.usernameField.backgroundColor = self.fieldBackgroundColor;
    NSAttributedString *userNamePlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.signUpView.usernameField.attributedPlaceholder = userNamePlaceholder;
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;

    // configure password field
    [self.signUpView.passwordField setTextColor:[UIColor blackColor]];
    self.signUpView.passwordField.backgroundColor = self.fieldBackgroundColor;
    NSAttributedString *passwordPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.signUpView.passwordField.attributedPlaceholder = passwordPlaceholder;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;

    // set up the additional Field
    self.signUpView.additionalField.secureTextEntry = YES;
    [self.signUpView.additionalField setTextColor:[UIColor blackColor]];
    NSAttributedString *placeholderStr = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.signUpView.additionalField.attributedPlaceholder = placeholderStr;
    self.signUpView.additionalField.textAlignment = NSTextAlignmentCenter;
    self.signUpView.additionalField.backgroundColor = self.fieldBackgroundColor;
    
    // configure email field
    [self.signUpView.emailField setTextColor:[UIColor blackColor]];
    self.signUpView.emailField.backgroundColor = self.fieldBackgroundColor;
    NSAttributedString *emailPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.signUpView.emailField.attributedPlaceholder = emailPlaceholder;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    
    // configure sign up button
    UIColor *buttonTextColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AppleGreen"]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitleColor:buttonTextColor forState:UIControlStateNormal];

    // configure dismiss button
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cross-white"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self initialUITextFieldPositions];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.signUpView.usernameField becomeFirstResponder];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITextField delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Set field background color
    textField.backgroundColor = [UIColor whiteColor];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Set field background color
    textField.backgroundColor = self.fieldBackgroundColor;
    
    if ([textField isEqual:self.signUpView.additionalField] && (textField.text.length != 0)) {
        if ( [textField.text isEqualToString:self.signUpView.passwordField.text] )
        {
         //   NSLog(@"password good to go");
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Passwords do not match"
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
    }

}


#pragma mark Keyboard Notifications
// Having these handlers here somehow activates the self.signUpView (which is a scrollView) to scroll out of the keyboard's way
- (void)keyboardWasShown:(NSNotification*)aNotification
{

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
}

-(void)initialUITextFieldPositions
{
    [self.signUpView.dismissButton setFrame:CGRectMake(5.0, 30.0, 20.0, 20.0)];
    [self.signUpView.logo setFrame:CGRectMake(60.0, 75.0, 200, 20.0)];
    [self.signUpView.usernameField setFrame:CGRectMake(35.0f, 120.0f, 250.0f, 42.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(35.0f, 164.0f, 250.0f, 42.0f)];
    [self.signUpView.additionalField setFrame:CGRectMake(35.0f, 208.0f, 250.0f, 42.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(35.0f, 252.0f, 250.0f, 42.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 308.0f, 250.0f, 40.0f)];
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
