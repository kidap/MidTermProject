//
//  TripDetailViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "TripDetailViewController.h"
#import "Trip.h"
#import "MomentMainViewController.h"
#import "AddTripViewController.h"

@interface TripDetailViewController()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *dayTableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@end
@implementation TripDetailViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareTableView];
}
-(void)prepareView{
  self.sourceArray = [[NSMutableArray alloc] init];
  
//  UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTrip)];
  UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit Trip" style:UIBarButtonSystemItemEdit target:self action:@selector(editTrip)];
  self.navigationController.navigationItem.leftBarButtonItem = edit;
}
-(void)prepareTableView{
  self.dayTableView.delegate = self;
  self.dayTableView.dataSource = self;
  
  for (int x = 1 ; x <= self.trip.totalDays; x++){
    [self.sourceArray addObject:[NSString stringWithFormat:@"Day %i",x]];
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
//MARK: Action
-(void)editTrip{
  [self performSegueWithIdentifier:@"showEditTrip" sender:self];
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showMoments"]){
    MomentMainViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.trip;
    destinationVC.day = (int)[self.dayTableView indexPathForSelectedRow].row;
  } else if ([segue.identifier isEqualToString:@"showEditTrip"]){
    AddTripViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.trip;
  }
}
@end