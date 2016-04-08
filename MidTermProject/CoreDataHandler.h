//
//  CoreDateHandler.h
//  W4D4Receipts
//
//  Created by Karlo Pagtakhan on 03/31/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSManagedObject;
@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSFetchedResultsController;
@class NSManagedObjectID;
@class Moment;
@class Tag;
@class UIImage;
@class Trip;

@interface CoreDataHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)sharedInstance;

//Get
-(NSArray *)getAllTrips;
-(NSArray *)getAllTripsInDict;
-(NSArray *)getAllTags;
-(Tag *)getTagWithName:(NSString *)tagName;
-(NSArray *)getMomentsWithTagName:(NSString *)tagName;
-(NSArray *)getMomentsWithTag:(Tag *)tag;
-(Trip *)getTripWithDate:(NSDate *)date;
-(Trip *)getTripNearDate:(NSDate *)date
               inCountry:(NSString *)country
                    City:(NSString *)city;
-(NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID
                                   error:(NSError **)error;
//Create
-(void)createTripWithCity:(NSString*)city
                  country:(NSString*)country
//dates:(NSString *)dates
                startDate:(NSDate*)startDate
                  endDate:(NSDate*)endDate
                    image:(UIImage *)image;
-(void)createMomentWithImage:(UIImage*)image
                       notes:(NSString *)notes
           datePhotoWasTaken:(NSDate *)date
                        trip:(Trip *)trip
                        tags:(NSSet<Tag *>*)tags;
-(Tag *)createTagWithName:(NSString *)tagName;
//Update
-(void)updateTrip:(Trip *)trip
             city:(NSString*)city
          country:(NSString*)country
//dates:(NSString *)dates
        startDate:(NSDate*)startDate
          endDate:(NSDate*)endDate
            image:(UIImage *)image;
-(void)updateMoment:(Moment *)moment
              image:(UIImage*)image
              notes:(NSString *)notes
  datePhotoWasTaken:(NSDate *)datePhotoTaken
               trip:(Trip *)trip
               tags:(NSSet<Tag *>*)tags;
//Delete
-(void)deleteTrip:(Trip *)trip;
-(void)deleteMoment:(Moment *)moment;
//Refresh
-(void)refreshObject:(NSManagedObject *)object;
-(void)logRegisteredObjects;
-(void)reset;
@end
