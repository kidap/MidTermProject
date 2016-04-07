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
#import "TagCollectionViewCell.h"
@import MobileCoreServices;
@import AssetsLibrary;
@import CoreLocation;
@import ImageIO;

static bool askWatson = YES;
static NSString *dateFormat = @"MM/dd/yyyy";

@interface AddMomentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
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
@property (strong, nonatomic) NSString *photoTakenCountry;
@property (strong, nonatomic) NSString *photoTakenCity;
@property (strong, nonatomic) NSSet<NSString *> *tags;
@property (assign, nonatomic) bool editMode;
@property (assign, nonatomic) bool imageSelected;
@property (assign, nonatomic) bool selectAllTags;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *customNavigationBar;
@property (weak, nonatomic) IBOutlet UIView *watsonView;
@property (assign, nonatomic) bool isWatsonThinking;
@property (strong, nonatomic) IBOutlet UIView *watsonNotificationView;
@end

@implementation AddMomentViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self prepareView];
  [self prepareDelegates];
  [self watsonThinkingEnded];//Initialize
}
-(void)viewWillAppear:(BOOL)animated{
  
  if (!self.moment && !self.imageSelected){
    [self displayImagePicker];
  }
  
  if (self.isWatsonThinking){
    
    self.watsonView.layer.shadowRadius = 3.0f;
    self.watsonView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.watsonView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.watsonView.layer.shadowOpacity = 0.5f;
    self.watsonView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:1 animations:^{
      self.watsonView.center = CGPointMake(self.watsonView.center.x, (self.watsonView.center.y - self.watsonView.frame.size.height - 40 ));
    } completion:^(BOOL finished) {
      
      [UIView animateWithDuration:1 delay:5 options:UIViewAnimationOptionTransitionNone animations:^{
        self.watsonView.center = CGPointMake(self.watsonView.center.x, (self.watsonView.center.y + self.watsonView.frame.size.height) + 40 );
      } completion:^(BOOL finished) {
        NSLog(@"animation done");
      }];
    }];
  }
}
-(void)viewDidAppear:(BOOL)animated{
}
-(void)viewDidLayoutSubviews{
  CGSize size = self.scrollView.contentSize;
  size.width = CGRectGetWidth(self.view.bounds);
  self.scrollView.contentSize = size;
  
  //select all initial tags
  [self.collectionView reloadData];
  if(self.selectAllTags && self.sourceArray.count != 0){
    for (int x = 0; x<self.sourceArray.count;x++){
      NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:x inSection:0];
      [self.collectionView selectItemAtIndexPath:newIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
      TagCollectionViewCell *tagCell = (TagCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];
      if(tagCell){
        [tagCell setSelected:YES];
        [self.collectionView selectItemAtIndexPath:newIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        self.selectAllTags = NO;
      }
    }
  }
}
//MARK: Preparation
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  //[self.sourceArray addObject:@""];
  self.collectionView.allowsMultipleSelection = YES;
  
  
  [self.view addSubview:self.watsonView];
  self.watsonView.center = CGPointMake(self.view.center.x, (self.view.center.y + self.watsonView.frame.size.height*1.5));
  
  self.notesTextView.layer.borderWidth  = 0.5;
  self.notesTextView.layer.borderColor  = [UIColor colorWithRed:0.325 green:0.518 blue:0.635 alpha:1].CGColor;//[UIColor lightGrayColor].CGColor;
  self.notesTextView.layer.cornerRadius  = 5.0;
  
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
    self.editMode = YES;
    self.customNavigationBar.hidden = YES;
    self.imageView.alpha = 1.0;
    
    //Add save button navigation bar
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveMoment:)];
    self.navigationItem.rightBarButtonItem = save;
    
    //Populates fields
    [self populateElementsFromMoment];
  }
}
-(void)prepareDelegates{
//  self.tableView.delegate = self;
//  self.tableView.dataSource = self;
  self.notesTextView.delegate = self;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}
-(void)populateElementsFromMoment{
  self.imageView.image = [UIImage imageWithData:self.moment.image];
  self.notesTextView.text = self.moment.notes;
  self.photoTakenDate = self.moment.date;
  for (Tag *tag in [self.moment.tags allObjects]){
    //    [self addTagWithName:tag.tagName];
    NSString *tagName = [[tag.tagName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSIndexPath *newIndexPath;
    if(self.sourceArray.count != 0){
      newIndexPath = [NSIndexPath indexPathForRow:self.sourceArray.count inSection:0];
      [self.sourceArray insertObject:tagName atIndex:newIndexPath.row];
    } else{
      newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      [self.sourceArray addObject:tagName];
    }
    self.selectAllTags = YES;
  }
}
//MARK: Collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
  
  cell.tagLabel.text = self.sourceArray[indexPath.row];
  if (cell.selected){
    cell.tagLabel.textColor = [UIColor whiteColor];
  } else{
    cell.tagLabel.textColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
  }
  
  cell.layer.borderWidth  = 0.5;
  cell.layer.cornerRadius  = 5.0;
  cell.layer.borderColor  = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1].CGColor;
  return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  //  CustomCollectionViewCell *cell = (CustomCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
  
  CGSize size = [(NSString*)[self.sourceArray objectAtIndex:indexPath.row] sizeWithAttributes:attributes];
  size.width += 20;
  size.height = 35;
  return size;
}

//MARK: Image Picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  NSLog(@"%@",info);
  [self.imageView setImage: info[@"UIImagePickerControllerOriginalImage"]];
  self.imageView.alpha = 1.0;
  self.imageSelected = YES;
  [self.sourceArray removeAllObjects];
  
  //Ask Watson what is in the image
  if (askWatson){
    //Display spinner while Watson is thinking
    [self watsonThinkingBegan];
    
    [[WatsonVisualRecognition sharedInstance] getTagUsingWatson:self.imageView.image completionHandler:^(bool result, NSSet * tags) {
      NSLog(@"received reply from Watson");
      NSArray *tagsArray = [tags allObjects];
      
      //Update tags shown on view
      dispatch_async(dispatch_get_main_queue(), ^{
        for (int x = 0; x<=tagsArray.count - 1;x++){
          NSString *tag = tagsArray[x];
          [self addTagWithName:tag];
        }
        [self watsonThinkingEnded];
      });
    }];
  }
  
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
    //    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    //    NSDictionary *exifMetadata = [metadata objectForKey:(id)kCGImagePropertyExifDictionary];
    //    NSString *dateString = [exifMetadata objectForKey:(id)kCGImagePropertyExifDateTimeOriginal];
    //
    //    NSString *dateFormat = @"yyyy:MM:dd HH:mm:ss";
    //    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    //    [f setDateFormat:dateFormat];
    //    self.photoTakenDate = [f dateFromString:dateString];
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
      //      [lib assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
      //        //NSLog(@"created: %@", [asset valueForProperty:ALAssetPropertyDate]);
      //
      //        //Get date when the photo was taken
      //        self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
      //        self.photoTakenLocation = [asset valueForProperty:ALAssetPropertyLocation];
      //
      //        //Get location from picture
      //        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
      //        //Get location of user
      //        [reverseGeocoder reverseGeocodeLocation:self.photoTakenLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
      //          CLPlacemark *currentPlacemark;
      //          for (CLPlacemark *placemark in placemarks){
      //            currentPlacemark = placemark;
      //
      //            NSLog(@"subLocality:%@",placemark.subLocality);
      //            for (NSString *place in placemark.areasOfInterest){
      //              //Split text if there is a /
      //              NSArray *splitPlaces = [place componentsSeparatedByString:@"/"];
      //              NSLog(@"areasOfInterest:%@",place);
      //              for (NSString *singlePlace in splitPlaces){
      //                dispatch_async(dispatch_get_main_queue(), ^{
      //                  [self addTagWithName:singlePlace];
      //                });
      //              }
      //            }
      //          }
      //        }];
      //
      //      } failureBlock:^(NSError *error) {
      //        NSLog(@"error: %@", error);
      //      }];
    }
  }
  
  [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: Text view delegate
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
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems){
      Tag *tag = [[CoreDataHandler sharedInstance] createTagWithName:self.sourceArray[indexPath.row]];
      [tags addObject:tag];
    }
    
    //Save moment with tag and trip
    //If the moment doesn't exist yet, create moment. Else, update the existing moment
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
    
    NSString *messageString = [NSString stringWithFormat:@"Added moment to your trip to %@ (%@)",trip.city,trip.dates];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Saved" message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
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
    
    //    //Check if there is a trip close to this moment
    //    Trip *closestTrip = [[CoreDataHandler sharedInstance] getTripNearDate:self.photoTakenDate
    //                                                                inCountry:self.photoTakenCountry
    //                                                                     City:self.photoTakenCity];
    //
    //    //Ask user if they want to add the moment to this trip
    //    if (closestTrip){
    //      NSString *titleString = [NSString stringWithFormat:@"Do you want to add this moment to your trip to %@ (%@)?",trip.city,trip.dates];
    //      NSString *messageString = [NSString stringWithFormat:@""];
    //      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleString
    //                                                                               message:messageString
    //                                                                        preferredStyle:UIAlertControllerStyleAlert];
    //
    //      //Add ok button
    //      [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        if (self.delegate){
    //
    //          //Adjust the dates of the trip
    //          Moment *adjustedMoment;
    //
    //          //Adjust the days of the trip
    //
    //          //Add the moment
    //
    //          [[CoreDataHandler sharedInstance] updateMoment:adjustedMoment
    //                                                   image:self.imageView.image
    //                                                   notes:self.notesTextView.text
    //                                       datePhotoWasTaken:self.photoTakenDate
    //                                                    trip:trip
    //                                                    tags:tags];
    //
    //          [self.delegate reloadData];
    //        }
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //        [self.navigationController popViewControllerAnimated:YES];
    //      }]];
    //      [self presentViewController:alertController animated:YES completion:nil];
    //
    //    } else{
    NSLog(@"Trip was not determined");
    NSString *messageString = [NSString stringWithFormat:@"There is no trip on %@",[self convertDateToString:self.photoTakenDate]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please create a trip first then reupload this moment" message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    //Add ok button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    //    }
  }
}
- (IBAction)cancelButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addTagTapped:(id)sender {
  [self.notesTextView resignFirstResponder];
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a new Tag" message:@"Enter tag name" preferredStyle:UIAlertControllerStyleAlert];
  //Add text field
  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //do nothing
  }];
  //Add ok button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self addTagWithName:alertController.textFields[0].text];
  }]];
  //Add cancel button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
  
  [self presentViewController:alertController animated:YES completion:nil];
}

-(void)dismissKB{
  [self.notesTextView resignFirstResponder];
  NSLog(@"Scroll view tapped");
}

//MARK: Helper methods
-(void)addTagWithName:(NSString *)name{
  NSString *tagName = [[name lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSIndexPath *newIndexPath;
  if(self.sourceArray.count != 0){
    newIndexPath = [NSIndexPath indexPathForRow:self.sourceArray.count inSection:0];
    [self.sourceArray insertObject:tagName atIndex:newIndexPath.row];
  } else{
    newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.sourceArray addObject:tagName];
  }
  
 //Add tag and select it by default
  [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
  
  //Default bg color or cell
  TagCollectionViewCell *cell = (TagCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];
  cell.contentView.backgroundColor=[UIColor whiteColor];

}
-(int)getDayFromImage:(UIImage *)image trip:(Trip *)trip{
  return 1;
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

//MARK:Watson
-(void)watsonThinkingBegan{
  self.isWatsonThinking = YES;
  self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  [self.activityIndicatorView startAnimating];
  self.watsonLabel.alpha = 1;
  self.watsonNotificationView.alpha = 1;
  self.activityIndicatorView.alpha = 1;
}
-(void)watsonThinkingEnded{
  self.isWatsonThinking = NO;
  [self.activityIndicatorView stopAnimating];
  self.watsonLabel.alpha = 0;
  self.watsonNotificationView.alpha = 0;
  self.activityIndicatorView.alpha = 0;
}
-(void) getMetaDataFromPhotoUsingLibrary:(ALAssetsLibrary *)library assetURL:(NSURL *)assetURL{
  [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
    //NSLog(@"created: %@", [asset valueForProperty:ALAssetPropertyDate]);
    
    //Get date when the photo was taken
    self.photoTakenDate = [asset valueForProperty:ALAssetPropertyDate];
    self.photoTakenLocation = [asset valueForProperty:ALAssetPropertyLocation];
    NSLog(@"Photo Date: %@", [self convertDateToString: self.photoTakenDate]);
    NSLog(@"Photo Location: %@",self.photoTakenLocation);
    
    //Get location from picture
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    //Get location of user
    [reverseGeocoder reverseGeocodeLocation:self.photoTakenLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
      CLPlacemark *currentPlacemark;
      for (CLPlacemark *placemark in placemarks){
        currentPlacemark = placemark;
        
        self.photoTakenCountry = currentPlacemark.country;
        self.photoTakenCity = currentPlacemark.locality;
        
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
