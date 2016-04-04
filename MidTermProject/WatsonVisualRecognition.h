//
//  WatsonVisualRecognition.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface WatsonVisualRecognition : NSObject
+(instancetype)sharedInstance;
-(void)getTagUsingWatson:(UIImage*)image completionHandler:(void (^)(bool,NSSet *))completionHandler;
@end
