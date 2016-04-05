//
//  CoreDateHandler.h
//  W4D4Receipts
//
//  Created by Karlo Pagtakhan on 03/31/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSFetchedResultsController;
@class Moment;
@class Tag;
@class UIImage;
@class Trip;

@interface CoreDataHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)sharedInstance;

-(NSArray *)getAllTrips;
-(NSArray *)getAllTags;
-(void)createTripWithCity:(NSString*)city
                    dates:(NSString *)dates
                startDate:(NSDate*)startDate
                  endDate:(NSDate*)endDate
                totalDays:(int)days
                    image:(UIImage *)image;
-(void)createMomentWithImage:(UIImage*)image
                       notes:(NSString *)notes
                         day:(int)day
                        trip:(Trip *)trip
                        tags:(NSSet<Tag *>*)tags;
-(Tag *)createTagWithName:(NSString *)tagName;
@end
