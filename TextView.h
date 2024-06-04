#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "StylesPanel.h"

@interface TextView : NSTextView {
  IBOutlet NSPanel* linkPanel;
  IBOutlet NSTextField* linkField;
}
- (void) orderFrontLinkPanel:(id)sender;
- (void) peformLinkPanelAction:(id)sender;

- (void) orderFrontStylesPanel:(id)sender;
- (void) performStylesPanelAction:(id)sender;
@end
