//
//  MomentMainViewController.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Trip;
@class Moment;

@interface MomentMainViewController : UIViewController
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) NSArray<Moment*> *moments;
@property (assign, nonatomic) int day;
@end
