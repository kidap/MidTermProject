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

@interface AddMomentViewController ()<UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) NSSet<NSString *> *tags;
@property (strong, nonatomic) IBOutlet UIView *tagsViewWrapper;
@property (strong, nonatomic) IBOutlet UIStackView *tagsView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation AddMomentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}
-(void)viewDidAppear:(BOOL)animated{
  if (self.imageView.image == nil){
  [self getImage];
  }
}

- (IBAction)saveMoment:(id)sender {
  
  Trip *trip = [[[CoreDataHandler sharedInstance] getAllTrips] firstObject];
  NSSet *tags = [[NSSet alloc] init];
                
  
  [[CoreDataHandler sharedInstance] createMomentWithImage:self.imageView.image
                                                    notes:self.notesTextView.text
                                                      day:[self getDay]
                                                     trip:trip
                                                     tags:tags];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(int)getDay{
  return 1;
}
-(void)getImage{
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
      [self addButtonTagWithName:tag];
      [self.activityIndicatorView stopAnimating];
    });
    
  }];
  
  
  [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: Helper methods
-(void)addButtonTagWithName:(NSString *)name{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

  [button addTarget:self
             action:@selector(buttonPressed:)
   forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:name forState:UIControlStateNormal];
  
  CGSize buttonSize = [button intrinsicContentSize];
  
  button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
  
  [self.tagsView addSubview:button];
  [self.tagsView layoutIfNeeded];
}
//MARK: Actions
-(void)buttonPressed:(UIButton *)button{
  NSLog(@"Button pressed");
}

@end
