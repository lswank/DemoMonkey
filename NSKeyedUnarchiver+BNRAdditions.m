//
//  NSKeyedUnarchiver+BNRAdditions.m
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import "NSKeyedUnarchiver+BNRAdditions.h"

NSString * const BNRNSKeyedArchiverErrorDomain = @"com.bignerdranch.nsadditions.keyedarchiver.errordomain";

@implementation NSKeyedUnarchiver (BNRAdditions)

+ (id)bnr_unarchiveObjectWithData:(NSData *)data
                              error:(NSError **)outError
{
    return [self bnr_unarchiveObjectWithData:data
                                       error:outError
                                  errorMaker:nil];
}

+ (id)bnr_unarchiveObjectWithData:(NSData *)data
                      error:(NSError **)outError
                 errorMaker:(NSError *(^)(NSException *))block
{
    @try {
        // This can throw.
        id result = [self unarchiveObjectWithData:data];
        
        return result;
    }
    @catch (NSException *exception) {
        if (outError) {
            *outError = ^{
                if (block) {
                    return block(exception);
                } else {
                    NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : @"Invalid archive!"};
                    NSError *result = [NSError errorWithDomain:BNRNSKeyedArchiverErrorDomain
                                                          code:BNRNSKeyedArchiverErrorCodeInvalidArchive
                                                      userInfo:userInfo];
                    return result;
                }
            }();
        }
        return NO;
    }
}

+ (BOOL)bnr_canParseData:(NSData *)data
                   error:(NSError **)outError
              errorMaker:(NSError *(^)(NSException *))block
{
    return !![self bnr_unarchiveObjectWithData:data
                                         error:outError
                                    errorMaker:block];
}

+ (BOOL)bnr_canParseData:(NSData *)data
{
    return [self bnr_canParseData:data
                            error:NULL
                       errorMaker:nil];
}

@end
