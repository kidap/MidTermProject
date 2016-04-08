//
//  MomentMainViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "MomentMainViewController.h"
#import "CoreDataHandler.h"
#import "MomentCollectionViewCell.h"
#import "Trip.h"
#import "Tag.h"
#import "Moment.h"
#import "AddMomentViewController.h"
#import "MomentPhotoViewController.h"

static NSString *dateFormat = @"MM/dd/yyyy HH:mm:ss";

@interface MomentMainViewController()<UICollectionViewDelegate, UICollectionViewDataSource,momentDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Moment *> *sourceArray;
@property (strong, nonatomic) UIBarButtonItem *editToggleButton;
@property (assign, nonatomic) bool isEditMode;
@end
@implementation MomentMainViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  
  [self prepareView];
  [self prepareDelegate];
  [self prepareGestures];
}
-(void)prepareView{
  self.sourceArray = [[NSArray alloc] init];
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  self.editToggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editMoment:)];
  self.navigationItem.rightBarButtonItem = self.editToggleButton;
  
  //if selected using a trip, get moments related to trip
  //else, tag was used to get all moments
  if (self.trip){
    NSSet *moments = self.trip.moments;
    
    //Filter based on day selected
    if (self.day != 0){
//      NSString *fieldName = @"day";
//      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,self.day];
      //day 1 = start date + 1
      //day 2 = start date + 1
      NSString *fieldName = @"date";
      int day = self.day - 1;
      NSDate *newDateStartOfDay = [self.trip.startDate dateByAddingTimeInterval:60*60*24*day];
      NSDate *newDateEndOfDay = [self.trip.startDate dateByAddingTimeInterval:(60*60*24*(day+1))-1];
//      NSLog(@"Start:%@,New:%@,New:%@",self.trip.startDate,newDateStartOfDay,newDateEndOfDay);
      
      NSLog(@"Start:%@,New:%@,New:%@",[self convertDateToString: self.trip.startDate],
            [self convertDateToString:newDateStartOfDay],[self convertDateToString:newDateEndOfDay]);
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)",fieldName,newDateStartOfDay,fieldName,newDateEndOfDay];
      
      self.sourceArray = [[moments allObjects] filteredArrayUsingPredicate:predicate];
    } else{
      self.sourceArray = [moments allObjects];
    }
  } else {
    self.sourceArray = self.moments;
  }
  
  //Sort by date ASCENDING
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
  self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor]];
  
  //Set title of the navigation bar
  if (self.day != 0){
    self.navigationItem.title = [NSString stringWithFormat:@"Day %d",self.day];
  } else{
    if ([self.navTitle isEqualToString:@""] || !self.navTitle){
      self.navigationItem.title = @"All";
    } else{
      self.navigationItem.title = self.navTitle;
    }
  }
  NSLog(@"Moment Main view did load");
  [[CoreDataHandler sharedInstance] logRegisteredObjects];
}
-(void)prepareDelegate{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}
-(void)prepareGestures{
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
  [self.collectionView addGestureRecognizer:longPressGesture];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
  [self.collectionView addGestureRecognizer:tapGesture];
}
//MARK:Collection delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  MomentCollectionViewCell *momentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"momentCell" forIndexPath:indexPath];
  
  momentCell.imageView.image = [UIImage imageWithData:self.sourceArray[indexPath.row].image];
  if (![self.sourceArray[indexPath.row].notes isEqualToString:@"<add notes>"]){
    momentCell.notes.text = self.sourceArray[indexPath.row].notes;
  }
  
  //  momentCell.imageView.layer.borderWidth = 0.5;
  //  momentCell.imageView.layer.borderColor  = [UIColor grayColor].CGColor;
  
  momentCell.layer.shadowRadius = 3.0f;
  //momentCell.layer.shadowColor = [UIColor colorWithRed:0.325 green:0.518 blue:0.635 alpha:1].CGColor;//[UIColor grayColor].CGColor;
  momentCell.layer.shadowColor = [UIColor colorWithRed:0.333 green:0.243 blue:0.322 alpha:1].CGColor;
  momentCell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  momentCell.layer.shadowOpacity = 0.5f;
  momentCell.layer.masksToBounds = NO;
  momentCell.backgroundColor = [UIColor whiteColor];
  
  NSLog(@"Moment date%@",[self convertDateToString: self.sourceArray[indexPath.row].date]);
  
  return momentCell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  //  [self performSegueWithIdentifier:@"showFullScreenPhoto" sender:self];
}
//MARK: Moment delegate
-(void)reloadData{
  if (self.trip){
    self.trip = [[CoreDataHandler sharedInstance] getTripWithDate:self.trip.startDate];
    NSSet *moments = self.trip.moments;
    //Filter based on day selected
    if (self.day != 0){
      NSString *fieldName = @"day";
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,self.day];
      self.sourceArray = [[moments allObjects] filteredArrayUsingPredicate:predicate];
    } else{
      self.sourceArray = [moments allObjects];
    }
    [self.collectionView reloadData];
    
    //Sort by date ASCENDING
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor]];
  }
}
//MARK:Actions
-(void)tapGesture:(UITapGestureRecognizer *)recognizer{
  switch (recognizer.state) {
    case UIGestureRecognizerStateEnded:{
      if (!self.isEditMode){
        [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        [self performSegueWithIdentifier:@"showFullScreenPhoto" sender:self];
        NSLog(@"Tap");
      } else{
        [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        [self performSegueWithIdentifier:@"showEditMoment" sender:self];
        NSLog(@"Long pressed");
      }
      break;
    }
    default:
      break;
  }
}
-(void)longPressGesture:(UILongPressGestureRecognizer *)recognizer{
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:{
//      [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
//      [self performSegueWithIdentifier:@"showEditMoment" sender:self];
//      NSLog(@"Long pressed");
      break;
    }
      
    default:
      break;
  }
}
-(void)editMoment:(UIButton *)sender{
  self.isEditMode = !self.isEditMode;
  if (!self.isEditMode){
    
//    self.editButtonItem.tintColor = [UIColor colorWithRed:0.71 green:0.816 blue:0.831 alpha:1];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.71 green:0.816 blue:0.831 alpha:1];
//    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0.71 green:0.816 blue:0.831 alpha:1]];
    
  } else{
//    self.editButtonItem.tintColor = [UIColor colorWithRed:0.333 green:0.243 blue:0.322 alpha:1];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.333 green:0.243 blue:0.322 alpha:1];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
  }
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showEditMoment"]){
    AddMomentViewController *destinationVC = segue.destinationViewController;
    destinationVC.moment = self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item];
    destinationVC.delegate = self;
  } else{
    if ([segue.identifier isEqualToString:@"showFullScreenPhoto"]){
      MomentPhotoViewController *destinationVC = segue.destinationViewController;
      destinationVC.image = [UIImage imageWithData:self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item].image ];
      destinationVC.notes = self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item].notes;
    }
  }
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