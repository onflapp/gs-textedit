#import "FileObserver.h"

@implementation FileObserver
- (id) initWithDelegate:(id) del
{
  self = [super init];
  files = [[NSMutableDictionary alloc] init];
  delegate = [del retain];
  return self;
}

- (void) dealloc
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [delegate release];
  [files release];
  [super dealloc];
}

- (void) observeFile:(NSString*) file
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDate *cd = [[fm attributesOfItemAtPath:file error:nil] fileModificationDate];
  if (cd) {
    [files setValue:cd forKey:file];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(checkFilesForModification) withObject:nil afterDelay:1.0];
  }
}

- (void) checkFilesForModification {
  NSFileManager *fm = [NSFileManager defaultManager];
  BOOL check = YES;

  if ([NSApp isActive]) check = NO;

  if (check) {
    for (NSString *file in [files allKeys]) {
      NSDate *md = [[fm attributesOfItemAtPath:file error:nil] fileModificationDate];
      NSDate *cd = [files valueForKey:file];

      if (!md) {
        [files removeObjectForKey:file];
      }
      else if ([md compare:cd] == NSOrderedDescending) {
        [files setValue:md forKey:file];
        [delegate performSelector:@selector(observedFileModifiedAtPath:) withObject:file];
      }
    }
  }

  [self performSelector:@selector(checkFilesForModification) withObject:nil afterDelay:1.0];
}

@end
