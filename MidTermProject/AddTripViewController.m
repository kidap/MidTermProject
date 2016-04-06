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

static NSString *dateFormat = @"MM/dd/yyyy";

@interface AddTripViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,PDTSimpleCalendarViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) UIPickerView *countryPicker;
@property (strong, nonatomic) NSDate *photoTakenDate;
@property (assign, nonatomic) bool editMode;
@property (assign,nonatomic) NSInteger dateTag;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSArray *sortedCountries;
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
  //  self.cancelButton.layer.borderWidth  = 0.5;
  //  self.cancelButton.layer.borderColor  = [UIColor lightGrayColor].CGColor;
  //  self.cancelButton.layer.cornerRadius  = 5.0;
  //  self.cancelButton.backgroundColor = [UIColor whiteColor];
  //  self.cancelButton.titleLabel.textColor = [UIColor redColor];
  //  self.saveButton.layer.borderWidth  = 0.5;
  //  self.saveButton.layer.borderColor  = [UIColor lightGrayColor].CGColor;
  //  self.saveButton.layer.cornerRadius  = 5.0;
  //  self.saveButton.backgroundColor = [UIColor whiteColor];
  
  self.saveButton.titleLabel.textColor = [UIColor greenColor];
  
  //Tap image to uploade image
  [self.imageView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadImage:)];
  [self.imageView addGestureRecognizer:imageTapGesture];
  
  //Edit mode
  if (self.trip){
    //Set up view
    self.editMode = YES;
    self.imageView.alpha = 1;
    self.deleteButton.alpha = 1;
    self.saveButton.hidden = YES;
    
    //Add save button navigation bar
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveTrip:)];
    self.navigationItem.rightBarButtonItem = save;
    
    //Populates fields
    [self populateElementsFromTrip];
  } else{
    self.deleteButton.alpha = 0;
    self.deleteButton.hidden = YES;
    self.saveButton.hidden = YES;
    [self displayImagePicker];
  }
  
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
  
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  NSString *startDate = [f stringFromDate:self.trip.startDate];
  NSString *endDate = [f stringFromDate:self.trip.endDate];
  
  self.startDateTextField.text = startDate;
  self.endDateTextField.text = endDate;
  
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
//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  
  //Get the date whent the photo was taken
  NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
      //NSLog(@"created: %@", [asset valueForProperty:ALAssetPropertyDate]);
      self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
      [self setStartDate:self.photoTakenDate];
      [self setEndDate:self.photoTakenDate];
    } failureBlock:^(NSError *error) {
      NSLog(@"error: %@", error);
    }];
  }
  [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
  //Calendar text fields will have a tag 1 na
  if(textField.tag == 1 ||textField.tag == 2){
    self.dateTag = textField.tag;
    PDTSimpleCalendarViewController *calendarViewController = [[PDTSimpleCalendarViewController alloc] init];
    [calendarViewController setDelegate:self];
    calendarViewController.weekdayHeaderEnabled = YES;
    calendarViewController.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
    
    //Create Navigation Controller
    UINavigationController *defaultNavController = [[UINavigationController alloc] initWithRootViewController:calendarViewController];
    [calendarViewController setTitle:@"Select Date"];
    
    
    [self presentViewController:defaultNavController animated:YES completion:nil];
  }
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
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//  self.countryTextField.text = self.sortedCountries[row];
//  [self.countryTextField resignFirstResponder];
//}

//MARK: - PDTSimpleCalendarViewDelegate
- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date{
  if (self.dateTag == 1){
    self.startDate = date;
  } else if (self.dateTag == 2){
    self.endDate = date;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller circleColorForDate:(NSDate *)date{
  return [UIColor whiteColor];
}
- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller textColorForDate:(NSDate *)date{
  return [UIColor orangeColor];
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
     //dates:dateText
                                               startDate:self.startDate
                                                 endDate:self.endDate
                                                   image:self.imageView.image];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
  } else{
    [[CoreDataHandler sharedInstance] updateTrip:self.trip
                                            city:self.cityTextField.text
                                         country:self.countryTextField.text
     //dates:dateText
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
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
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
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  NSString *dateString = [f stringFromDate:date];
  
  self.startDateTextField.text = dateString;
}
-(void)setEndDate:(NSDate *)date{
  _endDate = date;
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  NSString *dateString = [f stringFromDate:date];
  
  self.endDateTextField.text = dateString;
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

@end
