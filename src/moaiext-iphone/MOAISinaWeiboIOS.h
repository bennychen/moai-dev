//
//  MOAISinaWeiboIOS.h
//  Sina web support for MOAI SDK (iOS only)
//
//  Created by Benny Chen (rockerbenny@gmail.com) on 11/5/12.
//
//// Example usage:
//
//
// MIT License
// Copyright (C) 2012. Benny Chen
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

#ifndef MOAISINAWEIBOIOS_H
#define MOAISINAWEIBOIOS_H

#ifndef DISABLE_SINAWEIBO

#include <moaicore/moaicore.h>

#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"
#import "MOAISinaWeiboCompileView.h"

//================================================================//
// MOAISinaWeiboIOSDelegate
//================================================================//
@interface MOAISinaWeiboIOSDelegate : NSObject < SinaWeiboDelegate > {
@private
}
@end

//================================================================//
// MOAISinaWeiboCompileViewDelegate
//================================================================//
@interface MOAISinaWeiboCompileViewDelegate : NSObject < SinaWeiboCompileViewDelegate > {
@private
}
@end

//================================================================//
// MOAISinaWeiboRequestIOSDelegate
//================================================================//
@interface MOAISinaWeiboRequestIOSDelegate : NSObject < SinaWeiboRequestDelegate > {
@private
}
@end

//================================================================//
// MOAISinaWeiboIOS
//================================================================//
/**	@name	MOAISinaWeiboIOS
	@text	.
*/
class MOAISinaWeiboIOS :
	public MOAIGlobalClass < MOAISinaWeiboIOS, MOAILuaObject >,
	public MOAIGlobalEventSource
{
private:
	
	//----------------------------------------------------------------//
	static int		_init			( lua_State* L );
	static int	    _login			( lua_State* L );
	static int      _logout			( lua_State* L );
	static int		_compileDialog	( lua_State* L );
	static int      _isAuthValid	( lua_State* L );
	static int		_isAuthExpired	( lua_State* L );
	static int      _getUserId		( lua_State* L );
	static int	    _postText       ( lua_State* L );
	static int      _postTextWithImg( lua_State* L );

public:
	
	DECL_LUA_SINGLETON ( MOAISinaWeiboIOS );
	
	enum {
		SESSION_DID_LOGIN,
		SESSION_DID_LOGOUT,
		DIALOG_LOG_IN_CANCEL,
		DIALOG_POST_OK_CLICKED,
		DIALOG_POST_CANCEL_CLICKED,
		REQUEST_RESPONSE_WITH_RESULT,
		REQUEST_RESPONSE_WITH_ERROR,
	};
		
	SinaWeibo *mSinaWeibo;
	MOAISinaWeiboIOSDelegate*			mWeiboDelegate;	
	MOAISinaWeiboRequestIOSDelegate*	mWeiboRequestDelegate;
	MOAISinaWeiboCompileViewDelegate*   mWeiboCompileDelegate;

	//----------------------------------------------------------------//
					MOAISinaWeiboIOS			();
					~MOAISinaWeiboIOS			();
	void		    RemoveAuthData();
	void			StoreAuthData();
	void			HandleOpenURL( NSURL* url );
	void			RegisterLuaClass	( MOAILuaState& state );
};

#endif

#endif