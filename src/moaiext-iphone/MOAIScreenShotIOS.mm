#ifndef DISABLE_SCREENSHOT

#include "pch.h"

#import <moaiext-iphone/MOAIScreenShotIOS.h>
#import <moaiext-iphone/NSDate+MOAILib.h>



//================================================================//
// Obj-C part
//================================================================//


@interface SnapshotHelper : NSObject
@end

@interface SnapshotHelper ()
@property(nonatomic, assign) CGRect bounds;
@property(nonatomic, assign) UIImageOrientation orientation;
@end

@implementation SnapshotHelper {
@private
    CGRect _bounds;
    UIImageOrientation _orientation;
}

@synthesize bounds = _bounds;
@synthesize orientation = _orientation;


static void freeImageData(void *, const void *data, size_t)
{
    //NSLog(@"Image data freed");
    free((void*)data);
}

-(UIImage *)getImageFromFrameBuffer {
    CGRect screenRect = [[ UIScreen mainScreen ] bounds ];
    CGFloat scale = [[ UIScreen mainScreen ] scale ];
	// TODO: later pass in parameter isLandscape, now is default to landscape
	CGFloat screenWidth = screenRect.size.height * scale;
	CGFloat screenHeight = screenRect.size.width * scale;
    size_t backingWidth= (size_t) screenWidth;
    size_t backingHeight= (size_t) screenHeight;
    GLubyte *buffer = (GLubyte *) malloc(backingWidth * backingHeight * 4);
	
	//NSLog(@"backing resolution (%f, %f)", screenWidth, screenHeight);
	
    glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
	
    // Make data provider from buffer
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, backingWidth * backingHeight * 4, freeImageData);
	
    // Set up for CGImage creation
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * backingWidth;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(backingWidth, backingHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
    // Make UIImage from CGImage
    UIImage *newUIImage = [[[UIImage alloc] initWithCGImage: imageRef] autorelease];
	
    UIImage *answerImage= [newUIImage rotate:_orientation];
	answerImage = [answerImage scaleWithMaxSize:1024];
    //NSLog(@"Snapshot image is extent (%f, %f)", answerImage.size.width, answerImage.size.height);
	
    // If we have a bounds rectangle then crop to this
    if (_bounds.origin.x || _bounds.origin.y || _bounds.size.width || _bounds.size.height) {
        UIImage *croppedImage= [answerImage croppedImage: _bounds];
        answerImage=croppedImage;
    }
	
    // Free up our temporaries
    CGDataProviderRelease(provider);
    CGImageRelease(imageRef);
	
    return answerImage;
}

-(NSString *)pathForTemporaryFileWithFormat: (NSString *)format
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
	
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: format, uuidStr]];
    assert(result != nil);
	
    CFRelease(uuidStr);
    CFRelease(uuid);
	
    return result;
}

@end
//================================================================//
// lua
//================================================================//



static CGRect getBoundsRect(lua_State *L, int stackOffset)   {
    // Gets a bounds rectangle (CGRect) from the table parameter at (stackOffset)
    // on the Lua stack. The rectangle is assumed to have {left, top, width, height}
    // components.
    lua_pushstring(L, "left");
    lua_gettable(L, stackOffset);
    double left = lua_tonumber(L, -1);
    lua_pop(L, 1);
	
    lua_pushstring(L, "top");
    lua_gettable(L, stackOffset);
    double top = lua_tonumber(L, -1);
    lua_pop(L, 1);
	
    lua_pushstring(L, "width");
    lua_gettable(L, stackOffset);
    double width = lua_tonumber(L, -1);
    lua_pop(L, 1);
	
    lua_pushstring(L, "height");
    lua_gettable(L, stackOffset);
    double height = lua_tonumber(L, -1);
    lua_pop(L, 1);
	
    return CGRectMake((CGFloat) left, (CGFloat) top, (CGFloat) width, (CGFloat) height);
}

int MOAIScreenShotIOS::_snapshotToFile(lua_State* L) {
	
    if (lua_isnumber(L, 1)) {
		
		SnapshotHelper *snapshotHelper= [[SnapshotHelper alloc] init];
		
        snapshotHelper.orientation = (UIImageOrientation) lua_tointeger(L, 1);
		
        if (lua_istable(L, 2))
            snapshotHelper.bounds = getBoundsRect(L, 2);
		
		
        // Fetch the pixels from the frame buffer into an UIImage
        UIImage *image= [snapshotHelper getImageFromFrameBuffer];
		
		assert(image);
		
        // Write image to PNG
        NSString *imageFile = [snapshotHelper pathForTemporaryFileWithFormat:@"screen%@.png"];
		
		NSLog(@"Write imageFile to: %@",imageFile);
		
        [UIImagePNGRepresentation(image) writeToFile:imageFile atomically:YES];
        
		//give back the path to LUA
		lua_pushstring(L, [imageFile UTF8String]);
		
        [snapshotHelper release];
    } else
        lua_pushnil(L);
    return 1;
}

int MOAIScreenShotIOS::_snapshotToAlbum(lua_State* L) {
    bool result=false;
	if (lua_isnumber(L, 1)) {
		SnapshotHelper *snapshotHelper= [[SnapshotHelper alloc] init];
		
		
		snapshotHelper.orientation = (UIImageOrientation) lua_tointeger(L, 1);
		
        if (lua_istable(L, 2))
            snapshotHelper.bounds = getBoundsRect(L, 2);
		
        // Fetch the pixels from the frame buffer into an UIImage
        UIImage *image= [snapshotHelper getImageFromFrameBuffer];
		
        // Write image to album
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		
		
        result=true;
		
		 [snapshotHelper release];
    }
	//give back the result to LUA
    lua_pushboolean(L, result);
    return 1;
}
//================================================================//
// MOAIScreenShotIOS
//================================================================//

//----------------------------------------------------------------//
MOAIScreenShotIOS::MOAIScreenShotIOS () {
	
	RTTI_SINGLE ( MOAILuaObject )
}

//----------------------------------------------------------------//
MOAIScreenShotIOS::~MOAIScreenShotIOS () {
	
}

//----------------------------------------------------------------//
void MOAIScreenShotIOS::RegisterLuaClass ( MOAILuaState& state ) {
  
    // This is the list of constants that can be accessed from Lua.
    // Remeber UI image orientation is reversed with OpenGL
	state.SetField ( -1, "IMAGE_ORIENTATION_UP",		(u32)UIImageOrientationDownMirrored);
	state.SetField ( -1, "IMAGE_ORIENTATION_DOWN",		(u32)UIImageOrientationUpMirrored );
	state.SetField ( -1, "IMAGE_ORIENTATION_LEFT",		(u32)UIImageOrientationLeftMirrored );
	state.SetField ( -1, "IMAGE_ORIENTATION_RIGHT",		(u32)UIImageOrientationRightMirrored );
	
	state.SetField ( -1, "IMAGE_ORIENTATION_DOWN_MIRRORED",			(u32)	UIImageOrientationUp);
	state.SetField ( -1, "IMAGE_ORIENTATION_UP_MIRRORED",	(u32)	UIImageOrientationDown );
	state.SetField ( -1, "IMAGE_ORIENTATION_LEFT_MIRRORED",		(u32)	UIImageOrientationLeft );
	state.SetField ( -1, "IMAGE_ORIENTATION_RIGHT_MIRRORED",		(u32)	UIImageOrientationRight );

	//This is a list of functions that can be called from Lua
    luaL_Reg regTable [] = {
        {"snapshotToFile", _snapshotToFile},
        {"snapshotToAlbum", _snapshotToAlbum},
		
        {NULL, NULL},
    };

	luaL_register ( state, 0, regTable );
}

#endif

