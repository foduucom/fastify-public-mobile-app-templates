#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CompressFileHandler.h"
#import "CompressHandler.h"
#import "CompressListHandler.h"
#import "ImageCompressPlugin.h"
#import "UIImage+scale.h"

FOUNDATION_EXPORT double flutter_image_compress_commonVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_image_compress_commonVersionString[];

