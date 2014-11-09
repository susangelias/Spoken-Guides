//
//  InfoTableViewController.m
//  Spoken Guides
//
//  Created by Susan Elias on 11/7/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "InfoTableViewController.h"

@interface InfoTableViewController ()

@property (strong, nonatomic) NSArray *AckContentArray;
@property (strong, nonatomic) NSArray *LicenseContentArray;

@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section {
    
    switch(section) {
        case 0:
            return @"Acknowledgements";
        case 1:
            return @"Licenses";
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger rowCount;
    if (section == 0) {
        rowCount = [self.AckContentArray count];
    }
    else if (section == 1) {
        rowCount = [self.LicenseContentArray count];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"infoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.numberOfLines = 0;       // show all the lines
    UIFont *cellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cell.textLabel.font = cellFont;

    if (indexPath.section == 0) {
        // Acknowledgements
        cell.textLabel.text = (NSString *)[self.AckContentArray objectAtIndex:indexPath.row];
     }
    else if (indexPath.section == 1)
    {
        // Licenses
        cell.textLabel.text = (NSString *)[self.LicenseContentArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark UITableViewDelegate
// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *infoText;
    if (indexPath.section == 0) {
        infoText = self.AckContentArray[indexPath.row];
    } else if (indexPath.section == 1) {
        infoText = self.LicenseContentArray[indexPath.row];
    }
    CGSize constraint = CGSizeMake(self.tableView.frame.size.width - 10.0, NSUIntegerMax);
    UIFont *infoCellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:infoCellFont forKey:NSFontAttributeName];
    NSAttributedString *text  = [[NSAttributedString alloc] initWithString:infoText attributes:attributes];
    
    CGRect rect = [text boundingRectWithSize:constraint
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                              context:nil];
    float marginAdjustment = infoCellFont.pointSize + 10.0;
    float rowHeight = ceilf(rect.size.height)+ marginAdjustment;
    
    return rowHeight;
    
}


#pragma mark Initialization

-(NSArray *)AckContentArray
{
    if (!_AckContentArray) {
        _AckContentArray = [[NSArray alloc] initWithObjects:@"Spoken Guides uses the CMU Pocketsphinx library, the CMU Flite library, the CMU CMUCMLTK library (http://cmusphinx.sourceforge.net) and Politepix’s OpenEars (http://www.politepix.com/openears).",
        nil];
    }
    return _AckContentArray;
}

-(NSArray *)LicenseContentArray
{
    if (!_LicenseContentArray) {
        _LicenseContentArray = [[NSArray alloc] initWithObjects:@"Rejecto plugin licensed from PolitePix",
                                @"BlurryModalSegue Copyright (c) 2013 mhupman,licensed under The MIT License",
                                @"MZAppearance Copyright (c) 2013 Michał Zaborowski,licensed under The MIT License",
                                @"UIImage+BlurreddFrame Copyright (c) 2013 Adrián González <bernardogzzf@gmail.com> under The MIT License",
                                @"BNRDynamicTypeManager Copyright (c) 2014 John Gallagher <jgallagher@bignerdranch.com> under The MIT License",
                                @"SZTextView Copyright (c) 2013 glaszig <glaszig@gmail.com> under The MIT License",
                                @"ILTranslucentView Copyright (c) 2013 Ivo Leko under The MIT License",
                                @"App Icon by Dave Gandy, SIL Open Font License",
                                @"All other Icons created by Matt Gentile from http://www.icondeposit.com/ and it is licensed under a Creative Commons Attribution 3.0 Unported License: http://creativecommons.org/licenses/by/3.0/",
                                @"Background pattern from subtlepatterns.com",
                                     nil];
    }
    return _LicenseContentArray;
}
@end
