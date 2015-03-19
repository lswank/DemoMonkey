
/*
     File: MyDocument.m
 Abstract: Document object to manage a collection of text snippets; the snippets may be displayed in one or two windows:
 * A window managed by a DisplayController window controller which is solely for display purposes;
 * Optionally, a window managed by an EditController window controller, which is used for editing the snippets. 
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "MyDocument.h"
#import "DisplayController.h"
#import "EditController.h"
#import "Step.h"
#import "Step+XMLAdditions.h"
#import "NSKeyedUnarchiver+BNRAdditions.h"
#import "DocumentController.h"

static NSString * const MyDocumentErrorDomain = @"com.bignerdranch.demomonkey.MyDocumentErrorDomain";

typedef NS_ENUM(NSInteger, MyDocumentErrorCode) {
    MyDocumentErrorCodeNoError = 0,
    MyDocumentErrorCodeXMLInvalidStep,
    MyDocumentErrorCodeArchiveInvalid,
};

@interface MyDocument () {
    NSMutableArray *_steps;
}

@end

@implementation MyDocument

@synthesize steps = _steps;

#pragma mark -
#pragma mark Services methods

/*
 Service items apply to the display controller.
 */
-(NSString *)textForCurrentSelectionAndAdvance {
    return [self.displayController textForCurrentSelectionAndAdvance];
}

- (void)rewind {
    [self.displayController rewind];
}

- (void)moveUpOneLine {
    [self.displayController moveUpOneLine];
}

- (void)moveDownOneLine {
    [self.displayController moveDownOneLine];
}

- (void)createNewStep:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    
    NSArray *newSteps = [pboard readObjectsForClasses:@[Step.class] options:@{}];
    
    if ([newSteps count] != 1) {
        *error = NSLocalizedString(@"Couldn't create a step", @"Service error message");
        return;
    }
    
    Step *newStep = newSteps[0];    
    NSUInteger currentStepCount = [self countOfSteps];    
    newStep.tableSummary = [NSString stringWithFormat:@"Step %@", @(currentStepCount)];
    newStep.undoManager = [self undoManager];
    
    [self insertObject:newStep inStepsAtIndex:currentStepCount];    
    [self editSteps:nil];
}


#pragma mark -
#pragma mark Reading and writing file

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    switch (MyDocumentTypeFromMyDocumentTypeName(typeName)) {
        case MyDocumentTypeXML: {
            return [self readFromXMLData:data error:outError];
        } break;
        case MyDocumentTypeBinaryPlist: {
            return [self readFromArchiveData:data error:outError];
        } break;
        case MyDocumentTypeUnknown: {
            NSAssert(NO, @"MyDocument tried to open a document of unknown type.  This should have been handled in the DocumentController.  Programmer error!");
            __builtin_unreachable();
        }
    }
}

- (BOOL)readFromXMLData:(NSData *)data error:(NSError **)outError
{
    BOOL success = NO;
    NSError *error = nil;
    NSArray *steps = nil;
    
    NSError *parseXMLError = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:0 error:&parseXMLError];
    NSXMLElement *root = document.rootElement;
    
    NSError *addError = nil;
    
    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];
    
    for (NSXMLElement *childElement in [root elementsForName:StepXMLAdditionsKeyStep]) {
        Step * __nullable step = [[Step alloc] initWithXMLElement:childElement];
        if (step) {
            [mutableSteps addObject:step];
        } else {
            NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : @"Invalid XML file!  Found a step which could not be initialized."};
            addError = [NSError errorWithDomain:MyDocumentErrorDomain
                                           code:MyDocumentErrorCodeXMLInvalidStep
                                       userInfo:userInfo];
            mutableSteps = nil;
            break;
        }
    }
    
    if (mutableSteps) {
        success = YES;
        error = nil;
        steps = [mutableSteps copy];
    } else {
        success = NO;
        error = addError;
        steps = nil;
    }
    
    self.steps = steps;
    if (outError) {
        *outError = error;
    }
    return success;
}

- (BOOL)readFromArchiveData:(NSData *)data error:(NSError **)outError
{
    BOOL success = NO;
    NSError *error = nil;
    NSArray *steps = nil;
    
    NSError *unarchiveError = nil;
    id unarchivedSteps =  [NSKeyedUnarchiver bnr_unarchiveObjectWithData:data
                                                                   error:&unarchiveError
                                                              errorMaker:^(NSException * exception) {
                                                                  NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : @"Invalid archive!"};
                                                                  NSError *result = [NSError errorWithDomain:MyDocumentErrorDomain
                                                                                                        code:MyDocumentErrorCodeArchiveInvalid
                                                                                                    userInfo:userInfo];
                                                                  return result;
                                                              }];
    
    if (!!unarchivedSteps) {
        success = YES;
        error = nil;
        steps = unarchivedSteps;
    } else {
        success = NO;
        error = unarchiveError;
        steps = nil;
    }

    self.steps = steps;
    if (outError) {
        *outError = error;
    }
    return success;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    switch (MyDocumentTypeFromMyDocumentTypeName(typeName)) {
        case MyDocumentTypeBinaryPlist: {
            return [self archiveDataWithError:outError];
        } break;
        case MyDocumentTypeXML: {
            return [self xmlDataWithError:outError];
        } break;
        case MyDocumentTypeUnknown: {
            NSAssert(NO, @"Trying to save demoMonkey document by document type is unknown.  The document type should have been handled by the DocumentController.  Programmer error!");
            __builtin_unreachable();
        } break;
    }
}

- (NSData *)xmlDataWithError:(NSError **)outError
{
    NSArray *stepElements = ^{
        NSMutableArray *mutableResult = [[NSMutableArray alloc] init];
        
        for (Step *step in self.steps) {
            [mutableResult addObject:step.XMLElement];
        }
        
        return [mutableResult copy];
    }();
    
    NSXMLElement *root = [NSXMLElement elementWithName:@"demoMonkey"
                                              children:stepElements
                                            attributes:nil];
    NSXMLDocument *document = [NSXMLDocument documentWithRootElement:root];
    return [document XMLDataWithOptions:NSXMLNodePrettyPrint];
}

- (NSData *)archiveDataWithError:(NSError **)outError
{
    return [NSKeyedArchiver archivedDataWithRootObject:self.steps];
}

#pragma mark -
#pragma mark Managing window controllers

- (void)makeWindowControllers {
    
    // Create the display controller and keep a reference to it.
    DisplayController *aDisplayController = [[DisplayController alloc] initWithWindowNibName:@"Display"];
    [aDisplayController setShouldCloseDocument:YES];
    [aDisplayController showWindow:self];
    [self addWindowController:aDisplayController];
    self.displayController = aDisplayController;
}


- (EditController *)editController {
    /*
     If an edit controller exists, it's the second object in window controllers array.  If there's only one item in the array, create a new edit controller.
     */
    EditController *editController = nil;
    NSArray *myWindowControllers = [self windowControllers];
    
    if ([myWindowControllers count] == 1) {
        editController = [[EditController alloc] initWithWindowNibName:@"Edit"];
        [self addWindowController:editController];
        // Position the edit window atop the display window.
        NSRect frame = [[self.displayController window] frame];
        NSPoint topLeft = frame.origin;
        topLeft.y += [[[self.displayController window] contentView] frame].size.height;
        [[editController window] setFrameTopLeftPoint:topLeft];
    }
    else {
        editController = myWindowControllers[1];
    }
    
    return editController;
}    



- (IBAction)editSteps:(id)sender {
    [self.editController showWindow:self];
}


#pragma mark -
#pragma mark Steps accessors

- (NSUInteger)countOfSteps {
    return [self.steps count];
}

- (id)objectInStepsAtIndex:(NSUInteger)idx {
    return self.steps[idx];
}

- (void)insertObject:(id)anObject inStepsAtIndex:(NSUInteger)idx {
    [[[self undoManager] prepareWithInvocationTarget:self] removeObjectFromStepsAtIndex:idx];        
    [_steps insertObject:anObject atIndex:idx];
}

- (void)removeObjectFromStepsAtIndex:(NSUInteger)idx {
    
    id anObject = [self objectInStepsAtIndex:idx];
    [[[self undoManager] prepareWithInvocationTarget:self] insertObject:anObject inStepsAtIndex:idx];    
    [_steps removeObjectAtIndex:idx];
}

- (void)replaceObjectInStepsAtIndex:(NSUInteger)idx withObject:(id)anObject {
    
    id oldObject = [self objectInStepsAtIndex:idx];
    [[[self undoManager] prepareWithInvocationTarget:self] replaceObjectInStepsAtIndex:idx withObject:oldObject];
    _steps[idx] = anObject;
}

- (NSArray *)steps {
    return [_steps copy];
}

- (void)setSteps:(NSArray *)aSteps {
    if (_steps != aSteps) {
        _steps = [aSteps mutableCopy];
    }
}


#pragma mark -
#pragma mark Object lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _steps = [[NSMutableArray alloc] init];
    }
    return self;    
}

@end
