//
//  DocumentController.m
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import "DocumentController.h"
#import "NSXMLDocument+BNRAdditions.h"
#import "NSKeyedUnarchiver+BNRAdditions.h"

NSString * const MyDocumentTypeNameArchive = @"com.bignerdranch.demomonkey.property-list";
NSString * const MyDocumentTypeNameXML = @"com.bignerdranch.demomonkey.xml";

NSString * const DocumentControllerErrorDomain = @"DocumentControllerErrorDomain";

MyDocumentType MyDocumentTypeFromMyDocumentTypeName(NSString *name) {
    static NSDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
        
#define SetTypeForName( type , name ) do { \
mutableDictionary[name] = @((type));   \
} while(0);
        
        SetTypeForName(MyDocumentTypeBinaryPlist, MyDocumentTypeNameArchive);
        SetTypeForName(MyDocumentTypeXML, MyDocumentTypeNameXML);
        
#undef SetTypeForName
        
        dictionary = [mutableDictionary copy];
    });
    
    NSNumber *typeNumber = dictionary[name];
    if (typeNumber) {
        return typeNumber.integerValue;
    } else {
        return MyDocumentTypeUnknown;
    }
}

@implementation DocumentController

- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    // OS X with HFS can't know the correct UTI to give us:
    //    it determines the UTI on the basis of an extension and a creator code.
    //    The first UTI using that extension
    //    exported by the app with the appropriate creator code
    //    will be used.
    //    In this case, that UTI is simply com.bignerdranch.demomonkey.file.
    //    To determine the actual format of the file,
    //    we have a couple of options:
    //    (1) shell out to file (man file)
    //    (2) try to parse as one format, then fall back to the other(s)
    //    The second approach is followed here.
    //    - Nate 2015.03.18
    
    NSData *data = [NSData dataWithContentsOfURL:url
                                         options:NSDataReadingMappedIfSafe
                                           error:outError];
    if (!data) {
        return nil;
    }
    
    if ([NSXMLDocument bnr_canParseData:data withOptions:0]) {
        return MyDocumentTypeNameXML;
    }
    if ([NSKeyedUnarchiver bnr_canParseData:data]) {
        return MyDocumentTypeNameArchive;
    }
    
    if (outError) {
        NSString *informativeErrorAlertText = [NSString stringWithFormat:@"The specified file (%@) could not be read.", url.path];
        NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : informativeErrorAlertText};
        NSError *error = [NSError errorWithDomain:DocumentControllerErrorDomain
                                             code:DocumentControllerErrorCodeUnparseable
                                         userInfo:userInfo];
        *outError = error;
    }
    return nil;
}

@end
