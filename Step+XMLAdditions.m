//
//  Step+XMLAdditions.m
//  DemoMonkey
//
//  Created by Nate Chandler on 3/15/15.
//
//

#import "Step+XMLAdditions.h"

NSString * const __nonnull StepXMLAdditionsKeyStep = @"step";

static NSString * __nonnull const StepXMLAdditionsKeyTableSummary = @"tableSummary";
static NSString * __nonnull const StepXMLAdditionsKeyBody = @"body";
static NSString * __nonnull const StepXMLAdditionsKeyTooltip = @"tooltip";

@implementation Step (XMLAdditions)

- (nonnull NSXMLElement *)XMLElement {
    NSXMLElement *theTableSummaryElement = [NSXMLElement elementWithName:StepXMLAdditionsKeyTableSummary
                                                             stringValue:self.tableSummary];
    NSXMLNode *bodyText = [[NSXMLNode alloc] initWithKind:NSXMLTextKind options:NSXMLNodeIsCDATA];
    bodyText.stringValue = self.body;
    NSXMLElement *theBody = [NSXMLElement elementWithName:StepXMLAdditionsKeyBody
                                                 children:@[bodyText]
                                               attributes:nil];
    NSXMLElement *theTooltip = [NSXMLElement elementWithName:StepXMLAdditionsKeyTooltip
                                                 stringValue:self.tooltip];
    NSXMLElement *result = [NSXMLElement elementWithName:StepXMLAdditionsKeyStep
                                                children:@[theTableSummaryElement, theBody, theTooltip]
                                              attributes:nil];
    return result;
}

- (nullable Step *)initWithXMLElement:(nonnull NSXMLElement *)element {
    self = [super init];
    if (self) {
        NSXMLElement *tableSummaryElement = [element elementsForName:StepXMLAdditionsKeyTableSummary].firstObject;
        NSXMLElement *bodyElement = [element elementsForName:StepXMLAdditionsKeyBody].firstObject;
        NSXMLElement *tooltipElement = [element elementsForName:StepXMLAdditionsKeyTooltip].firstObject;
        if (tableSummaryElement && bodyElement && tooltipElement) {
            self.tableSummary = tableSummaryElement.stringValue;
            self.body = bodyElement.stringValue;
            self.tooltip = tooltipElement.stringValue;
        } else {
            return nil;
        }
    }
    return self;
}

@end
