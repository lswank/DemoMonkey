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

- (BNR_NONNULL NSXMLElement *)XMLElement;
- (BNR_NULLABLE Step *)initWithXMLElement:(BNR_NONNULL NSXMLElement *)element;

@end
