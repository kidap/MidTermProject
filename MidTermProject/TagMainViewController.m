//
//  TagMainViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/05/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "TagMainViewController.h"
#import "CoreDataHandler.h"
#import "MomentMainViewController.h"
#import "Tag.h"

@interface TagMainViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic)NSArray<Tag *> *sourceArray;
@end

@implementation TagMainViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self prepareDelegates];
}
-(void)viewWillAppear:(BOOL)animated{
    [self prepareView];
}
//MARK: Preparation
- (void)prepareView {
  self.sourceArray = [[CoreDataHandler sharedInstance] getAllTags];
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"moments.@count" ascending:NO];
  NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:YES];
  self.sourceArray = [self.sourceArray sortedArrayUsingDescriptors:@[sortDescriptor,sortDescriptor2]];
  [self.tableView reloadData];
}

- (void)prepareDelegates {
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
}
//MARK: TableView delegate/datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return self.sourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
  
  NSLog(@"%@",self.sourceArray[indexPath.row]);
  cell.textLabel.text = self.sourceArray[indexPath.row].tagName;
  cell.detailTextLabel.text = [@(self.sourceArray[indexPath.row].moments.count) stringValue];
  //  cell.textLabel.text = self.sourceArray[indexPath.row][@"tagName"];
  //  Tag *tagAtIndexPath = [[CoreDataHandler sharedInstance] getTagWithName:self.sourceArray[indexPath.row][@"tagName"]];
  //  cell.detailTextLabel.text = [@(tagAtIndexPath.moments.count) stringValue];
  
  return cell;
}
//MARK: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier isEqualToString:@"showMoments"]){
    MomentMainViewController *destinationVC = segue.destinationViewController;
    //    Tag *selectedTag = self.sourceArray[self.tableView.indexPathForSelectedRow.row];
    NSString* selectedTagString = self.sourceArray[self.tableView.indexPathForSelectedRow.row].tagName;
    [[CoreDataHandler sharedInstance] reset];
    //    Tag *selectedTag = [[CoreDataHandler sharedInstance] getTagWithName:self.sourceArray[self.tableView.indexPathForSelectedRow.row][@"tagName"]];
    Tag *selectedTag = [[CoreDataHandler sharedInstance] getTagWithName:selectedTagString];
    destinationVC.moments = [[CoreDataHandler sharedInstance] getMomentsWithTag:selectedTag];
  }
}
@end
