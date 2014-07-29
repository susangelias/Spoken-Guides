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
@property BOOL textHasChanged;
@property BOOL advanceView;
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
    
    // sign up to catch any changes the user makes to the font settings
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(preferredContentSizeChanged:)
        name:UIContentSizeCategoryDidChangeNotification
        object:nil ];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // setup text attributes for textEntryView
 //   self.textEntryView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    if (self.entryText) {
        // Text to display
        self.textEntryView.text = self.entryText;
    }
    else {
        // No Text to display
        // display the keyboard
        [self.textEntryView becomeFirstResponder];

        // show the placeholder text and set the capitalization style
        if (self.entryNumber > 0) {
            // set placeholder test for a new step
            self.textEntryView.placeholder = [NSString stringWithFormat:@"Step %d\n\nEnter instructions here", self.entryNumber];
            self.textEntryView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        }
        else {
            // show placeholder text for guide title
            self.textEntryView.placeholder = [NSString stringWithFormat:@"Enter guide title here"];
            self.textEntryView.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }
    }
    if (self.entryImage) {
        self.imageDisplayView.image = self.entryImage;
    }
    else {
        self.imageDisplayView.image = nil;
    }
    
    self.textHasChanged = NO;
    self.advanceView = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self viewAboutToChange];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Notifications

-(void)preferredContentSizeChanged:(NSNotification *)notification
{
    self.textEntryView.font  = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}


-(void)imageLoaded:(UIImage *)downloadedImage
{
    if (downloadedImage) {
        self.imageDisplayView.image = downloadedImage;
        self.entryImage = downloadedImage;
    }
}


-(void)viewAboutToChange
{
    [self textViewDidEndEditing:self.textEntryView];
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
        self.advanceView = YES;
        [textView resignFirstResponder];
        return NO;
    }
    else {
        self.textHasChanged = YES;
        return YES;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.textHasChanged) {
        self.textHasChanged = NO;
        [self.dataEntryDelegate entryTextChanged:textView.text];
    }
}



#pragma mark - Navigation


@end
