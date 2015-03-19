//
//  Step+XMLAdditions.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/15/15.
//
//

#import "Step.h"

extern NSString * __nonnull const StepXMLAdditionsKeyStep;

@interface Step (XMLAdditions)

- (nonnull NSXMLElement *)XMLElement;
- (nullable Step *)initWithXMLElement:(nonnull NSXMLElement *)element;

@end
