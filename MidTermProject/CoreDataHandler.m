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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
  
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

//MARK: (CREATE) Data methods
-(Tag *)createTagWithName:(NSString *)tagName{
  //Check if the tag is already existing
  Tag *tag = [self getTagWithName:tagName];
  
  //If tag doesn't exist yet, create a new one
  if (tag == nil) {
    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                        inManagedObjectContext:self.managedObjectContext];
    tag.tagName = tagName;
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
                    dates:(NSString *)dates
                startDate:(NSDate*)startDate
                  endDate:(NSDate*)endDate
                totalDays:(int)days
                    image:(UIImage *)image {
  
  Trip *newTrip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip"
                                                inManagedObjectContext:self.managedObjectContext];
  
  newTrip.city = city;
  newTrip.dates = dates;
  newTrip.startDate = 1;
  newTrip.endDate = 2;
  newTrip.totalDays = 5;
  newTrip.coverImage = UIImageJPEGRepresentation(image, 1.0);
  //    newTrip.city = @"";
  
  [self saveContext];
  
}

-(void)createMomentWithImage:(UIImage*)image
                     notes:(NSString *)notes
                         day:(int*)day
                        trip:(Trip *)trip
                        tags:(NSSet<Tag *>*)tags{
  
  Moment *newMoment = [NSEntityDescription insertNewObjectForEntityForName:@"Moment"
                                                inManagedObjectContext:self.managedObjectContext];
  
  newMoment.image = UIImageJPEGRepresentation(image, 1.0) ;
  newMoment.notes = notes;
  newMoment.day = *(day);
  newMoment.tags = tags;
  newMoment.trip = trip;
  
//  [self saveContext];
  
}
//-(void)addReceiptWithAmount:(double)amount
//                       note:(NSString *)note
//                  timestamp:(NSString *)timestamp
//                       tags:(NSSet<Tag *> *)tags{
//  NSSet *tagsToBeAdded = [NSSet alloc];
//  if (tagsToBeAdded == nil){
//    tagsToBeAdded = [NSSet setWithObject:[[CoreDataHandler sharedInstance] createTagWithName:@"Test Tag" receipts:nil]];
//  } else {
//    tagsToBeAdded = [NSSet setWithSet:tags];
//  }
//  Receipt *newReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt"
//                                                      inManagedObjectContext:self.managedObjectContext];
//  newReceipt.amount = amount;
//  newReceipt.note = note;
//  newReceipt.timestamp = timestamp;
//  newReceipt.tag = tags;
//
//  [self saveContext];
//
//}
//-(NSArray *)getAllReceipts{
//  NSError *error = nil;
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Receipt"];
//
//  return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//}
//-(NSArray *)getAllTags{
//  NSError *error = nil;
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
//
//  return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//}
//-(NSArray *)getReceiptsWithTag:(Tag *)tag{
//  NSError *error = nil;
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
//
//  return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//}
//-(Tag *)createTagWithName:(NSString *)tagName{
//  //Check if the tag is already existing
//  Tag *tag = [self getTagWithName:tagName];
//
//  //If tag doesn't exist yet, create a new one
//  if (tag == nil) {
//    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
//                                        inManagedObjectContext:self.managedObjectContext];
//    tag.tagName = tagName;
//  }
//
//  [self saveContext];
//
//  return tag;
//}
//-(Tag *)createTagWithName:(NSString *)tagName
//                 receipts:(Receipt *)receipts{
//  //Check if the tag is already existing
//  Tag *tag = [self getTagWithName:tagName];
//
//  //If tag doesn't exist yet, create a new one
//  if (tag == nil) {
//    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
//                                                        inManagedObjectContext:self.managedObjectContext];
//    tag.tagName = tagName;
//    [tag.receipts setByAddingObject:receipts];
//  }
//
//  [self saveContext];
//
//  return tag;
//}
//-(Tag *)getTagWithName:(NSString *)tagName{
//  NSError *error= nil;
//  NSString *fieldName = @"tagName";
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
//
//  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",fieldName,tagName];
//  fetchRequest.predicate = predicate;
//
//  NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//
//  return [tags firstObject];
//
//}
//-(void)deleteReceipt:(Receipt *)receipt{
//  [self.managedObjectContext deleteObject:receipt];
//  [self saveContext];
//}
@end