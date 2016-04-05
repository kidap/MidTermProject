//
//  AddMomentViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "AddMomentViewController.h"
#import "CoreDataHandler.h"
#import "WatsonVisualRecognition.h"
#import "Moment.h"
#import "Tag.h"
#import "Trip.h"

@interface AddMomentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) NSSet<NSString *> *tags;
@property (strong, nonatomic) IBOutlet UIView *tagsViewWrapper;
@property (strong, nonatomic) IBOutlet UIStackView *tagsView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *sourceArray;
@end

@implementation AddMomentViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self prepareView];
  [self prepareDelegates];
}
-(void)viewDidAppear:(BOOL)animated{
  if (self.imageView.image == nil){
    //[self displayImagePicker];
  }
}
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  [self.sourceArray addObject:@""];
  self.tableView.allowsMultipleSelection = YES;
}
-(void)prepareDelegates{
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
}

//MARK: TableView delegate, datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell;
  if (indexPath.row < self.sourceArray.count - 1){
    cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
    cell.textLabel.text = self.sourceArray[indexPath.row];
  } else{
    cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
    //cell.textLabel.text = self.sourceArray[indexPath.row];
  }
  return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  if (indexPath.row < self.sourceArray.count - 1){
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = self.sourceArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
  if (indexPath.row < self.sourceArray.count - 1){
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = self.sourceArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  return @"Tags";
}
//MARK:Actions
- (IBAction)saveMoment:(id)sender {
  
  Trip *trip = [[[CoreDataHandler sharedInstance] getAllTrips] firstObject];
  NSMutableSet *tags = [[NSMutableSet alloc] init];
  
  //Get all selected rows and create(retrieve is there is already an existing) a tag
  for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows){
    Tag *tag = [[CoreDataHandler sharedInstance] createTagWithName:self.sourceArray[indexPath.row]];
    [tags addObject:tag];
  }
  
  //Save moment with tag and trip
  [[CoreDataHandler sharedInstance] createMomentWithImage:self.imageView.image
                                                    notes:self.notesTextView.text
                                                      day:[self getDay]
                                                     trip:trip
                                                     tags:tags];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addTagTapped:(id)sender {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a new Tag" message:@"Enter tag name" preferredStyle:UIAlertControllerStyleAlert];
  //Add text field
  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //do nothing
  }];
  //Add ok button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self addTagWithName:alertController.textFields[0].text];
    [self.tableView reloadData];
  }]];
  //Add cancel button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //do nothing
  }]];
  
  [self presentViewController:alertController animated:YES completion:nil];
}


//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  
  self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [self.activityIndicatorView startAnimating];
  self.activityIndicatorView.center = self.tagsViewWrapper.center;
  NSLog(@"%@", NSStringFromCGPoint(self.activityIndicatorView.center));
  [self.tagsView addSubview:self.activityIndicatorView];
  
  [[WatsonVisualRecognition sharedInstance] getTagUsingWatson:self.imageView.image completionHandler:^(bool result, NSSet * tags) {
    NSLog(@"received reply");
    NSString *tag = [tags anyObject];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self addTagWithName:tag];
      [self.activityIndicatorView stopAnimating];
    });
    
  }];
  
  
  [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: Helper methods
-(void)addTagWithName:(NSString *)name{
  //  NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0];
  [self.sourceArray insertObject:name atIndex:self.sourceArray.count-1];
  //  [self.tableView insertRowsAtIndexPaths:@[lastIndex] withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView reloadData];
}

-(int)getDay{
  return 1;
}
-(void)displayImagePicker{
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.delegate = self;
  
  //Show an action with Camera and Photo library upload
  UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select image" message:@"Select source" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
  }];
  
  UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
  }];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [actionSheet dismissViewControllerAnimated:YES completion:nil];
  }];
  
  //Disable source type if it is not available
  if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
    cameraAction.enabled = NO;
  }
  [actionSheet addAction:cameraAction];
  
  if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
    libraryAction.enabled = NO;
  }
  [actionSheet addAction:libraryAction];
  
  [actionSheet addAction:cancelAction];
  
  //Display alert controller
  [self presentViewController:actionSheet animated:YES completion:nil];
}
//-(void)addButtonTagWithName:(NSString *)name{
//  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//
//  [button addTarget:self
//             action:@selector(buttonPressed:)
//   forControlEvents:UIControlEventTouchUpInside];
//  [button setTitle:name forState:UIControlStateNormal];
//
//  CGSize buttonSize = [button intrinsicContentSize];
//
//  button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
//
//  [self.tagsView addSubview:button];
//  [self.tagsView layoutIfNeeded];
//}
////MARK: Actions
//-(void)buttonPressed:(UIButton *)button{
//  NSLog(@"Button pressed");
//}

@end
