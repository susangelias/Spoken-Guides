//
//  StepEntryViewController.m
//  Talk Lists
//
//  Created by Susan Elias on 7/17/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "DataEntryViewController.h"
#import "addPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface DataEntryViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet SZTextView *textEntryView;
@property (weak, nonatomic) IBOutlet PFImageView *imageDisplayView;

@end

@implementation DataEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.textEntryView.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.entryText) {
        self.textEntryView.text = self.entryText;
    }
    else {
        // show the placeholder text
        self.textEntryView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", self.entryNumber];
    }
    self.imageDisplayView.image = self.entryImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Add Photo unwind segues

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *addPhotoVC = (addPhotoViewController *)segue.sourceViewController;
    
    if (addPhotoVC.selectedPhoto) {
        // update the screen display with the 300 x 300 image, not the thumbnail
        self.entryImage = addPhotoVC.selectedPhoto;
        [self.dataEntryDelegate entryImageChanged:addPhotoVC.selectedPhoto];
    }
    
}

- (IBAction)photoCanceled:(UIStoryboardSegue *)segue
{
    // resume editing of step text
 //   [self.textEntryView resetFirstResponder];
}

#pragma mark    <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
       // [self.stepEntryDelegate stepInstructionEntryCompleted:self.stepTextView.text];
        return NO;
    }
    else {
        // need to pass range and replacement text to delegate
     //   [self.stepEntryDelegate stepInstructionTextChanged:range
      //                                 withReplacementText:text];
        //    [self.stepEntryDelegate stepInstructionTextChanged:self.stepTextView.text];
        return YES;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
  //  [self.stepEntryDelegate stepInstructionEditingEnded:textView.text];
    [self.dataEntryDelegate entryTextChanged:textView.text];
}



#pragma mark - Navigation


@end
