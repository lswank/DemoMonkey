//
//  Step+XMLAdditions.m
//  DemoMonkey
//
//  Created by Nate Chandler on 3/15/15.
//
//

#import "Step+XMLAdditions.h"

NSString * const BNR_NONNULL StepXMLAdditionsKeyStep = @"step";

static NSString * BNR_NONNULL const StepXMLAdditionsKeyTableSummary = @"tableSummary";
static NSString * BNR_NONNULL const StepXMLAdditionsKeyBody = @"body";
static NSString * BNR_NONNULL const StepXMLAdditionsKeyTooltip = @"tooltip";

@implementation Step (XMLAdditions)

- (NSXMLElement * BNR_NONNULL)XMLElement {
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

- (Step * BNR_NULLABLE)initWithXMLElement:(NSXMLElement * BNR_NONNULL)element {
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
