//
//  AddTripViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "AddTripViewController.h"
#import "CoreDataHandler.h"
#import "Trip.h"
#import "PDTSimpleCalendarViewController.h"
#import "PDTSimpleCalendarViewCell.h"
#import "PDTSimpleCalendarViewHeader.h"
@import MobileCoreServices;
@import AssetsLibrary;
@import CoreLocation;

static NSString *dateFormat = @"MM/dd/yyyy";

@interface AddTripViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,PDTSimpleCalendarViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *imageUploadLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *customNavigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) UIPickerView *countryPicker;
@property (strong, nonatomic) NSDate *photoTakenDate;
@property (assign, nonatomic) bool editMode;
@property (assign,nonatomic) NSInteger dateTag;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSArray *sortedCountries;
@property (strong, nonatomic) PDTSimpleCalendarViewController *calendarViewController;
@property (nonatomic, strong) NSMutableArray *customDates;
@property (strong, nonatomic) CLLocation *photoTakenLocation;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewCountry;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewCity;
@end

@implementation AddTripViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self prepareView];
  [self prepareDelegates];
  [self prepareCountryList];
  [self prepareCountryPicker];
}
-(void)prepareView{
  //Init Activity Indicator
  self.activityIndicatorViewCountry.alpha = 0;
  [self.activityIndicatorViewCountry stopAnimating];
  self.activityIndicatorViewCity.alpha = 0;
  [self.activityIndicatorViewCity stopAnimating];
  
  self.saveButton.titleLabel.textColor = [UIColor greenColor];
  
  //Tap image to uploade image
  [self.imageView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(uploadImage:)];
  [self.imageView addGestureRecognizer:imageTapGesture];
  
  //Edit mode
  if (self.trip){
    //Set up view
    self.editMode = YES;
    self.imageView.alpha = 1;
    self.deleteButton.alpha = 1;
    self.saveButton.hidden = YES;
    self.customNavigationBar.hidden = YES;
    self.imageUploadLabel.hidden = YES;
    
    
    //Add save button navigation bar
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(saveTrip:)];
    self.navigationItem.rightBarButtonItem = save;
    self.navigationItem.title = @"Edit Trip";
    
    //Populates fields
    [self populateElementsFromTrip];
  } else{
    self.deleteButton.alpha = 0;
    self.deleteButton.hidden = YES;
    self.saveButton.hidden = YES;
    [self displayImagePicker];
  }
  
  self.imageView.layer.shadowRadius = 3.0f;
  self.imageView.layer.shadowColor = [UIColor grayColor].CGColor;
  self.imageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  self.imageView.layer.shadowOpacity = 0.5f;
}
-(void)prepareDelegates{
  self.countryTextField.delegate = self;
  self.cityTextField.delegate = self;
  self.startDateTextField.delegate = self;
  self.endDateTextField.delegate = self;
}
-(void)populateElementsFromTrip{
  self.countryTextField.text = self.trip.country;
  self.cityTextField.text = self.trip.city;
  self.startDate = self.trip.startDate;
  self.endDate = self.trip.endDate;
  self.imageView.image = [UIImage imageWithData:self.trip.coverImage];
}
-(void)prepareCountryList{
  NSMutableArray *countries = [NSMutableArray arrayWithCapacity: [[NSLocale ISOCountryCodes] count]];
  
  for (NSString *countryCode in [NSLocale ISOCountryCodes])
  {
    NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
    NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
    [countries addObject: country];
  }
  self.sortedCountries = [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
}
-(void)prepareCountryPicker{
  self.countryPicker = [[UIPickerView alloc] init];
  self.countryTextField.inputView = self.countryPicker;
  self.countryPicker.delegate = self;
  self.countryPicker.dataSource = self;
  UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
  keyboardDoneButtonView.barStyle = UIBarStyleBlack;
  keyboardDoneButtonView.translucent = YES;
  keyboardDoneButtonView.tintColor = nil;
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStylePlain target:self
                                                                action:@selector(pickerDoneClicked:)];
  
  [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpaceLeft,doneButton, nil]];
  
  self.countryTextField.inputAccessoryView = keyboardDoneButtonView;
}
-(void)prepareCalendar{
  self.customDates = [[NSMutableArray alloc] init];
  self.calendarViewController = [[PDTSimpleCalendarViewController alloc] init];
  [self.calendarViewController setDelegate:self];
  self.calendarViewController.weekdayHeaderEnabled = YES;
  self.calendarViewController.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
  
  [[PDTSimpleCalendarViewCell appearance] setCircleSelectedColor:[UIColor redColor]];
}
//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  self.imageView.alpha = 1;
  self.imageUploadLabel.alpha = 0;
  
  //Start animating Activity Indicator
  self.activityIndicatorViewCountry.alpha = 1;
  [self.activityIndicatorViewCountry startAnimating];
  self.activityIndicatorViewCity.alpha = 1;
  [self.activityIndicatorViewCity startAnimating];
  
  
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.imageView.image.CGImage
                                 metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                            
                            NSLog(@"assetURL %@", assetURL);
                            [self getMetaDataFromPhotoUsingLibrary:library assetURL: assetURL];
                            
                          }];
    
  } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
    
    //Get the date whent the photo was taken
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
      
      [self getMetaDataFromPhotoUsingLibrary:library assetURL: [info objectForKey:UIImagePickerControllerReferenceURL]];
    }
  }
  //  //Get the date whent the photo was taken
  //  NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  //  if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
  //    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
  //
  //    [lib assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
  //      self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
  //      self.photoTakenLocation = [asset valueForProperty:ALAssetPropertyLocation];
  //      dispatch_async(dispatch_get_main_queue(), ^{
  //        NSLog(@"PhotoTakenDate%@",self.photoTakenDate);
  //        if (!self.trip){
  //          [self setStartDate:self.photoTakenDate];
  //          [self setEndDate:self.photoTakenDate];
  //        }
  //      });
  //
  //      //Get location from picture
  //      CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
  //      //Get location of user
  //      [reverseGeocoder reverseGeocodeLocation:self.photoTakenLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
  //        CLPlacemark *currentPlacemark = [placemarks firstObject];
  //        dispatch_async(dispatch_get_main_queue(), ^{
  //          self.countryTextField.text = currentPlacemark.country;
  //          self.cityTextField.text = currentPlacemark.locality;
  //        });
  //      }];
  //    } failureBlock:^(NSError *error) {
  //      NSLog(@"Error in getting phote metadata: %@", error);
  //    }];
  //  }
  [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void) getMetaDataFromPhotoUsingLibrary:(ALAssetsLibrary *)library assetURL:(NSURL *)assetURL{
  [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
    //NSLog(@"created: %@", [asset valueForProperty:ALAssetPropertyDate]);
    
    //Get date when the photo was taken
    self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
    self.photoTakenLocation = [asset valueForProperty:ALAssetPropertyLocation];
    NSLog(@"Photo Date: %@", [self convertDateToString: self.photoTakenDate]);
    NSLog(@"Photo Location: %@",self.photoTakenLocation);
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!self.trip){
        [self setStartDate:self.photoTakenDate];
        [self setEndDate:self.photoTakenDate];
      }
    });
    
    //Get location from picture
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    //Get location of user
    [reverseGeocoder reverseGeocodeLocation:self.photoTakenLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
      CLPlacemark *currentPlacemark = [placemarks firstObject];
      dispatch_async(dispatch_get_main_queue(), ^{
        self.countryTextField.text = currentPlacemark.country;
        self.cityTextField.text = currentPlacemark.locality;
        
        //Stop animating Activity Indicator
        self.activityIndicatorViewCountry.alpha = 0;
        [self.activityIndicatorViewCountry stopAnimating];
        self.activityIndicatorViewCity.alpha = 0;
        [self.activityIndicatorViewCity stopAnimating];
      });
    }];
  } failureBlock:^(NSError *error) {
    NSLog(@"error: %@", error);
  }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: TextField delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
  //Calendar text fields will have a tag 1 na
  if(textField.tag == 1 ||textField.tag == 2){
    self.dateTag = textField.tag;
    
    [self prepareCalendar];
    
    //Set the start and end circle color
    [self.customDates removeAllObjects];
    NSLog(@"Start Date:%@",[self convertDateToString:self.startDate]);
    NSLog(@"End Date:%@",[self convertDateToString:self.endDate]);
    if (self.startDate){
      [self.customDates addObject:self.startDate];
    }
    if (self.endDate){
      [self.customDates addObject:self.endDate];
    }
    
    //First date on calendar is 5 years ago
    self.calendarViewController.firstDate = [[NSDate date] dateByAddingTimeInterval:-5*365*24*60*60];
    //Last date on calendar is 1 year from now
    self.calendarViewController.lastDate = [[NSDate date] dateByAddingTimeInterval:1*365*24*60*60];
    //Set focus to current date
    if(textField.tag == 1 && (self.startDate || self.endDate)){
      if (self.startDate){
        [self.calendarViewController scrollToDate:self.startDate animated:YES];
      } else if (self.endDate){
        [self.calendarViewController scrollToDate:self.endDate animated:YES];
      }
    } else if(textField.tag == 2 && (self.startDate || self.endDate)){
      if (self.endDate){
        [self.calendarViewController scrollToDate:self.endDate animated:YES];
      } else if (self.startDate){
        [self.calendarViewController scrollToDate:self.startDate animated:YES];
      }
    } else{
      [self.calendarViewController scrollToDate:[NSDate date] animated:YES];
    }
    
    //Create and present Navigation Controller
    UINavigationController *defaultNavController = [[UINavigationController alloc] initWithRootViewController:self.calendarViewController];
    [self.calendarViewController setTitle:@"Select Date"];
    [self presentViewController:defaultNavController animated:YES completion:nil];
  }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}
//MARK: - Country Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  if (self.sortedCountries!=nil) {
    return self.sortedCountries.count;
  }
  return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  if (self.sortedCountries!=nil) {
    return self.sortedCountries[row];
  } else {
    NSLog(@"Error displaying the country picker view");
  }
  return @"-";
}
//MARK: - PDTSimpleCalendarViewDelegate
- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date{
  
  if (self.dateTag == 1){
    //if (!self.endDate || (self.endDate && date <= self.endDate)){
    self.startDate = date;
    //  [self dismissViewControllerAnimated:YES completion:nil];
    //} else{
    //  NSLog(@"Error");
    
    //}
  } else if (self.dateTag == 2){
    //if (!self.startDate || (self.startDate && date >= self.startDate)){
    self.endDate = date;
    //  [self dismissViewControllerAnimated:YES completion:nil];
    //} else{
    //  NSLog(@"Error");
    //}
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller circleColorForDate:(NSDate *)date{
  return [UIColor redColor];
}
- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller textColorForDate:(NSDate *)date{
  return [UIColor whiteColor];
}
- (BOOL)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller shouldUseCustomColorsForDate:(NSDate *)date{
  if ([self.customDates containsObject:date]) {
    return YES;
  }
  
  return NO;
}
//MARK: Actions
- (IBAction)uploadImage:(id)sender {
  [self displayImagePicker];
}
- (IBAction)saveTrip:(id)sender {
  //Create Trip if not on edit mode. Else, edit
  if (!self.editMode){
    [[CoreDataHandler sharedInstance] createTripWithCity:self.cityTextField.text
                                                 country:self.countryTextField.text
                                               startDate:self.startDate
                                                 endDate:self.endDate
                                                   image:self.imageView.image];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
  } else{
      [[CoreDataHandler sharedInstance] updateTrip:self.trip
                                              city:self.cityTextField.text
                                           country:self.countryTextField.text
                                         startDate:self.startDate
                                           endDate:self.endDate
                                             image:self.imageView.image];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

- (IBAction)cancelTrip:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)deleteTrip:(id)sender {
  if(self.trip){
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete trip" message:@"Do you want to delete this trip?" preferredStyle:UIAlertControllerStyleAlert];
    
    //Add ok button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
      [[CoreDataHandler sharedInstance] deleteTrip:self.trip];
      [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    
    //Add cancel button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
  }
}
-(void)pickerDoneClicked:(id)sender{
  self.countryTextField.text = self.sortedCountries[[self.countryPicker selectedRowInComponent:0]];
  [self.countryPicker removeFromSuperview];
  [self.countryTextField resignFirstResponder];
}

//MARK: Helper methods
-(void)setStartDate:(NSDate *)date{
  _startDate = date;
  self.startDateTextField.text = [self convertDateToString:date];
}
-(void)setEndDate:(NSDate *)date{
  _endDate = date;
  self.endDateTextField.text = [self convertDateToString:date];
}
-(void)displayImagePicker{
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.delegate = self;
  
  //Show an action with Camera and Photo library upload
  UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select image source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
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

-(NSString *)convertDateToString:(NSDate *)date{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  return [f stringFromDate:date];
}
@end
