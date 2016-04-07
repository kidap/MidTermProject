//
//  WatsonVisualRecognition.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "WatsonVisualRecognition.h"
@import UIKit;

static NSString *username = @"548f780e-4694-413b-aec9-f86ed6918e4d";
static NSString *password = @"DS2cavB6d4MW";

@implementation WatsonVisualRecognition
+(instancetype)sharedInstance{
  static WatsonVisualRecognition *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

-(void)getTagUsingWatson:(UIImage*)image completionHandler:(void (^)(bool,NSSet *))completionHandler{
  NSMutableSet *returnSet = [[NSMutableSet alloc] init];
  
  //  NSString *imageFileName = @"test.jpg";
  NSString *urlString = @"https://gateway.watsonplatform.net/visual-recognition-beta/api/v2/classify?version=2015-12-02";
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
  [request setHTTPMethod:@"POST"];
  
  //username:password
  NSString *authDetails = [NSString stringWithFormat:@"%@:%@",username,password];
  //string in NSData
  NSData *plainData = [authDetails dataUsingEncoding:NSUTF8StringEncoding];
  //Convert to base64
  NSString *base64String = [plainData base64EncodedStringWithOptions:0];
  NSString * authorizationToken = base64String;
  //Add to request
  [request setValue:[NSString stringWithFormat:@"Basic %@",authorizationToken ] forHTTPHeaderField:@"Authorization"];
  
  NSLog(@"authDetails: %@",authDetails);
  NSLog(@"authorizationToken: %@",authorizationToken);
  
  // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
  NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
  
  
  // set Content-Type in HTTP header
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
  [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
  
  // post body
  NSMutableData *body = [NSMutableData data];
  
  // add image data
  UIImage *imageToPost = image;
  NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
  if (imageData) {
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"; filename=\"test.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
  
  // setting the body of the post to the reqeust
  [request setHTTPBody:body];
  
  // set the content-length
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
//    NSLog(@"Data: %@",data);
//    NSLog(@"Response: %@",response);
    if (error == nil){
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      //NSLog(@"DataJSON: %@",responseDictionary);
      
      NSArray *images = responseDictionary[@"images"];
      NSDictionary *image = [images firstObject];
      NSArray *scores = image[@"scores"];
      for (int x = 0; x < scores.count ; x++){
        NSDictionary *score = scores[x];
        NSLog(@"%@",score[@"name"]);
        NSLog(@"%@",score[@"score"]);
        [returnSet addObject:score[@"name"]];
        
        if (x==2){
          break;
        }
      }
      completionHandler(YES,returnSet);
    } else{
      NSLog(@"Error: %@",error);
    }
  }];
  
  [task resume];
  NSLog(@"Connecting to Watson...");
  
}


@end
