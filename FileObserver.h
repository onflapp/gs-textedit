#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface FileObserver : NSObject 
{
  NSMutableDictionary *files;
  id delegate;
}
- (id) initWithDelegate:(id) del;
- (void) observeFile:(NSString*) file;
@end
