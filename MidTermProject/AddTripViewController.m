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
@property (assign, nonatomic) bool editMode;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AddTripViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self prepareView];
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
  //  self.saveButton.titleLabel.textColor = [UIColor greenColor];
  
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
-(void)populateElementsFromTrip{
  
  self.countryTextField.text = self.trip.country;
  self.cityTextField.text = self.trip.city;
  
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:@"MM/dd/yyyy"];
  NSString *startDate = [f stringFromDate:self.trip.startDate];
  NSString *endDate = [f stringFromDate:self.trip.endDate];
  
  self.startDateTextField.text = startDate;
  self.endDateTextField.text = endDate;
  
  self.imageView.image = [UIImage imageWithData:self.trip.coverImage];
}

//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
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
  
  NSString *start = self.startDateTextField.text;
  NSString *end = self.endDateTextField.text;
  
  NSString *dateText = [start stringByAppendingString:@"-"];
  dateText = [dateText stringByAppendingString:end];
  
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:@"MM/dd/yyyy"];
  NSDate *startDate = [f dateFromString:start];
  NSDate *endDate = [f dateFromString:end];
  
  //Create Trip if not on edit mode. Else, edit
  if (!self.editMode){
    [[CoreDataHandler sharedInstance] createTripWithCity:self.cityTextField.text
                                                 country:self.countryTextField.text
                                                   dates:dateText
                                               startDate:startDate
                                                 endDate:endDate
                                                   image:self.imageView.image];
  } else{
    [[CoreDataHandler sharedInstance] updateTrip:self.trip
                                            city:self.cityTextField.text
                                         country:self.countryTextField.text
                                           dates:dateText
                                       startDate:startDate
                                         endDate:endDate
                                           image:self.imageView.image];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
  [self.navigationController popViewControllerAnimated:YES];
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
      //[self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
  }
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
