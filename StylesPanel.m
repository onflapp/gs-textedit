#import <AppKit/AppKit.h>
#import "StylesPanel.h"
#import "Preferences.h"

NSData* dataForAttributes(NSDictionary* dict) {
  NSAttributedString* str = [[NSAttributedString alloc] initWithString:@"x" attributes:dict];
  return [str RTFFromRange:NSMakeRange(0, 1) documentAttributes:nil];
}

NSDictionary* attributesForData(NSData* data) {
  NSAttributedString* str = [[NSAttributedString alloc] initWithRTF:data documentAttributes:nil];
  NSRange r = {0, 0};
  return [str attributesAtIndex:0 effectiveRange:&r];
}

#define STYLE_ITEM_TAG 52431

@implementation StylesPanel

- (id )init {
  if (!(self = [super init]))
    return nil;
  
  styles = [[NSMutableArray alloc] init];

  return self;
}

- (void) awakeFromNib {
  [panel setBecomesKeyOnlyIfNeeded:YES];

  [panel setFrameUsingName:@"styles_panel"];
  [panel setFrameAutosaveName:@"styles_panel"];

  [stylesList setHeaderView:nil];
  [stylesList setBackgroundColor:[NSColor whiteColor]];
  [stylesList setRowHeight:20];

  [self load];

  [stylesList reloadData];
}

static id sharedStylesPanel = nil;

+ (id) sharedInstance {
  if (! sharedStylesPanel) {
    sharedStylesPanel = [[self alloc] init];
    [NSBundle loadNibNamed:@"StylesPanel" owner:sharedStylesPanel];
  }
  return sharedStylesPanel;
}

- (void) dealloc {
  if (self != sharedStylesPanel) {
    [styles release];
    [stylesMenu release];
    [super dealloc];
  }
}

- (void) setStylesMenu:(NSMenu*) menu {
  stylesMenu = [menu retain];
  [self updateStylesMenu];
}

- (void) orderFrontStylesPanel:(id)sender {
  [panel makeKeyAndOrderFront:nil];
  [stylesList reloadData];
}

- (void) updateStylesMenu
{
  NSMutableArray* toremove = [NSMutableArray array];
  for (NSMenuItem* it in [stylesMenu itemArray]) {
    if ([it tag] == STYLE_ITEM_TAG) {
      [toremove addObject:it];
    }
  }
  for (NSMenuItem* it in toremove) {
    [stylesMenu removeItem:it];
  }

  NSInteger c = 0;
  for (NSDictionary *it in styles) {
    NSString *title = [it valueForKey:@"title"];
    if ([title hasPrefix:@"_"])
      continue;

    NSString *key = @"";
    if (c < 10) key = [NSString stringWithFormat:@"%ld", c];
    NSMenuItem *item = [stylesMenu addItemWithTitle:title
                                             action:@selector(applyMenuItem:) 
                                      keyEquivalent:key];
    [item setTarget:self];
    [item setRepresentedObject:[NSNumber numberWithInteger:c]];
    [item setTag:STYLE_ITEM_TAG];
    c++;
  }
}

- (void) applyMenuItem:(id)sender {
  NSInteger row = [[sender representedObject] integerValue];
  [stylesList selectRow:row byExtendingSelection:NO];

  [NSApp sendAction:@selector(performStylesPanelAction:) to:nil from:sender];
}

- (void) __saveAndReload {
  [stylesList reloadData];

  [self save];
  [self updateStylesMenu];
}

- (void) load {
  NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
  NSArray* ls = [defs objectForKey:@"styles"];

  [styles removeAllObjects];

  if ([ls count] > 0) {
    for (NSDictionary* it in ls) {
      NSMutableDictionary* dict = [it mutableCopy];
      NSData* data = [dict valueForKey:@"attributes"];
      if (data) {
        [dict setValue:attributesForData(data) forKey:@"attributes"];
      }
      else {
        [dict setValue:[NSDictionary dictionary] forKey:@"attributes"];
      }

      [styles addObject:dict];
    }
  }
  else {
    NSFont *font = [Preferences objectForKey:RichTextFont];

    NSMutableDictionary* it = [NSMutableDictionary dictionary];
    [it setValue:@"Body" forKey:@"title"];
    [styles addObject:it];
    
    it = [NSMutableDictionary dictionary];
    [it setValue:@"Header" forKey:@"title"];
    [styles addObject:it];
    
    it = [NSMutableDictionary dictionary];
    [it setValue:@"Footer" forKey:@"title"];
    [styles addObject:it];
  }
}

- (void) save {
  @try {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray* tosave = [NSMutableArray array];

    for (NSDictionary* it in styles) {
      NSMutableDictionary* dict = [it mutableCopy];
      if ([dict valueForKey:@"attributes"]) {
        NSData* data = dataForAttributes([dict valueForKey:@"attributes"]);
        [dict setValue:data forKey:@"attributes"];
      }
      [tosave addObject:dict];
    }

    [defs setObject:tosave forKey:@"styles"];
    [defs synchronize];
  }
  @catch(NSException* ex) {
    NSLog(@"save error: %@", ex);
  }
}

- (void) setSelectedStyle:(NSDictionary*) style {
  NSInteger row = [stylesList selectedRow];
  if (row < 0) return;
  
  NSMutableDictionary* it = [styles objectAtIndex:row];
  [it setValue:style forKey:@"attributes"];

  [self __saveAndReload];
}

- (NSDictionary*) selectedStyle {
  NSInteger row = [stylesList selectedRow];
  if (row < 0) return nil;

  NSMutableDictionary* it = [styles objectAtIndex:row];
  return [it valueForKey:@"attributes"];
}

- (void) addStyle:(id) sender {
  NSMutableDictionary* it = [NSMutableDictionary dictionary];
  [it setValue:@"New Style" forKey:@"title"];
  [styles addObject:it];
  
  [stylesList reloadData];

  [self __saveAndReload];
}

- (void) removeStyle:(id) sender {
  NSInteger row = [stylesList selectedRow];
  if (row < 0) return;

  [styles removeObjectAtIndex:row];
  
  [self __saveAndReload];
}

- (void) tableView:(NSTableView*)table willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)col row: (NSInteger)row {
}

- (id) tableView:(NSTableView*) table objectValueForTableColumn:(NSTableColumn*) col row:(NSInteger) row {
  NSDictionary* it = [styles objectAtIndex: row];
  
  NSString* title = [it valueForKey:@"title"];
  NSMutableDictionary* attr = [[it valueForKey:@"attributes"] mutableCopy];

  NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString: title];
  if (attr) {
    NSFont* font = [attr valueForKey:@"NSFont"];
    if (font) {
      if ([font pointSize] > 20) {
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:20];
        [attr setValue:font forKey:@"NSFont"];
      }
    }
    [str setAttributes:attr range:NSMakeRange(0, [str length])];
  }

  [str autorelease];
  return str;
}

- (void) tableView:(NSTableView*)table setObjectValue:(id)obj forTableColumn:(NSTableColumn*)col row:(NSInteger)row {
  if ([obj length] > 0) {
    NSMutableDictionary* it = [styles objectAtIndex: row];
    [it setValue:obj forKey:@"title"];
    [self performSelector:@selector(__saveAndReload) withObject:nil afterDelay:0.1];
  }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView*) table {
  return [styles count];
}

@end
