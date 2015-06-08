//
//  Step+XMLAdditions.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/15/15.
//
//

#import "Step.h"

extern NSString * BNR_NONNULL const StepXMLAdditionsKeyStep;

@interface Step (XMLAdditions)

- (NSXMLElement * BNR_NONNULL)XMLElement;
- (Step * BNR_NULLABLE)initWithXMLElement:(NSXMLElement * BNR_NONNULL)element;

@end
