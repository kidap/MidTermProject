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
#import "Moment.h"

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
  NSSet *moments = self.trip.moments;
  self.sourceArray = [moments allObjects];
  
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
  MomentCollectionViewCell *momentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tripCell" forIndexPath:indexPath];
  
  return momentCell;
}
@end
