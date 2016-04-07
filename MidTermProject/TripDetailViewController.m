//
//  TripDetailViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "TripDetailViewController.h"
#import "Trip.h"
#import "Moment.h"
#import "MomentMainViewController.h"
#import "AddTripViewController.h"
#import "DayCollectionViewCell.h"

@interface TripDetailViewController()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *dayTableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) IBOutlet UICollectionView *dayCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@end
@implementation TripDetailViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareCollectionView];
}
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit Trip" style:UIBarButtonItemStylePlain target:self action:@selector(editTrip)];
  self.navigationItem.rightBarButtonItem = edit;
}
-(void)prepareCollectionView{
  self.dayTableView.delegate = self;
  self.dayTableView.dataSource = self;
  self.dayCollectionView.delegate = self;
  self.dayCollectionView.dataSource = self;
  
  for (int x = 0 ; x <= [self.trip.totalDays intValue]; x++){
    if (x != 0){
      [self.sourceArray addObject:[NSString stringWithFormat:@"Day %i",x]];
    } else{
      [self.sourceArray addObject:[NSString stringWithFormat:@"All"]];
    }
  }
}

//MARK: Collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  DayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dayCell" forIndexPath:indexPath];
  
  //Day text
  cell.dayLabel.text= self.sourceArray[indexPath.row];
  
  //Image - Filter based on day selected
  int currentDay = (int)indexPath.row;
  NSSet <Moment *>*moments = self.trip.moments;
  if (currentDay != 0){
    NSString *fieldName = @"day";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,currentDay];
    Moment *moment = [[[moments allObjects] filteredArrayUsingPredicate:predicate] lastObject];
    cell.imageView.image = [UIImage imageWithData:moment.image];
  } else{
    cell.imageView.image = [UIImage imageWithData: [moments anyObject].image];
  }
  
  //Image properties
  cell.imageView.layer.borderWidth  = 0.5;
  cell.imageView.layer.borderColor  = [UIColor colorWithRed:0.333 green:0.243 blue:0.322 alpha:1].CGColor;//[UIColor lightGrayColor].CGColor;
  cell.imageView.layer.cornerRadius  = 5.0;
  cell.imageView.backgroundColor = [UIColor whiteColor];
  
  return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  DayCollectionViewCell *cell = (DayCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
  
  //Show moments only if there is an image
  if (cell.imageView.image){
    [self performSegueWithIdentifier:@"showMoments" sender:self];
  }
  
}

//MARK: Action
-(void)editTrip{
  [self performSegueWithIdentifier:@"showEditTrip" sender:self];
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showMoments"]){
    MomentMainViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.trip;
    //    destinationVC.day = (int)self.dayTableView.indexPathForSelectedRow.row;
    //    NSLog(@"Day selected:%ld",self.dayTableView.indexPathForSelectedRow.row);
    destinationVC.day = (int)[self.dayCollectionView.indexPathsForSelectedItems firstObject].item;
    NSLog(@"Day selected:%ld",[self.dayCollectionView.indexPathsForSelectedItems firstObject].item);
  } else if ([segue.identifier isEqualToString:@"showEditTrip"]){
    AddTripViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.trip;
  }
}
@end