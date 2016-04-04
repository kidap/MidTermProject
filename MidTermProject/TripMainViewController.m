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
#import "TripDetailViewController.h"
@import CoreData;


@interface TripMainViewController()<UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Trip *> *sourceArray;
@end

@implementation TripMainViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  [self prepareView];
  [self prepareDelegate];
}
-(void)prepareView{
  self.sourceArray = [[NSArray alloc] init];
  self.sourceArray = [[CoreDataHandler sharedInstance] getAllTrips];
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  //Create test data
  
  if (self.sourceArray.count == 0){
    [[CoreDataHandler sharedInstance] createTripWithCity:@"Toronto"
                        dates:@"March 21-31"
                    startDate:[NSDate date]
                      endDate:[NSDate date]
                    totalDays:10
                        image:[UIImage imageNamed:@"Toronto"]];
    
  }
}
-(void)prepareDelegate{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  TripCollectionViewCell *tripCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tripCell" forIndexPath:indexPath];

  tripCell.imageView.image = [UIImage imageWithData:self.sourceArray[indexPath.row].coverImage];
  tripCell.cityLabel.text  = self.sourceArray[indexPath.row].city;
  if (self.sourceArray[indexPath.row].totalDays > 1){
    tripCell.daysLabel.text  = [NSString stringWithFormat:@"%@ days", [@(self.sourceArray[indexPath.row].totalDays) stringValue] ];
  } else{
    tripCell.daysLabel.text  = [NSString stringWithFormat:@"%@ day", [@(self.sourceArray[indexPath.row].totalDays) stringValue] ];
  }
  tripCell.datesLabel.text  = self.sourceArray[indexPath.row].dates;
  
  return tripCell;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showTripMoments"]){
    TripDetailViewController *destinationVC = segue.destinationViewController;
    destinationVC.trip = self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item];
  }
}
@end
