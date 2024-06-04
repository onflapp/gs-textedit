#import <AppKit/AppKit.h>
#import "StylesPanel.h"

NSData* dataForAttributes(NSDictionary* dict) {
  NSAttributedString* str = [[NSAttributedString alloc] initWithString:@"x" attributes:dict];
  return [str RTFFromRange:NSMakeRange(0, 1) documentAttributes:nil];
}

NSDictionary* attributesForData(NSData* data) {
  NSAttributedString* str = [[NSAttributedString alloc] initWithRTF:data documentAttributes:nil];
  NSRange r = {0, 0};
  return [str attributesAtIndex:0 effectiveRange:&r];
}

@implementation StylesPanel

- (id )init {
  if (!(self = [super init]))
    return nil;
  
  styles = [[NSMutableArray alloc] init];

  return self;
}

- (void) awakeFromNib {
  [panel setBecomesKeyOnlyIfNeeded:YES];

  [stylesList setHeaderView:nil];
  [stylesList setBackgroundColor:[NSColor whiteColor]];

  [self load];
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
    [super dealloc];
  }
}

- (void) orderFrontStylesPanel:(id)sender {
  [panel makeKeyAndOrderFront:nil];
  [stylesList reloadData];
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
    NSMutableDictionary* it = [NSMutableDictionary dictionary];
    [it setValue:@"Header" forKey:@"title"];
    [styles addObject:it];
    
    it = [NSMutableDictionary dictionary];
    [it setValue:@"Body" forKey:@"title"];
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

  [stylesList reloadData];

  [self save];
}

- (NSDictionary*) selectedStyle {
  NSInteger row = [stylesList selectedRow];
  if (row < 0) return nil;

  NSMutableDictionary* it = [styles objectAtIndex:row];
  return [it valueForKey:@"attributes"];
}

- (void) tableView:(NSTableView*)table willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)col row: (NSInteger)row {
}

- (id) tableView:(NSTableView*) table objectValueForTableColumn:(NSTableColumn*) col row:(NSInteger) row {
  NSDictionary* it = [styles objectAtIndex: row];
  
  NSString* title = [it valueForKey:@"title"];
  NSDictionary* attr = [it valueForKey:@"attributes"];

  NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString: title];
  if (attr) {
    [str setAttributes:attr range:NSMakeRange(0, [str length])];
  }

  [str autorelease];
  return str;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView*) table {
  return [styles count];
}

@end
