//
//  Moment+CoreDataProperties.h
//  MidTermProject
//
//  Created by Karlo Pagtakhan on 04/04/2016.
//  Copyright © 2016 AccessIT. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Moment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Moment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nonatomic) int32_t day;
@property (nullable, nonatomic, retain) Trip *trip;
@property (nullable, nonatomic, retain) NSSet<Tag *> *tags;

@end

@interface Moment (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet<Tag *> *)values;
- (void)removeTags:(NSSet<Tag *> *)values;

@end

NS_ASSUME_NONNULL_END
