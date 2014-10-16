//
//  MyAccountViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/30/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MyAccountViewController.h"
#import "GuideUserSignUpViewController.h"
#import "InitialViewController.h"

@interface MyAccountViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong,nonatomic) UIColor *fieldBackgroundColor;
@property (strong, nonatomic) UIColor *appleGreen;
@end

@implementation MyAccountViewController

#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.fields = PFLogInFieldsDefault;
        self.fieldBackgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
        self.appleGreen = [UIColor colorWithRed:151.0/255 green:223.0/255 blue:92.0/255 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.delegate = self;
    
    [self.logInView setBackgroundColor:[UIColor clearColor]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];

    // Configure the user name field
    [self.logInView.usernameField setTextColor:[UIColor blackColor]];
        // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    self.logInView.usernameField.backgroundColor = self.fieldBackgroundColor;
    
    // Configure the password field
    [self.logInView.passwordField setTextColor:[UIColor blackColor]];
    // Remove text shadow
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    self.logInView.passwordField.backgroundColor = self.fieldBackgroundColor;
   
    
    // Configure log in button
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"AppleGreen"] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"AppleGreen"] forState:UIControlStateHighlighted];
    self.logInView.logInButton.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    
    // Configure sign up button
    UIColor *buttonTextColor = self.appleGreen;
    [self.logInView.signUpButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitleColor:buttonTextColor forState: UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpLabel setShadowColor:[UIColor clearColor]];
    [self.logInView.signUpLabel setTextColor:[UIColor blackColor]];

    // Configure the 'Don't have an account yet' color
    [self.logInView.signUpLabel setTextColor:[UIColor whiteColor]];
    
    // Create the sign up view controller
    GuideUserSignUpViewController *signUpViewController = [[GuideUserSignUpViewController alloc]init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsDefault];
    [self setSignUpController:signUpViewController];
 
    // configure dismiss button
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"cross-black"] forState:UIControlStateNormal];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.parentViewController) {
        self.logInView.dismissButton.hidden = YES;
    }
    else
    {
        self.logInView.dismissButton.hidden = NO;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PFUser *loggedInUser = [PFUser currentUser];
    if (loggedInUser && ![PFAnonymousUtils isLinkedWithUser:loggedInUser]) {
        self.logInView.usernameField.text = loggedInUser.username;
        self.logInView.passwordField.text = loggedInUser.password;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark User Actions


- (IBAction)deleteMyAccountGuidesButtonPress:(UIButton *)sender
{
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  //  [super textFieldDidBeginEditing:textField];
    
    // Set field background color
    textField.backgroundColor = [UIColor whiteColor];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
 //   [super textFieldDidEndEditing:textField];
    
    // Set field background color
    textField.backgroundColor = self.fieldBackgroundColor;
}

#pragma mark <PFLoginViewControllerDelegate>

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process

}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"current User after log in %@", currentUser);

    [self performSegueWithIdentifier:@"unwindToInitialVCSegueID" sender:self];
}

#pragma  mark <PFSignUPViewControllerDelegate>

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    self.logInView.usernameField.text = user.username;
    self.logInView.passwordField.text = user.password;
 
    NSString *unwindSegueIdentifier = @"unwindToInitialVCSegueID";
    [self performSegueWithIdentifier:unwindSegueIdentifier sender:self];
    
 }


- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
        BOOL informationComplete = YES;
        
        // loop through all of the submitted data
        for (id key in info) {
            NSString *field = [info objectForKey:key];
            if (!field || field.length == 0) { // check completion
                informationComplete = NO;
                break;
            }
        }

        // Display an alert if a field wasn't completed
        if (!informationComplete) {
            [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                        message:@"Make sure you fill out all of the information!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    
    if (informationComplete == YES) {
        // convert anonymous user to new user signing up
        if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            [PFUser currentUser].username = [info objectForKey:@"username"];
            [PFUser currentUser].password = [info objectForKey:@"password"];
            [PFUser currentUser].email = [info objectForKey:@"email"];
        }
    }
        return informationComplete;
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
