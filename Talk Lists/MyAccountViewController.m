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

@property (weak, nonatomic) IBOutlet UIButton *deleteAllButton;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.delegate = self;
    
    
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];

    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
 
    
    // Create the sign up view controller
    GuideUserSignUpViewController *signUpViewController = [[GuideUserSignUpViewController alloc]init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsDefault];
    [self setSignUpController:signUpViewController];
    
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.logInView addSubview:self.deleteAllButton];
    
    
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
    // move back to previous view
    if (self.parentViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma  mark <PFSignUPViewControllerDelegate>

void (^dismissMyAccountViewController)(void) = ^ {
    NSLog(@"block");
};


-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    self.logInView.usernameField.text = user.username;
    self.logInView.passwordField.text = user.password;
    
    // dismiss the signUpController
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        
        // unwind self back to root view controller
        SEL theUnwindSelector = @selector(goToRoot:);
        NSString *unwindSegueIdentifier = @"unwindToRootSeque";
        
        UINavigationController *nc = [weakSelf navigationController];
        // Find the view controller that has this unwindAction selector (may not be one in the nav stack)
        UIViewController *viewControllerToCallUnwindSelectorOn = [nc viewControllerForUnwindSegueAction: theUnwindSelector
                                                                                     fromViewController: weakSelf
                                                                                             withSender: weakSelf];
        // None found, then do nothing.
        if (viewControllerToCallUnwindSelectorOn == nil) {
            NSLog(@"No controller found to unwind too");
            return;
        }
        
        // Can the controller that we found perform the unwind segue.  (This is decided by that controllers implementation of canPerformSeque: method
        BOOL cps = [viewControllerToCallUnwindSelectorOn canPerformUnwindSegueAction: theUnwindSelector
                                                                  fromViewController: weakSelf
                                                                          withSender: weakSelf];
        // If we have permision to perform the seque on the controller where the unwindAction is implmented
        // then get the segue object and perform it.
        if (cps) {
            
            UIStoryboardSegue *unwindSegue = [nc segueForUnwindingToViewController: viewControllerToCallUnwindSelectorOn fromViewController: weakSelf identifier: unwindSegueIdentifier];
            
            [viewControllerToCallUnwindSelectorOn prepareForSegue: unwindSegue sender: weakSelf];
            
            [unwindSegue perform];
        }

    }];
    
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
        
        return informationComplete;}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
