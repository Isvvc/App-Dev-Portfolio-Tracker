//
//  IJLAppRepresentation.h
//  Portfolio
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

NS_SWIFT_NAME(AppRepresentation)

@interface IJLAppRepresentation : NSObject

@property (nonatomic, readonly, nonnull) NSString *name;
@property (nonatomic, readonly, nonnull) NSString *bundleID;
@property (nonatomic, readonly, nullable) NSURL *artworkURL;
@property (nonatomic, readonly, nullable) NSString *ageRating;
@property (nonatomic, readonly, nonnull) NSString *appDescription;
@property (nonatomic, readonly, nullable) NSURL *appStoreURL;
@property (nonatomic, readonly) int16_t userRatingCount;
@property (nonatomic, readonly, nullable) NSArray<NSURL *> *screenshots;

@property (nonatomic, readwrite, nullable) UIImage *artwork;

- (instancetype _Nonnull )initWithName:(NSString *_Nonnull)name
                              bundleID:(NSString *_Nonnull)bundleID
                            artworkURL:(NSURL *_Nullable)artworkURL
                             ageRating:(NSString *_Nullable)ageRating
                           description:(NSString *_Nonnull)description
                           appStoreURL:(NSURL *_Nullable)appStoreURL
                       userRatingCount:(int16_t)userRatingCount
                           screenshots:(NSArray<NSURL *> *_Nullable)screenshots;

@end
