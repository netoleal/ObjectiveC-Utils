//
//  SpriteMovieClip.m
//  SpriteTest
//
//  Created by Neto Leal on 8/24/12.
//  Copyright (c) 2012 Lov. All rights reserved.
//

#import "SpriteMovieClip.h"
#import "NSDictionary+Ordered.h"

@interface SpriteMovieClip( )
{
    void (^_finishBlock)(void);
    int _startFrameOfAnimation;
    int _endFrameOfAnimation;
    
    BOOL _loop;
    BOOL _playing;
    BOOL _hasEnterFrame;
    BOOL _shouldStopAtTargetFrame;
    
    NSUInteger _factor;
    NSUInteger _targetFrame;
    
    NSTimer *_timerEnterFrame;
    NSArray *_orderedFrameKeys;
    CGSize _spriteSourceSize;
}

@property (nonatomic, strong) NSDictionary *plist;
@property (nonatomic, strong) UIImage *originalImage;
@end

@implementation SpriteMovieClip
@synthesize plist = _plist;
@synthesize originalImage = _originalImage;
@synthesize frameRate = _frameRate;
@synthesize currentFrame = _currentFrame;
@synthesize scaleForProperties = _scaleForProperties;

- (void)dealloc
{
    [_timerEnterFrame invalidate];
    _timerEnterFrame = nil;
    
    self.image = nil;
    self.originalImage = nil;
    self.plist = nil;
    _finishBlock = nil;
    _orderedFrameKeys = nil;
}

#pragma mark Public methods

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (CGFloat)scaleForProperties
{
    if( !_scaleForProperties )
    {
        return [UIScreen mainScreen].scale == 1.0? 1.0: 0.5;
    }
    
    return _scaleForProperties;
}

- (void) loadFromDictionary:(NSDictionary *)dictionary
{
    self.plist = dictionary;
    [self loadOriginalImage];
}

- (void)loadFromPlistNamed:(NSString *)plistFileName
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"];
    [self loadFromPlist:plistPath];
}

- (void) loadFromPlist:(NSString *)plistFilePath
{
    [self loadFromDictionary:[NSDictionary dictionaryWithContentsOfFile:plistFilePath]];
}

- (void) stop
{
    [self stopEnterFrame];
}

- (void) play
{
    _factor = 1;
    _targetFrame = 0;
    _shouldStopAtTargetFrame = NO;
    _finishBlock = nil;
    
    [self startEnterFrame];
}

- (void) animateToFrame:(NSUInteger)frame
{
    _targetFrame = frame;
    
    _factor = ( _targetFrame < _currentFrame )? -1: 1;
    _shouldStopAtTargetFrame = YES;
    _finishBlock = nil;
    
    [self startEnterFrame];
}

- (void) animateBetweenFrame:(NSUInteger)startFrame andFrame:(NSUInteger)endFrame
{
    [self gotoFrame:startFrame];
    [self animateToFrame:endFrame];
}

- (void)animateBetweenFrame:(NSUInteger)startFrame andFrame:(NSUInteger)endFrame andBlock:(void (^)(void))finishBlock
{
    [self gotoFrame:startFrame];
    [self animateToFrame:endFrame andBlock:finishBlock];
}

- (void)animateToBegin
{
    [self animateToFrame:1];
}

- (void)animateToBeginWithBlock:(void (^)(void))finishBlock
{
    [self animateBetweenFrame:self.currentFrame andFrame:1 andBlock:finishBlock];
}

- (void) animateToFrame:(NSUInteger)frame andBlock:(void (^)(void))finishBlock
{
    [self animateToFrame:frame];
    _finishBlock = finishBlock;
}

- (void) playAndStopAtEnd
{
    [self animateToFrame:self.totalFrames];
}

- (void)playAndStopAtEndWithBlock:(void (^)(void))finishBlock
{
    [self animateToFrame:self.totalFrames andBlock:finishBlock];
}

- (void) gotoAndStop:(NSUInteger)frame
{
    [self gotoFrame:frame];
    [self stopEnterFrame];
}

- (NSUInteger) totalFrames
{
    NSDictionary *frames = [self.plist objectForKey:@"frames"];
    return frames.count;
}

- (NSUInteger)frameRate
{
    if( !_frameRate )
    {
        return 24;
    }
    
    return _frameRate;
}

#pragma mark Private methods

- (CGSize) spriteSourceSize:(NSDictionary *)frame
{
    CGPoint temp = [self parseToPoint:[frame objectForKey:@"spriteSourceSize"]];
    _spriteSourceSize = CGSizeMake(temp.x * self.scaleForProperties, temp.y * self.scaleForProperties);
    
    return _spriteSourceSize;
}

- (void) startEnterFrame
{
    if( !_timerEnterFrame )
    {
        _timerEnterFrame = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.frameRate target:self selector:@selector(enterFrame) userInfo:nil repeats:YES];
    }
}

- (void) stopEnterFrame
{
    [_timerEnterFrame invalidate];
    _timerEnterFrame = nil;
}

- (void) enterFrame
{
    if( self.window )
    {
        _factor = _factor? _factor: 1;
        
        if( _currentFrame != _targetFrame )
        {
            if( _factor > 0 )
            {
                if( _currentFrame < self.totalFrames )
                {
                    [self gotoFrame:_currentFrame + _factor];
                }
                else
                {
                    [self gotoFrame:1];
                }
            }
            else
            {
                if( _currentFrame > 1 )
                {
                    [self gotoFrame:_currentFrame + _factor];
                }
                else
                {
                    [self gotoFrame:self.totalFrames];
                }
            }
        }
        else
        {
            if( _shouldStopAtTargetFrame )[self stop];
            if( _finishBlock )
            {
                _finishBlock( );
            }
        }
    }
    else
    {
        [self stopEnterFrame];
    }
}

- (double) getDurationBetweenFrame:(int)start andFrame:(int)end
{
    int max = MAX(start, end);
    int min = MIN(start, end);
    
    return ( max - min ) / self.frameRate;
}

- (double) getDurationUntilFrame:(int)frame
{
    return [self getDurationBetweenFrame:self.currentFrame andFrame:self.totalFrames];
}

- (void) loadOriginalImage
{
    if( !self.originalImage )
    {
        self.contentMode = UIViewContentModeTopLeft;
        
        NSString *imageFileName = [self.plist valueForKeyPath:@"metadata.target.textureFileName"];
        NSString *imageFileExts = [self.plist valueForKeyPath:@"metadata.target.textureFileExtension"];
        NSString *imageName = [imageFileName stringByAppendingString:imageFileExts];
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0/self.scaleForProperties orientation:UIImageOrientationUp];
        
        self.originalImage = image;
        [self spriteSourceSize:[[self.plist objectForKey:@"frames"] objectForKey:[[[self.plist objectForKey:@"frames"] allKeys] lastObject]]];
        
        _currentFrame = 1;
        [self gotoAndStop:1];
        
        image = nil;
    }
}

- (void) gotoFrame:(NSUInteger)frameNumber
{
    NSUInteger frameIndex = frameNumber - 1;
    _currentFrame = frameNumber;
    
    if( !_orderedFrameKeys )  _orderedFrameKeys = [[self.plist objectForKey:@"frames"] orderedKeys];
    
    NSString *key = [_orderedFrameKeys objectAtIndex:frameIndex];
    NSDictionary *frame = [[self.plist objectForKey:@"frames"] objectForKey:key];
    
    CGRect imageRect = [self parseToRect:[frame objectForKey:@"textureRect"]];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.originalImage.CGImage, imageRect);
    
    self.image = [UIImage imageWithCGImage:imageRef scale:1.0/self.scaleForProperties orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
}

- (CGPoint)parseToPoint:(NSString *)pointString
{
    NSArray *parts = [pointString componentsSeparatedByString:@","];
    NSString *x = [parts objectAtIndex:0];
    NSString *y = [parts objectAtIndex:1];
    
    x = [x substringFromIndex:1];
    y = [y substringToIndex:y.length - 1];
    
    return CGPointMake([x floatValue], [y floatValue]);
}

- (CGRect)parseToRect:(NSString *)rectString
{
    NSArray *parts = [rectString componentsSeparatedByString:@","];
    NSString *x = [parts objectAtIndex:0];
    NSString *y = [parts objectAtIndex:1];
    NSString *w = [parts objectAtIndex:2];
    NSString *h = [parts objectAtIndex:3];
    
    x = [x stringByReplacingOccurrencesOfString:@"{" withString:@""];
    y = [y stringByReplacingOccurrencesOfString:@"}" withString:@""];
    w = [w stringByReplacingOccurrencesOfString:@"{" withString:@""];
    h = [h stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    CGFloat scale = [UIScreen mainScreen].scale == 1.0? 2.0: 1.0;
    
    return CGRectMake(
                [x floatValue] / scale,
                [y floatValue] / scale,
                [w floatValue] / scale,
                [h floatValue] / scale);
}

@end
