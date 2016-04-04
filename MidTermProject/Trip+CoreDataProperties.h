//
//  Trip+CoreDataProperties.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Trip.h"

NS_ASSUME_NONNULL_BEGIN

@interface Trip (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *dates;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) NSTimeInterval endDate;
@property (nonatomic) int32_t totalDays;
@property (nullable, nonatomic, retain) NSData *coverImage;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *moments;

@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addMomentsObject:(NSManagedObject *)value;
- (void)removeMomentsObject:(NSManagedObject *)value;
- (void)addMoments:(NSSet<NSManagedObject *> *)values;
- (void)removeMoments:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
