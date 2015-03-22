//
//  AttributeMacros.h
//  DemoMonkey
//
//  Created by Nate Chandler on 3/21/15.
//
//

#ifndef DemoMonkey_AttributeMacros_h
#define DemoMonkey_AttributeMacros_h

#ifndef BNR_NONNULL
    #if __has_attribute(__nonnull)
        #define BNR_NONNULL __nonnull
    #else
        #define BNR_NONNULL
    #endif
#endif

#ifndef BNR_NULLABLE
    #if __has_attribute(__nullable)
        #define BNR_NULLABLE __nullable
    #else
        #define BNR_NULLABLE
    #endif
#endif

#ifndef BNR_NULL_UNSPECIFIED
    #if __has_attribute(__null_unspecified)
        #define BNR_NULL_UNSPECIFIED __null_unspecified
    #else
        #define BNR_NULL_UNSPECIFIED
    #endif
#endif

#endif
