#import <AppKit/AppKit.h>

@interface StylesPanel : NSObject {
  IBOutlet NSPanel* panel;
  IBOutlet NSTableView* stylesList;

  NSMutableArray* styles;
}

+ (id) sharedInstance;
- (void) orderFrontStylesPanel:(id)sender;
- (void) setSelectedStyle:(NSDictionary*) style;
- (NSDictionary*) selectedStyle;
@end
