//
//  CoreDateHandler.m
//  W4D4Receipts
//
//  Created by Karlo Pagtakhan on 03/31/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//

#import "CoreDataHandler.h"
#import "CoreData/CoreData.h"
#import "UIKit/UIKit.h"
#import "Moment.h"
#import "Tag.h"
#import "Trip.h"

static NSString *dateFormat = @"MM/dd/yyyy";

@implementation CoreDataHandler
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+(instancetype)sharedInstance{
  static CoreDataHandler *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}
-(NSURL *)applicationDocumentsDirectory{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSManagedObjectContext *)managedObjectContext{
  if (_managedObjectContext != nil){
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}
-(NSManagedObjectModel *)managedObjectModel{
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MidTerm" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjectModel;
}
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator{
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSError *error = nil;
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MidTerm.sqlite"];
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    NSLog(@"Error: %@ %@.", error, [error userInfo]);
    abort();
  }
  NSLog(@"%@",storeURL);
  
  return _persistentStoreCoordinator;
}
-(void)dealloc{
}

- (void)saveContext {
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}
//MARK: (GET) Data methods
-(NSArray *)getAllTrips{
  NSError *error = nil;
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
  
  return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
}
-(NSArray *)getAllTags{
  NSError *error = nil;
  
  //Delete empty tags
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"moments.@count == 0"];
  fetchRequest.predicate = predicate;
  
  NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  for (Tag *tag in tags){
  [self.managedObjectContext deleteObject:tag];
  }

  //Get all tags with moments
  fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
  
  return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}
-(Tag *)getTagWithName:(NSString *)tagName{
  NSError *error= nil;
  NSString *fieldName = @"tagName";
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",fieldName,tagName];
  fetchRequest.predicate = predicate;
  
  NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  return [tags firstObject];
  
}
-(Trip *)getTripWithDate:(NSDate *)date{
  if (date){
    NSError *error= nil;
    NSString *fieldName1 = @"startDate";
    NSString *fieldName2 = @"endDate";
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K <= %@) AND (%K >= %@)",fieldName1,date,fieldName2,date];
    fetchRequest.predicate = predicate;
    
    NSLog(@"Looking for a trip on %@",date);
    NSArray *trips = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [trips firstObject];
  }
  return nil;
}
-(NSArray *)getMomentsWithTagName:(NSString *)tagName{
  NSError *error= nil;
  NSString *fieldName = @"tagName";
  //Get all tags
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",fieldName,tagName];
  fetchRequest.predicate = predicate;
  
  //Get all memories using the tags
  NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  NSMutableArray *moments = [[NSMutableArray alloc] init];
  for (Tag *tag in tags){
    [moments addObjectsFromArray:[tag.moments allObjects]];
  }
  
  return moments;
}
-(NSArray *)getMomentsWithTag:(Tag *)tag{
  return [tag.moments allObjects];
}
-(Trip *)getTripNearDate:(NSDate *)date
               inCountry:(NSString *)country
                    City:(NSString *)city{

  //Create a predicate which will give me trip closest
  
  
  return nil;
}
//MARK: (CREATE) Data methods
-(Tag *)createTagWithName:(NSString *)tagName{
  //Check if the tag is already existing
  Tag *tag = [self getTagWithName:[[tagName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]];
  
  //If tag doesn't exist yet, create a new one
  if (tag == nil) {
    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                        inManagedObjectContext:self.managedObjectContext];
    tag.tagName = [[tagName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
  }
  
  [self saveContext];
  
  return tag;
}
-(Tag *)createTagWithName:(NSString *)tagName
                  moments:(Moment *)moments{
  //Check if the tag is already existing
  Tag *tag = [self getTagWithName:tagName];
  
  //If tag doesn't exist yet, create a new one
  if (tag == nil) {
    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                        inManagedObjectContext:self.managedObjectContext];
    tag.tagName = tagName;
    [tag.moments setByAddingObject:moments];
  }
  
  [self saveContext];
  
  return tag;
}

-(void)createTripWithCity:(NSString*)city
                  country:(NSString*)country
//dates:(NSString *)dates
                startDate:(NSDate*)startDate
                  endDate:(NSDate*)endDate
                    image:(UIImage *)image {
  
  Trip *newTrip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip"
                                                inManagedObjectContext:self.managedObjectContext];
  
  newTrip.city = city;
  newTrip.country = country;
  //Format date text
  NSString *startDateString = [self convertDateToString:startDate];
  NSString *endDateString = [self convertDateToString:endDate];
  NSString *dateText = [startDateString stringByAppendingString:@"-"];
  dateText = [dateText stringByAppendingString:endDateString];
  newTrip.dates = dateText;
  
  //Reset time on Start Date
  //unsigned int flags = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
  NSCalendar* calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:startDate];
    components.hour = 00;
    components.minute = 00;
    components.second = 00;
  //  newTrip.startDate = [[NSCalendar currentCalendar]dateFromComponents:components ];
  newTrip.startDate = [startDate dateByAddingTimeInterval:-components.hour*components.minute*components.minute];
  
  
  //Reset time on End Date
  components = [calendar components:NSUIntegerMax fromDate:endDate];
  components.hour = 23;
  components.minute = 59;
  components.second = 59;
  components.nanosecond = 59;
  newTrip.endDate = [[NSCalendar currentCalendar]dateFromComponents:components ];
  
  components = [calendar components:NSUIntegerMax fromDate:newTrip.endDate];
  
  NSLog(@"Start Date:%@",[self convertDateToString:newTrip.startDate]);
  NSLog(@"End Date:%@",[self convertDateToString:newTrip.endDate]);
  
  //Get total days of trip
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  components = [gregorianCalendar components:NSCalendarUnitDay
                                    fromDate:startDate
                                      toDate:endDate
                                     options:NSCalendarWrapComponents];
  int daysOfTrip = (int)[components day] + 1;
  
  newTrip.totalDays = [NSNumber numberWithInteger:daysOfTrip];
  newTrip.coverImage = UIImageJPEGRepresentation(image, 1.0);
  
  [self saveContext];
  
}

-(void)createMomentWithImage:(UIImage*)image
                       notes:(NSString *)notes
           datePhotoWasTaken:(NSDate *)datePhotoTaken
                        trip:(Trip *)trip
                        tags:(NSSet<Tag *>*)tags{
  
  Moment *newMoment = [NSEntityDescription insertNewObjectForEntityForName:@"Moment"
                                                    inManagedObjectContext:self.managedObjectContext];
  
  newMoment.image = UIImageJPEGRepresentation(image, 1.0) ;
  newMoment.notes = notes;
  newMoment.date = datePhotoTaken;
  
  //Get total days of trip
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                      fromDate:trip.startDate
                                                        toDate:datePhotoTaken
                                                       options:NSCalendarWrapComponents];
  int day = (int)[components day] + 1;
  NSLog(@"Save in day: %@",[@(day) stringValue]);
  
  newMoment.day = [NSNumber numberWithInteger:day];
  newMoment.tags = tags;
  newMoment.trip = trip;
  
  [self saveContext];
  
}

//MARK: (UPDATE) Data methods
-(void)updateTrip:(Trip *)trip
             city:(NSString*)city
          country:(NSString*)country
//dates:(NSString *)dates
        startDate:(NSDate*)startDate
          endDate:(NSDate*)endDate
            image:(UIImage *)image {
  
  trip.city = city;
  trip.country = country;
  
  NSString *startDateString = [self convertDateToString:startDate];
  NSString *endDateString = [self convertDateToString:endDate];
  
  NSString *dateText = [startDateString stringByAppendingString:@"-"];
  dateText = [dateText stringByAppendingString:endDateString];
  
  trip.dates = dateText;
  trip.startDate = startDate;
  trip.endDate = endDate;
  
  //Get total days of trip
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                      fromDate:startDate
                                                        toDate:endDate
                                                       options:NSCalendarWrapComponents];
  int daysOfTrip = (int)[components day] + 1;
  
  trip.totalDays = [NSNumber numberWithInt:daysOfTrip];
  trip.coverImage = UIImageJPEGRepresentation(image, 1.0);
  
  //Rebuild moments
  //change the day properties
  
  //all days no longer in the range will be deleted
  
  [self saveContext];
  
}
-(void)updateMoment:(Moment *)moment
              image:(UIImage*)image
              notes:(NSString *)notes
  datePhotoWasTaken:(NSDate *)datePhotoTaken
               trip:(Trip *)trip
               tags:(NSSet<Tag *>*)tags{
  
  
  moment.image = UIImageJPEGRepresentation(image, 1.0) ;
  moment.notes = notes;
  moment.date = datePhotoTaken;
  
  //Get total days of trip
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                      fromDate:trip.startDate
                                                        toDate:datePhotoTaken
                                                       options:NSCalendarWrapComponents];
  int day = (int)[components day] + 1;
  NSLog(@"Save in day: %@",[@(day) stringValue]);
  
  moment.day = [NSNumber numberWithInteger:day];
  moment.tags = tags;
  moment.trip = trip;
  
  [self saveContext];
  
}

//MARK: (DELETE) Data methods
-(void)deleteTrip:(Trip *)trip{
  [self.managedObjectContext deleteObject:trip];
  [self saveContext];
}
-(NSString *)convertDateToString:(NSDate *)date{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  return [f stringFromDate:date];
}
-(NSDate *)convertStringToDate:(NSString *)dateString{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:dateFormat];
  return [f dateFromString:dateString];
}
@end