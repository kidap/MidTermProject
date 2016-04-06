//
//  AddMomentViewController.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Moment;

@protocol momentDelegate <NSObject>
-(void)reloadData;
@end

@interface AddMomentViewController : UIViewController
@property (strong, nonatomic) Moment *moment;
@property (weak, nonatomic) id<momentDelegate> delegate;
@end
