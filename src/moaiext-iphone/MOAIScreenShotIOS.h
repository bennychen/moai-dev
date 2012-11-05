// MOAIScreenShotIOS by Herman Jakobi (@hermanjakobi) , 13/6/12
// Screen snapshot plugin for MOAI SDK V1.1 (IOS Only) 
//
//
//// Example usage:
//
// "
//  --- saves png in tmp directory on iOS device & on iOS simulator 
// 	local filename=MOAIScreenShotIOS.snapshotToFile(MOAIScreenShotIOS.PORTRAIT)
// .... load and use the file later in Moai SDK
//
// Based on BhSnapshot.mm 

//
//
// BhSnapshot.mm
// Screen snapshot plugin for Gideros Studio (IOS Only)

// Will dump the current contents of the OpenGL frame buffer to a temporary file and then
// answer the filename. You can then load this back in as a texture etc. Okay for deployment
// to IOS 3.1 and up.
//
// Example usage:
//
//  require "BhSnapshot"
// 	local filename=BhSnapshot.snapshot(BhSnapshot.PORTRAIT)
//  local image=Bitmap.new(Texture.new(filename))
//  image:setAnchorPoint(0.5, 0.5)
//  image:setPosition(application:getContentWidth(), application:getContentHeight())
//  stage:addChild(image)
//
// MIT License
// Copyright (C) 2012. Andy Bower, Bowerhaus LLP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef	MOAISCREENSIOS_H
#define	MOAISCREENSIOS_H

#ifndef DISABLE_SCREENSHOT

#import <moaicore/moaicore.h>

//needed for AKU-iphone.mm
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RotScale.h"
#import "UIImage+RoundedCorner.h"

//================================================================//
// MOAIScreenshotIOS
//================================================================//
/**	@name	MOAIScreenshotIOS
	@text	Wrapper for iOS Screenshot functionality.
	
*/

class MOAIScreenShotIOS:
	public MOAIGlobalClass < MOAIScreenShotIOS, MOAILuaObject > {
private:

	//----------------------------------------------------------------//
	
	static int	_snapshotToFile(lua_State* L) ;
	static int	_snapshotToAlbum(lua_State* L) ;
	
public:
	
	DECL_LUA_SINGLETON ( MOAIScreenShotIOS );

	
					MOAIScreenShotIOS				();
					~MOAIScreenShotIOS				();
	void			RegisterLuaClass				( MOAILuaState& state );
	
	
};


#endif
#endif