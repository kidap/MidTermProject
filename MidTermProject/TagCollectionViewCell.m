//
//  CustomCollectionViewCell.m
//  DynamicCollectionViewCell
//
//  Created by Karlo Pagtakhan on 04/06/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "TagCollectionViewCell.h"

@implementation TagCollectionViewCell
-(void)setSelected:(BOOL)selected{
  [super setSelected:selected];
  
  if(self.selected){
    self.contentView.backgroundColor=[UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
    self.tagLabel.textColor = [UIColor whiteColor];
  }else{
    self.contentView.backgroundColor=[UIColor whiteColor];
    self.tagLabel.textColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
  }
}

@end
