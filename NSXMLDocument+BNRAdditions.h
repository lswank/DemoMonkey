//
//  NSXMLDocument+BNRAdditions.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import <Foundation/Foundation.h>

@interface NSXMLDocument (BNRAdditions)

+ (BOOL)bnr_canParseData:(NSData *)data
             withOptions:(NSUInteger)mask;
+ (BOOL)bnr_canParseData:(NSData *)data
             withOptions:(NSUInteger)mask
                document:(NSXMLDocument **)documentOut
                   error:(NSError **)errorOut;

@end
