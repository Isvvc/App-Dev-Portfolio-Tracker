//
//  IJLAppRepresentation.m
//  Portfolio
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

#import "IJLAppRepresentation.h"

@implementation IJLAppRepresentation

- (instancetype)initWithName:(NSString *)name
                    bundleID:(NSString *)bundleID
                  artworkURL:(NSURL *)artworkURL
                   ageRating:(NSString *)ageRating
                 description:(NSString *)description
                 appStoreURL:(NSURL *)appStoreURL
             userRatingCount:(int16_t)userRatingCount
                 screenshots:(NSArray<NSURL *> *)screenshots {
    self = [super init];
    if (self) {
        _name = name;
        _bundleID = bundleID;
        _artworkURL = artworkURL;
        _ageRating = ageRating;
        _appDescription = description;
        _appStoreURL = appStoreURL;
        _userRatingCount = userRatingCount;
        _screenshots = screenshots;
    }
    return self;
}

@end
