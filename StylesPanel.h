#import <AppKit/AppKit.h>

@interface StylesPanel : NSObject {
  IBOutlet NSPanel* panel;
  IBOutlet NSTableView* stylesList;

  NSMutableArray* styles;
  NSMenu* stylesMenu;
}

+ (id) sharedInstance;
- (void) orderFrontStylesPanel:(id)sender;
- (void) setStylesMenu:(NSMenu*) menu;
- (void) setSelectedStyle:(NSDictionary*) style;
- (NSDictionary*) selectedStyle;
@end
