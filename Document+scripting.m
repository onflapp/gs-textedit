/*
*/

#import "Document.h"

@implementation Document (scripting)

- (void)setTextContent:(NSString*) txt 
{
  if (!txt) return;

  NSTextStorage* storage = [self textStorage];
  NSAttributedString* str = [[NSAttributedString alloc] initWithString:txt];
  [storage beginEditing];
  [storage setAttributedString:str];
  [storage endEditing];

  RELEASE(str);
}

- (NSString*)textContent
{
  return [[self textStorage] string];
}

- (void) save
{
  [self save:self];
}
@end
