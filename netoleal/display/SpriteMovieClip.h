//
//  SpriteMovieClip.h
//  SpriteTest
//
//  Created by Neto Leal on 8/24/12.
//  Copyright (c) 2012 Lov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpriteMovieClip : UIImageView

- (void) loadFromPlist:(NSString *)plistFilePath;
- (void) loadFromPlistNamed:(NSString *)plistFileName;
- (void) loadFromDictionary:(NSDictionary *)dictionary;

- (void) gotoAndStop:(NSUInteger)frame;
- (void) play;
- (void) stop;
- (void) playAndStopAtEnd;
- (void) playAndStopAtEndWithBlock:(void (^)(void))finishBlock;
- (void) animateToFrame:(NSUInteger)frame;
- (void) animateToFrame:(NSUInteger)frame andBlock:(void (^)(void))finishBlock;

- (void) animateBetweenFrame:(NSUInteger)startFrame andFrame:(NSUInteger)endFrame;
- (void) animateBetweenFrame:(NSUInteger)startFrame andFrame:(NSUInteger)endFrame andBlock:(void (^)(void))finishBlock;

- (void) animateToBegin;
- (void) animateToBeginWithBlock:(void (^)(void))finishBlock;

@property (nonatomic) NSUInteger frameRate;
@property (nonatomic, readonly) NSUInteger totalFrames;
@property (nonatomic, readonly) NSUInteger currentFrame;
@property (nonatomic) CGFloat scaleForProperties;
@end
