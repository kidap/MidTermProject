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
@import MobileCoreServices;
@import AssetsLibrary;
@import CoreLocation;
@import ImageIO;

static bool askWatson = NO;
static NSString *dateFormat = @"MM/dd/yyyy";

@interface AddMomentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIView *tagsViewWrapper;
@property (weak, nonatomic) IBOutlet UIStackView *tagsView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *watsonLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSMutableArray<NSString *> *sourceArray;
@property (strong, nonatomic) NSDate *photoTakenDate;
@property (strong, nonatomic) CLLocation *photoTakenLocation;
@property (strong, nonatomic) NSSet<NSString *> *tags;
@property (assign, nonatomic) bool editMode;
@property (assign, nonatomic) bool imageSelected;
@property (assign, nonatomic) bool selectAllTags;
@end

@implementation AddMomentViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self prepareView];
  [self prepareDelegates];
  [self watsonThinkingEnded];//Initialize
}
-(void)viewDidAppear:(BOOL)animated{
  if (!self.moment && !self.imageSelected){
    [self displayImagePicker];
  }
}
-(void)viewDidLayoutSubviews{
  CGSize size = self.scrollView.contentSize;
  size.width = CGRectGetWidth(self.view.bounds);
  self.scrollView.contentSize = size;
  
  //select all initial tags
  if(self.selectAllTags){
    for (int x = 0; x<self.sourceArray.count-1;x++){
      NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:x inSection:0];
      [self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:newIndexPath];
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      self.selectAllTags = NO;
    }
  }
}
//MARK: Preparation
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  [self.sourceArray addObject:@""];
  self.tableView.allowsMultipleSelection = YES;
  
  self.notesTextView.layer.borderWidth  = 0.5;
  self.notesTextView.layer.borderColor  = [UIColor lightGrayColor].CGColor;
  self.notesTextView.layer.cornerRadius  = 5.0;
  [self.notesTextView setTextColor:[UIColor lightGrayColor]];
  
  self.photoTakenDate = [[NSDate alloc] init];
  self.photoTakenLocation = [[CLLocation alloc] init];
  
  //Tap image to uploade image
  [self.imageView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImagePicker)];
  [self.imageView addGestureRecognizer:imageTapGesture];
  
  //Notifications - Keyboard
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
  
  //Tap view to dismiss keyboard
  self.scrollView.directionalLockEnabled = YES;
  self.scrollView.alwaysBounceHorizontal = NO;
  self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  
  if (self.moment){
    //    //Set up view
    self.editMode = YES;
    //    self.imageView.alpha = 1;
    //    self.deleteButton.alpha = 1;
    //    self.saveButton.hidden = YES;
    
    //Add save button navigation bar
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveMoment:)];
    self.navigationItem.rightBarButtonItem = save;
    
    //Populates fields
    [self populateElementsFromMoment];
  }
}
-(void)prepareDelegates{
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.notesTextView.delegate = self;
}
-(void)populateElementsFromMoment{
  self.imageView.image = [UIImage imageWithData:self.moment.image];
  self.notesTextView.text = self.moment.notes;
  self.photoTakenDate = self.moment.date;
  for (Tag *tag in [self.moment.tags allObjects]){
    //    [self addTagWithName:tag.tagName];
    NSString *tagName = [[tag.tagName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0];
    [self.sourceArray insertObject:tagName atIndex:newIndexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    self.selectAllTags = YES;
  }
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
//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  NSLog(@"%@",info);
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  self.imageView.alpha = 1;
  self.imageSelected = YES;
  
  //Ask Watson what is in the image
  if (askWatson){
    //Display spinner while Watson is thinking
    [self watsonThinkingBegan];
    
    [[WatsonVisualRecognition sharedInstance] getTagUsingWatson:self.imageView.image completionHandler:^(bool result, NSSet * tags) {
      NSLog(@"received reply from Watson");
      NSArray *tagsArray = [tags allObjects];
      
      //Update tags shown on view
      dispatch_async(dispatch_get_main_queue(), ^{
        for (int x = 0; x<=2;x++){
          NSString *tag = tagsArray[x];
          [self addTagWithName:tag];
          [self watsonThinkingEnded];
        }
      });
    }];
  }
  
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    NSDictionary *exifMetadata = [metadata objectForKey:(id)kCGImagePropertyExifDictionary];
    NSString *dateString = [exifMetadata objectForKey:(id)kCGImagePropertyExifDateTimeOriginal];
    
    NSString *dateFormat = @"yyyy:MM:dd HH:mm:ss";
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:dateFormat];
    self.photoTakenDate = [f dateFromString:dateString];
    
  } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
    
    //Get the date whent the photo was taken
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
      ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
      
      [lib assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        //NSLog(@"created: %@", [asset valueForProperty:ALAssetPropertyDate]);
        
        //Get date when the photo was taken
        self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
        self.photoTakenLocation = [asset valueForProperty:ALAssetPropertyLocation];
        
        //Get location from picture
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        //Get location of user
        [reverseGeocoder reverseGeocodeLocation:self.photoTakenLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
          CLPlacemark *currentPlacemark;
          for (CLPlacemark *placemark in placemarks){
            currentPlacemark = placemark;
            
            NSLog(@"subLocality:%@",placemark.subLocality);
            for (NSString *place in placemark.areasOfInterest){
              //Split text if there is a /
              NSArray *splitPlaces = [place componentsSeparatedByString:@"/"];
              NSLog(@"areasOfInterest:%@",place);
              for (NSString *singlePlace in splitPlaces){
                dispatch_async(dispatch_get_main_queue(), ^{
                  [self addTagWithName:singlePlace];
                });
              }
            }
          }
        }];
        
      } failureBlock:^(NSError *error) {
        NSLog(@"error: %@", error);
      }];
    }
  }
  
  
  [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: TextField/TextView delegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
  textView.text = @"";
  [textView setTextColor:[UIColor blackColor]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}
//MARK:Actions
- (IBAction)saveMoment:(id)sender {
  
  Trip *trip = [[CoreDataHandler sharedInstance] getTripWithDate:self.photoTakenDate];
  NSLog(@"Saving to Country:%@, City:%@",trip.country,trip.city);
  
  if (trip){
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    
    //Get all selected rows and create(retrieve is there is already an existing) a tag
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows){
      Tag *tag = [[CoreDataHandler sharedInstance] createTagWithName:self.sourceArray[indexPath.row]];
      [tags addObject:tag];
    }
    
    //Save moment with tag and trip
    
    if (!self.moment){
      [[CoreDataHandler sharedInstance] createMomentWithImage:self.imageView.image
                                                        notes:self.notesTextView.text
                                            datePhotoWasTaken:self.photoTakenDate
                                                         trip:trip
                                                         tags:tags];
    } else{
      [[CoreDataHandler sharedInstance] updateMoment:self.moment
                                               image:self.imageView.image
                                               notes:self.notesTextView.text
                                   datePhotoWasTaken:self.photoTakenDate
                                                trip:trip
                                                tags:tags];
    }
    
    
    NSString *messageString = [NSString stringWithFormat:@"Moment saved in your trip to %@ (%@)",trip.city,trip.dates];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Moment saved" message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    //Add ok button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      if (self.delegate){
        [self.delegate reloadData];
      }
      [self dismissViewControllerAnimated:YES completion:nil];
      [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
  } else {
    NSLog(@"Trip was not determined");
    NSString *messageString = [NSString stringWithFormat:@"There is no trip on %@",[self convertDateToString:self.photoTakenDate]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Moment not saved" message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    //Add ok button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      //[self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
  }
}
- (IBAction)cancelButtonTapped:(id)sender {
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
    //[self.tableView reloadData];
  }]];
  //Add cancel button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //do nothing
  }]];
  
  [self presentViewController:alertController animated:YES completion:nil];
}

-(void)dismissKB{
  [self.notesTextView resignFirstResponder];
  NSLog(@"Scroll view tapped");
}

//MARK: Helper methods
-(void)addTagWithName:(NSString *)name{
  NSString *tagName = [[name lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.sourceArray.count-1 inSection:0];
  [self.sourceArray insertObject:tagName atIndex:newIndexPath.row];
  [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:newIndexPath];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(int)getDayFromImage:(UIImage *)image trip:(Trip *)trip{
  
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
-(void)watsonThinkingBegan{
  self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  [self.activityIndicatorView startAnimating];
  self.watsonLabel.alpha = 1;
  self.activityIndicatorView.alpha = 1;
}
-(void)watsonThinkingEnded{
  [self.activityIndicatorView stopAnimating];
  self.watsonLabel.alpha = 0;
  self.activityIndicatorView.alpha = 0;
}
//MARK: Handle keyboard
-(void)keyboardShow:(NSNotification *)notification{
  NSValue *value = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
  CGFloat keyboardHeight = CGRectGetHeight([value CGRectValue]);
  
  CGPoint offset = CGPointMake(0, (keyboardHeight/2)+30);
  NSLog(@"%f",keyboardHeight);
  [self.scrollView setContentOffset:offset animated:YES];
}

-(void)keyboardHide:(NSNotification *)notification{
  NSValue *value = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
  CGFloat keyboardHeight = CGRectGetHeight([value CGRectValue]);
  
  CGPoint offset = CGPointMake(0, 0);
  NSLog(@"%f",keyboardHeight);
  [self.scrollView setContentOffset:offset animated:YES];
}
-(NSString *)convertDateToString:(NSDate *)date{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  return [f stringFromDate:date];
}
-(NSDate *)convertStringToDate:(NSString *)dateString{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  return [f dateFromString:dateString];
}
@end
