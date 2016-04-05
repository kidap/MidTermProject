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

@interface AddTripViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (assign, nonatomic) bool editMode;

@end

@implementation AddTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self prepareView];
}
-(void)prepareView{
  self.uploadButton.center = self.imageView.center;
  
  if (self.imageView.image == nil){
    self.uploadButton.alpha = 1;
  } else {
    self.uploadButton.alpha = 0;
  }
  
  if (self.trip){
    self.editMode = YES;
//    [CoreDataHandler sharedInstance]
  }
}

//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  self.uploadButton.alpha = 0;
  [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: Actions

- (IBAction)uploadImage:(id)sender {
    [self displayImagePicker];
}

- (IBAction)saveTrip:(id)sender {
  NSString *dateText = [self.startDateTextField.text stringByAppendingString:@"-"];
  dateText = [dateText stringByAppendingString:self.endDateTextField.text];

  
  NSString *start = @"04/01/2016";
  NSString *end = @"04/30/2016";
  
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:@"MM/dd/yyyy"];
  NSDate *startDate = [f dateFromString:start];
  NSDate *endDate = [f dateFromString:end];
  
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                      fromDate:startDate
                                                        toDate:endDate
                                                       options:NSCalendarWrapComponents];
  int dayOfTrip = (int)[components day];
  
  //Create. else, edit
  if (!self.editMode){
  [[CoreDataHandler sharedInstance] createTripWithCity:self.cityTextField.text
                                                 dates:dateText
                                             startDate:startDate
                                               endDate:endDate
                                             totalDays:dayOfTrip
                                                 image:self.imageView.image];
  } else{
  
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelTrip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: Helper methods
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
