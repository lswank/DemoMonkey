//
//  DocumentController.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/19/15.
//
//

#import <Cocoa/Cocoa.h>

extern NSString * const DocumentControllerErrorDomain;

typedef NS_ENUM(NSInteger, DocumentControllerErrorCode) {
    DocumentControllerErrorCodeNoError,
    DocumentControllerErrorCodeUnparseable,
};

extern NSString * const MyDocumentTypeNameArchive;
extern NSString * const MyDocumentTypeNameXML;

typedef NS_ENUM(NSInteger, MyDocumentType) {
    MyDocumentTypeUnknown = 0,
    MyDocumentTypeBinaryPlist,
    MyDocumentTypeXML,
};

MyDocumentType MyDocumentTypeFromMyDocumentTypeName(NSString *name);

@interface DocumentController : NSDocumentController

@end
