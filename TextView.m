#import "TextView.h"

@implementation TextView

- (void) orderFrontLinkPanel:(id)sender
{
  if (!linkPanel) {
    if (![NSBundle loadNibNamed:@"LinkPanel" owner:self]) {
      NSLog (@"Failed to load LinkPanel");
    }
  }
  NSRange r = {0, 0};

  NSRange s = [self selectedRange];
  NSDictionary* dict = [[self textStorage]attributesAtIndex:s.location effectiveRange:&r];
  NSURL* url = [dict objectForKey:NSLinkAttributeName];

  if (url) {
    if (s.length == 0 && r.length > 0) {
      [self setSelectedRange:r];
    }
    [linkField setStringValue:[url description]];
  }

  [linkPanel makeKeyAndOrderFront:sender];
}

- (void) peformLinkPanelAction:(id)sender
{
  NSRange selectionRange = [self selectedRange];
  if ([sender tag] == 1) {
    NSURL* url = [NSURL URLWithString:[linkField stringValue]];
    if (url) {
      NSMutableDictionary* dict = [NSMutableDictionary new];
      [dict setObject:url forKey:NSLinkAttributeName];

      [[self textStorage] setAttributes:dict range:selectionRange];
      [dict release];
    }
  }
  else {
    NSDictionary* dict = [NSDictionary new];
    [[self textStorage] setAttributes:dict range:selectionRange];
    [dict release];
  }

  [linkPanel orderOut:self];
}

- (void) orderFrontStylesPanel:(id)sender
{
  [[StylesPanel sharedInstance] orderFrontStylesPanel: sender];
}

- (void) performStylesPanelAction:(id)sender
{
  NSRange s = [self selectedRange];
  NSRange r = {0, 0};
  if ([sender tag] == 10 && s.length > 0) { /* set style from the selection */
    NSDictionary* dict = [[self textStorage]attributesAtIndex:s.location effectiveRange:&r];
    [[StylesPanel sharedInstance] setSelectedStyle: dict];
  }
  else if ([sender tag] == 30) { /* clear styles */
    NSDictionary* dict = [NSDictionary dictionary];
    if (dict && s.length > 0) {
      [[self textStorage] setAttributes:dict range:s];
    }
    else if (dict) {
      [self setTypingAttributes:dict];
    }
  }
  else { /* apply styles */
    NSDictionary* dict = [[StylesPanel sharedInstance] selectedStyle];
    if (dict && s.length > 0) {
      [[self textStorage] setAttributes:dict range:s];
    }
    else if (dict) {
      [self setTypingAttributes:dict];
    }
  }
}

- (void) changeFontSize:(id)sender
{
  NSRange s = [self selectedRange];
  NSRange r = {0, 0};

  if (s.length == 0) return;

  NSDictionary* dict = [[self textStorage]attributesAtIndex:s.location effectiveRange:&r];
  NSFont* font = [dict valueForKey:@"NSFont"];
 
  if (([sender tag] < 0 && [font pointSize] > 5) || [sender tag] > 0) {
    font = [[NSFontManager sharedFontManager] convertFont:font 
                                                   toSize:[font pointSize] + [sender tag]];

    dict = [dict mutableCopy];
    [dict setValue:font forKey:@"NSFont"];
    [[self textStorage] setAttributes:dict range:s];
  }
}

@end
