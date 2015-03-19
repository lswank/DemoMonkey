//
//  NSKeyedUnarchiver+BNRAdditions.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const BNRNSKeyedArchiverErrorDomain;

typedef NS_ENUM(NSInteger, BNRNSKeyedArchiverErrorCode) {
    BNRNSKeyedArchiverErrorCodeNoError = 0,
    BNRNSKeyedArchiverErrorCodeInvalidArchive,
};

@interface NSKeyedUnarchiver (BNRAdditions)

+ (id)bnr_unarchiveObjectWithData:(NSData *)data
                            error:(NSError **)outError;
+ (id)bnr_unarchiveObjectWithData:(NSData *)data
                            error:(NSError **)outError
                       errorMaker:(NSError *(^)(NSException *))block;

+ (BOOL)bnr_canParseData:(NSData *)data
                   error:(NSError **)outError
              errorMaker:(NSError *(^)(NSException *))block;
+ (BOOL)bnr_canParseData:(NSData *)data;

@end
