//
//  MomentPhotoViewController.m
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/06/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "MomentPhotoViewController.h"

@interface MomentPhotoViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation MomentPhotoViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setupScrollView];
}
-(void)viewDidAppear:(BOOL)animated{
  [self addElementsToScrollView];
}
//MARK: Prepare ScrollView
-(void)setupScrollView{
  self.scrollView.delegate = self;
  self.scrollView.minimumZoomScale = 1.0;
  self.scrollView.maximumZoomScale = 10;
  [self.scrollView setZoomScale:1.0];
}
-(void)addElementsToScrollView{
  if (!self.image) {
    NSLog(@"No image");
  }
  
  self.imageView = [[UIImageView alloc] initWithImage:self.image];
  [self.scrollView addSubview:self.imageView];
  self.imageView.frame = self.scrollView.bounds;
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.backgroundColor = [UIColor blackColor];
}

//MARK: Scroll View delegates
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
  return self.imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
  [self centerScrollViewContents];
}
-(void)centerScrollViewContents{
  //Center only if the image doesn't cover entire scrollView
  if (CGRectGetMinY(self.scrollView.bounds) <= CGRectGetHeight(self.scrollView.bounds) ||
      CGRectGetMinX(self.scrollView.bounds) <= CGRectGetWidth(self.scrollView.bounds)){

    //Center image using ContentOffset
    [self.scrollView setContentOffset:(CGPointMake(CGRectGetMinX(self.scrollView.bounds),
                                                   ((self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds)) / 2)-40)) animated:YES];
  }
}

@end
