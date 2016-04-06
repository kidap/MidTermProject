//
//  TripMainViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "TripMainViewController.h"
#import "TripCollectionViewCell.h"
#import "CoreDataHandler.h"
#import "Trip.h"
#import "Moment.h"
#import "TripDetailViewController.h"
#import "MomentMainViewController.h"
@import CoreData;


@interface TripMainViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Trip *> *sourceArray;
@property (strong, nonatomic) NSArray<Moment *> *momentsArray;
@end

@implementation TripMainViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareDelegate];
}
-(void)viewDidAppear:(BOOL)animated{
  [self prepareCollectionView];
}
//MARK: Preparation
-(void)prepareView{
  self.sourceArray = [[NSArray alloc] init];
  [self prepareCollectionView];
  
  //Create test data
  if (self.sourceArray.count == 0){
    [[CoreDataHandler sharedInstance] createTripWithCity:@"Toronto"
                                                 country:@"Canada"
                                               startDate:[NSDate date]
                                                 endDate:[NSDate date]
                                                   image:[UIImage imageNamed:@"Toronto"]];
  }
}
-(void)prepareDelegate{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}
-(void)prepareCollectionView{
  self.sourceArray = [[CoreDataHandler sharedInstance] getAllTrips];
  //Sort by date
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
  self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor]];
  [self.collectionView reloadData];
}
//MARK: Table view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  TripCollectionViewCell *tripCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tripCell" forIndexPath:indexPath];
  
  tripCell.imageView.image = [UIImage imageWithData:self.sourceArray[indexPath.row].coverImage];
  tripCell.cityLabel.text  = self.sourceArray[indexPath.row].city;
  if ([self.sourceArray[indexPath.row].totalDays intValue] > 1){
    tripCell.daysLabel.text  = [NSString stringWithFormat:@"%@ days", [self.sourceArray[indexPath.row].totalDays stringValue] ];
  } else{
    tripCell.daysLabel.text  = [NSString stringWithFormat:@"%@ day", [self.sourceArray[indexPath.row].totalDays stringValue] ];
  }
  tripCell.datesLabel.text  = self.sourceArray[indexPath.row].dates;
  
  tripCell.layer.borderWidth  = 0.5;
  tripCell.layer.borderColor  = [UIColor lightGrayColor].CGColor;
  tripCell.layer.cornerRadius  = 5.0;
  tripCell.backgroundColor = [UIColor whiteColor];
  
  return tripCell;
}
//MARK: Actions
- (IBAction)searchMoments:(id)sender {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Search" message:@"Enter a tag" preferredStyle:UIAlertControllerStyleAlert];
  //Add text field
  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //do nothing
  }];
  //Add ok button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    self.momentsArray = [[CoreDataHandler sharedInstance] getMomentsWithTagName:alertController.textFields[0].text];
    if (self.momentsArray.count > 0){
      [self performSegueWithIdentifier:@"showMoments" sender:self];
    } else{
      NSString *messageString = [NSString stringWithFormat:@"That's a cool hashtag! Unfortunately, you haven't used it yet in any of your moments."];
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No results" message:messageString preferredStyle:UIAlertControllerStyleAlert];
      
      //Add ok button
      [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
      }]];
      [self presentViewController:alertController animated:YES completion:nil];
    }
  }]];
  //Add cancel button
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //do nothing
  }]];
  
  [self presentViewController:alertController animated:YES completion:nil];
}

//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showTripMoments"]){
    TripDetailViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item];
    NSLog(@"Start Date: %@",destinationVC.trip.startDate);
    NSLog(@"End Date: %@",destinationVC.trip.endDate);
  }  else if ([segue.identifier isEqualToString:@"showMoments"]){
    MomentMainViewController *destinationVC = segue.destinationViewController;
    destinationVC.moments = [self.momentsArray copy];
    self.momentsArray = nil;
  }
}
@end
