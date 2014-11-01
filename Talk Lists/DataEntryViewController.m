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
#import "ILTranslucentView.h"
#import "TalkListAppDelegate.h"

@interface DataEntryViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet SZTextView *textEntryView;
@property (weak, nonatomic) IBOutlet PFImageView *imageDisplayView;
@property BOOL entryHasChanged;
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
 
    // set up background view to reside under the textentry view
    self.textEntryView.backgroundColor =  [UIColor clearColor];
    
    ILTranslucentView *translucentTextEntry = [[ILTranslucentView alloc] initWithFrame:self.textEntryView.frame];
    [self.view addSubview:translucentTextEntry];
    translucentTextEntry.backgroundColor = [UIColor clearColor];
    translucentTextEntry.translucentTintColor = [UIColor clearColor];
    translucentTextEntry.translucentAlpha = 0.8;
    translucentTextEntry.translucentStyle = UIBarStyleDefault;
    [self.view bringSubviewToFront:self.textEntryView];
    
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
    self.imageDisplayView.backgroundColor = [UIColor clearColor];
    
    // darken the placeholder text since background is grey instead of white
    self.textEntryView.placeholderTextColor = [UIColor colorWithWhite:1.0 alpha:.90];

    // indent the text so that it doesn't run into the left & right swipe indicators
    self.textEntryView.textContainerInset = UIEdgeInsetsMake(self.textEntryView.textContainerInset.top,
                                                             self.textEntryView.textContainerInset.left + 10,
                                                             self.textEntryView.textContainerInset.bottom,
                                                             self.textEntryView.textContainerInset.right + 10);
    
    // sign up to catch any changes the user makes to the font settings
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(preferredContentSizeChanged:)
        name:UIContentSizeCategoryDidChangeNotification
        object:nil ];
    
     self.entryHasChanged = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
            // set placeholder text for a new step
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
    
  //  self.entryHasChanged = NO;
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

-(void)retractKeyboard
{
    [self.textEntryView resignFirstResponder];
}

#pragma mark Add Photo unwind segues

- (IBAction)photoAdded:(UIStoryboardSegue *)segue
{
    addPhotoViewController *addPhotoVC = (addPhotoViewController *)segue.sourceViewController;
    
    if (addPhotoVC.selectedPhoto) {
        // update the screen display with the 300 x 300 image, not the thumbnail
        self.entryImage = addPhotoVC.selectedPhoto;
        if ([self.dataEntryDelegate respondsToSelector:@selector(entryImageChanged:)]) {
            [self.dataEntryDelegate entryImageChanged:addPhotoVC.selectedPhoto];
        }
    }
    else {
        // photo was removed
        self.entryImage = nil;
        if ([self.dataEntryDelegate respondsToSelector:@selector(entryImageChanged:)]) {
            [self.dataEntryDelegate entryImageChanged:nil];
        }
    }
    self.entryHasChanged = YES;
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
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.entryHasChanged = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.entryHasChanged) {
        self.entryHasChanged = NO;
        NSString *trimmedText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([self.dataEntryDelegate respondsToSelector:@selector(entryTextChanged:autoAdvance:)]) {
            [self.dataEntryDelegate entryTextChanged:trimmedText autoAdvance:self.advanceView];
        }
    }
}



#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addPhotoSegue"]) {
        addPhotoViewController *destinationVC = (addPhotoViewController *)segue.destinationViewController;
        destinationVC.selectedPhoto = self.entryImage;
    }
}

@end
