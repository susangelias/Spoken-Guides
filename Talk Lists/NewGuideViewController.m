//
//  NewGuideTitleViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 4/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "NewGuideViewController.h"
#import "addPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GuideCategories.h"

@interface NewGuideViewController () <UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *guideTitle;
@property (weak, nonatomic) IBOutlet UILabel *UserDirections;
@property (weak, nonatomic) IBOutlet UITextView *StepTextView;
@property (weak, nonatomic) IBOutlet UITextView *swapTextView;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation NewGuideViewController
{
    int stepNumber;
    BOOL returnKeyPressed;
}

#pragma mark View Lifecycle

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
    self.guideTitle.delegate = self;
    [self.guideTitle becomeFirstResponder];
    
    // make sure step text views are hidden to start with
    self.StepTextView.hidden = YES;
    self.swapTextView.hidden = YES;
    self.textViewPlaceholder.hidden = YES;
    
    stepNumber = 0;
    
    // make sure a camera or photo library is available before enabling the Add Photo button
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        self.addPhotoButton.enabled = YES;
        self.addPhotoButton.hidden = NO;
    }
    else {
        self.addPhotoButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UITextFieldDelegate>

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    returnKeyPressed = NO;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    returnKeyPressed = YES;
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (returnKeyPressed) {
      //  NSLog(@"NEW TITLE: %@", textField.text);    // save to model
        // update navigation title to the user's new title
        self.navigationItem.title = textField.text;

        // Change the user directions for the next step
        [self updateStepText];

        // Clear the photo image of the guide title
        if (self.imageView.image) {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionTransitionFlipFromRight
                             animations:^{
                                 self.imageView.image = nil;
                             } completion:^(BOOL finished) {
                                 Nil;
                             }];
        }
        
        // Slide in new view
        self.StepTextView.center = CGPointMake(self.StepTextView.center.x + 300, self.StepTextView.center.y);
        [UIView animateWithDuration:0.75
                              delay:0.1
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.guideTitle.center = CGPointMake(self.guideTitle.center.x - 300, self.guideTitle.center.y);
                             self.StepTextView.hidden = NO;
                             self.StepTextView.center = CGPointMake(self.StepTextView.center.x - 300, self.StepTextView.center.y);
                           }
                         completion:^(BOOL finished) {
                             self.guideTitle.hidden = YES;
                             [self.StepTextView becomeFirstResponder];
                             self.StepTextView.delegate = self;
                             self.textViewPlaceholder.hidden = NO;
                         }];
    }
}

#pragma mark    <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        // Change the user directions for the next step
        [self updateStepText];
        
        // swap the step views
        self.swapTextView.center = CGPointMake(self.StepTextView.center.x + 300, self.StepTextView.center.y);
        [UIView animateWithDuration:0.50
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.StepTextView.center = CGPointMake(self.StepTextView.center.x - 300, self.StepTextView.center.y);
                             self.StepTextView.hidden = YES;
                             self.swapTextView.hidden = NO;
                             self.swapTextView.center = CGPointMake(self.swapTextView.center.x - 300, self.swapTextView.center.y);
                             // clear the photo image
                             self.imageView.image = nil;
                         }
                         completion:^(BOOL finished) {
                             // Save the entered text to the model here
                             // Then clear the text view for the next step entry
                             self.StepTextView.text = @"";
                             // Then swap the views
                             UITextView *temp = self.StepTextView;
                             self.StepTextView = self.swapTextView;
                             self.swapTextView = temp;
                             [self.StepTextView becomeFirstResponder];
                             self.StepTextView.delegate = self;
                             self.textViewPlaceholder.hidden = NO;
                             
                         }];
        
        return NO;
    }
    else {
        return YES;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    // clear the placeholder text
    self.textViewPlaceholder.hidden = YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceholder.hidden = ([textView.text length] > 0);
}



#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *apVC = (addPhotoViewController *)segue.sourceViewController;
    // get the image from modal vc
    UIImage *photo;
    photo = apVC.photo;
    if (photo) {
        // save photo to model
        
        // Display thumbnail of photo
        self.imageView.image =  photo;
    }
 
    // resume editing of step text
    [self resetFirstResponder];
 
}

- (IBAction)photoCanceled:(UIStoryboardSegue *)segue
{
    // resume editing of step text
    [self resetFirstResponder];
}

- (IBAction)finishedPreview:(UIStoryboardSegue *)segue
{
    // finished looking at the preview
    [self resetFirstResponder];
}

#pragma mark Set Category Button

- (IBAction)setCategoryPressed
{
    [self.guideTitle resignFirstResponder];
    [self.StepTextView resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Catagory for Your Guide"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *category in [self categoryChoices]) {
        [actionSheet addButtonWithTitle:category];
    }
    [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    
    [actionSheet showInView:self.view]; // different on iPad
}

- (NSDictionary *)categoryChoices
{
    GuideCategories *guideCats = [[GuideCategories alloc]init];
    return [guideCats categories];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ( ![choice isEqualToString:@"Cancel"]) {
        // save category to model
        self.categoryLabel.text = choice;
     }
    else {
        // do nothing
        self.categoryLabel.text = @"";
    }
    
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    
    [self.guideTitle resignFirstResponder];
    [self.StepTextView resignFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Guide"
                                                    message:@"Choose where to save your guide"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save Local", @"Publish", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex == 0)
    {
        // save choice to model
        // return to main screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark Helpers
-(void)updateStepText
{
    // Change the user directions for the next step
    stepNumber++;
    self.UserDirections.text = [NSString stringWithFormat:@"Step %d", stepNumber];
}

-(void)resetFirstResponder {
    if (self.StepTextView.hidden == NO) {
        //   self.StepTextView.clearsOnBeginEditing = NO;
        [UIView animateWithDuration:0.0
                         animations:^{
                             [self.view addSubview:self.StepTextView];
                         }
                         completion:^(BOOL finished) {
                             [self.StepTextView becomeFirstResponder];
                         }
         ];
    }
    else if (self.guideTitle.hidden == NO) {
        self.guideTitle.clearsOnBeginEditing = NO;
        [UIView animateWithDuration:0.0
                         animations:^{
                             [self.view addSubview:self.guideTitle];
                         }
                         completion:^(BOOL finished) {
                             [self.guideTitle becomeFirstResponder];
                         }
         ];
        
    }
    
}

#pragma mark Initializations


@end
