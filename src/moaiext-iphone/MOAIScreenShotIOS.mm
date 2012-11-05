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
	
	
    UIWindow* window = [[ UIApplication sharedApplication ] keyWindow ];
	
    UIViewController* controller = [ window rootViewController ]; 
    CGRect frame=controller.view.frame;
	
    size_t backingWidth= (size_t) frame.size.height;
    size_t backingHeight= (size_t) frame.size.width;
    GLubyte *buffer = (GLubyte *) malloc(backingWidth * backingHeight * 4);
	
	//NSLog(@"backing resolution (%f, %f)", frame.size.width, frame.size.height);
	
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
    // These correspond to the rotation modes that one has to use for the various device orientations.
    // Note that we use the "mirrored" options to compensate for the fact that the OpenGL frame buffer
    // is inverted.

	state.SetField ( -1, "PORTRAIT",			(u32)	UIImageOrientationDownMirrored);
	state.SetField ( -1, "PORTRAIT_UPSIDEDOWN",	(u32)	UIImageOrientationUpMirrored );
	state.SetField ( -1, "LANDSCAPE_LEFT",		(u32)	UIImageOrientationLeftMirrored );
	state.SetField ( -1, "LANDSCAPE_RIGHT",		(u32)	UIImageOrientationRightMirrored );

	//This is a list of functions that can be called from Lua
    luaL_Reg regTable [] = {
        {"snapshotToFile", _snapshotToFile},
        {"snapshotToAlbum", _snapshotToAlbum},
		
        {NULL, NULL},
    };

	luaL_register ( state, 0, regTable );
}

#endif

