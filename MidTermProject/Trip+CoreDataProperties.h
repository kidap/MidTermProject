//
//  Trip+CoreDataProperties.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/05/2016.
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
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSNumber *totalDays;
@property (nullable, nonatomic, retain) NSData *coverImage;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSSet<Moment *> *moments;

@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addMomentsObject:(Moment *)value;
- (void)removeMomentsObject:(Moment *)value;
- (void)addMoments:(NSSet<Moment *> *)values;
- (void)removeMoments:(NSSet<Moment *> *)values;

@end

NS_ASSUME_NONNULL_END
