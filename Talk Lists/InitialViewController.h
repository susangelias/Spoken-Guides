//
//  InitialViewViewController.h
//  Talk Lists
//
//  Created by Susan Elias on 7/25/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InitialViewController : UIViewController

//@property (nonatomic, strong) NSDictionary *filters;
//@property (nonatomic, strong) NSDictionary *sortChoices;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoryButton;

-(void) setHeaderTitle:(NSString*)headerTitle andSubtitle:(NSString*)headerSubtitle;
- (IBAction) goToRoot:(UIStoryboardSegue *)segue;

@end
