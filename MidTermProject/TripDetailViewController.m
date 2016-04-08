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
#import "CoreDataHandler.h"


static NSString *dateFormat = @"MM/dd/yyyy HH:mm:ss";

@interface TripDetailViewController()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *dayTableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (weak, nonatomic) IBOutlet UICollectionView *dayCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) NSSet <Moment *>*moments;
@end
@implementation TripDetailViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareCollectionView];
}
-(void)viewDidAppear:(BOOL)animated{
  [[CoreDataHandler sharedInstance] refreshObject:self.trip];
}
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit Trip" style:UIBarButtonItemStylePlain target:self action:@selector(editTrip)];
  self.navigationItem.rightBarButtonItem = edit;
  self.navigationItem.title = [NSString stringWithFormat:@"%@, %@",self.trip.city,self.trip.country];
  
  //from Core Data Handler
  self.moments = self.trip.moments;
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
  
  NSLog(@"Trip Detail view did load");
  [[CoreDataHandler sharedInstance] logRegisteredObjects];
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
  if (currentDay != 0){
//    NSString *fieldName = @"day";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,currentDay];
//    Moment *moment = [[[self.moments allObjects] filteredArrayUsingPredicate:predicate] lastObject];
    //day 1 = start date + 1
    //day 2 = start date + 1
    NSString *fieldName = @"date";
    int day = currentDay - 1;
    NSDate *newDateStartOfDay = [self.trip.startDate dateByAddingTimeInterval:60*60*24*day];
    NSDate *newDateEndOfDay = [self.trip.startDate dateByAddingTimeInterval:(60*60*24*(day+1))-1];
   NSLog(@"Start:%@,New:%@,New:%@",[self convertDateToString: self.trip.startDate],
         [self convertDateToString:newDateStartOfDay],[self convertDateToString:newDateEndOfDay]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)",fieldName,newDateStartOfDay,fieldName,newDateEndOfDay];
                              
    Moment *moment = [[[self.moments allObjects] filteredArrayUsingPredicate:predicate] lastObject];
    NSLog(@"Day %D:%@",currentDay,moment.date);
    NSLog(@"Moment date%@",[self convertDateToString: moment.date]);
    cell.imageView.image = [UIImage imageWithData:moment.image];
    [[CoreDataHandler sharedInstance] refreshObject:moment];
  } else{
    cell.imageView.image = [UIImage imageWithData: [self.moments anyObject].image];
  }
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