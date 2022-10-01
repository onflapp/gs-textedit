#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface TextView : NSTextView {
  IBOutlet NSPanel* linkPanel;
  IBOutlet NSTextField* linkField;
}
- (void) orderFrontLinkPanel:(id)sender;
- (void) peformLinkPanelAction:(id)sender;
@end
