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

@interface MomentMainViewController()<UICollectionViewDelegate, UICollectionViewDataSource,momentDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Moment *> *sourceArray;
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
  
  //if selected using a trip, get moments related to trip
  //else, tag was used to get all moments
  if (self.trip){
    NSSet *moments = self.trip.moments;
    
    //Filter based on day selected
    if (self.day != 0){
      NSString *fieldName = @"day";
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,self.day];
      self.sourceArray = [[moments allObjects] filteredArrayUsingPredicate:predicate];
    } else{
      self.sourceArray = [moments allObjects];
    }
  } else {
    self.sourceArray = self.moments;
  }
  
  //Sort by date ASCENDING
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
  self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor]];
  
  //Set title of the navigation bar
  if (self.day != 0){
    self.navigationItem.title = [NSString stringWithFormat:@"Day %d",self.day];
  } else{
    self.navigationItem.title = @"All";
  }
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
  momentCell.layer.shadowColor = [UIColor colorWithRed:0.325 green:0.518 blue:0.635 alpha:1].CGColor;//[UIColor grayColor].CGColor;
  momentCell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  momentCell.layer.shadowOpacity = 0.5f;
  momentCell.layer.masksToBounds = NO;
  momentCell.backgroundColor = [UIColor whiteColor];
  
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
  }
}
//MARK:Actions
-(void)tapGesture:(UITapGestureRecognizer *)recognizer{
  switch (recognizer.state) {
    case UIGestureRecognizerStateEnded:{
      [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
      [self performSegueWithIdentifier:@"showFullScreenPhoto" sender:self];
      NSLog(@"Tap");
      break;
    }
    default:
      break;
  }
}
-(void)longPressGesture:(UILongPressGestureRecognizer *)recognizer{
  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:{
      [self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]] animated:YES scrollPosition:UICollectionViewScrollPositionTop];
      [self performSegueWithIdentifier:@"showEditMoment" sender:self];
      NSLog(@"Long pressed");
      break;
    }
      
    default:
      break;
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
    }
  }
}
@end