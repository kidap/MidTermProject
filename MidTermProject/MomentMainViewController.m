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

@interface MomentMainViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Moment *> *sourceArray;
@end
@implementation MomentMainViewController
-(void)viewDidLoad{
  [super viewDidLoad];
  
  [self prepareView];
  [self prepareDelegate];
}
-(void)prepareView{
  self.sourceArray = [[NSArray alloc] init];
  
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
  
  //Sort by date
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
  self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor]];
  
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.navigationController.navigationItem.title = [NSString stringWithFormat:@"Day %d",self.day];
}
-(void)prepareDelegate{
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  MomentCollectionViewCell *momentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"momentCell" forIndexPath:indexPath];
  momentCell.imageView.image = [UIImage imageWithData:self.sourceArray[indexPath.row].image];
  if (![self.sourceArray[indexPath.row].notes isEqualToString:@"<add notes>"]){
    momentCell.notes.text = self.sourceArray[indexPath.row].notes;
  }
  return momentCell;
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showEditMoment"]){
    AddMomentViewController *destinationVC = segue.destinationViewController;
    destinationVC.moment = self.sourceArray[[self.collectionView.indexPathsForSelectedItems firstObject].item];
  }
}
@end