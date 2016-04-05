//
//  Tag+CoreDataProperties.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/05/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tag.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *tagName;
@property (nullable, nonatomic, retain) NSSet<Moment *> *moments;

@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addMomentsObject:(Moment *)value;
- (void)removeMomentsObject:(Moment *)value;
- (void)addMoments:(NSSet<Moment *> *)values;
- (void)removeMoments:(NSSet<Moment *> *)values;

@end

NS_ASSUME_NONNULL_END
