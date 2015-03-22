//
//  NSXMLDocument+BNRAdditions.m
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import "NSXMLDocument+BNRAdditions.h"

@implementation NSXMLDocument (BNRAdditions)

+ (BOOL)bnr_canParseData:(NSData *)data
             withOptions:(NSUInteger)mask
{
    return [self bnr_canParseData:data
                      withOptions:mask
                         document:NULL
                            error:NULL];
}

+ (BOOL)bnr_canParseData:(NSData *)data
             withOptions:(NSUInteger)mask
                document:(NSXMLDocument **)documentOut
                   error:(NSError **)errorOut
{
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data
                                                          options:mask
                                                            error:&error];
    
    if (documentOut) {
        *documentOut = document;
    }
    if (errorOut) {
        *errorOut = error;
    }
    return !!document;
}

@end
