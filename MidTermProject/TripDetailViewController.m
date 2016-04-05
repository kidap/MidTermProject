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

@interface TripDetailViewController()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *dayTableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) IBOutlet UICollectionView *dayCollectionView;
@end
@implementation TripDetailViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareTableView];
}
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit Trip" style:UIBarButtonItemStylePlain target:self action:@selector(editTrip)];
  self.navigationItem.rightBarButtonItem = edit;
  
}
-(void)prepareTableView{
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
//MARK: Table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return self.sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dayCell" forIndexPath:indexPath];
  
  cell.textLabel.text = self.sourceArray[indexPath.row];
  
  return cell;
}
//MARK: Collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  DayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dayCell" forIndexPath:indexPath];
  
   cell.dayLabel.text= self.sourceArray[indexPath.row];
  
  
  //Filter based on day selected
  int currentDay = (int)indexPath.row;
  NSSet <Moment *>*moments = self.trip.moments;
  if (currentDay != 0){
    NSString *fieldName = @"day";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %i",fieldName,currentDay];
    Moment *moment = [[[moments allObjects] filteredArrayUsingPredicate:predicate] lastObject];
    cell.imageView.image = [UIImage imageWithData:moment.image];
  } else{
//    Moment *moment = [[[moments allObjects] filteredArrayUsingPredicate:predicate] lastObject];
    cell.imageView.image = [UIImage imageWithData: [moments anyObject].image];
  }
  
  return cell;
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
    destinationVC.day = (int)self.dayTableView.indexPathForSelectedRow.row;
    NSLog(@"Day selected:%ld",self.dayTableView.indexPathForSelectedRow.row);
  } else if ([segue.identifier isEqualToString:@"showEditTrip"]){
    AddTripViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.trip;
  }
}
@end