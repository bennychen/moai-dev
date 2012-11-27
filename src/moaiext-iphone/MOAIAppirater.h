//
//  MOAIAppirater
//  Appirater support for MOAI SDK (iOS only)
//
//  Created by Benny Chen (rockerbenny@gmail.com) on 11/27/12.
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

#ifndef MOAIAPPIRATER_H
#define MOAIAPPIRATER_H

#ifndef DISABLE_APPIRATER

#include <moaicore/moaicore.h>

//================================================================//
// MOAIAppirater
//================================================================//
/**	@name	MOAIAppirater
	@text	.
*/
class MOAIAppirater :
	public MOAIGlobalClass < MOAIAppirater, MOAILuaObject >
{
private:
	
	//----------------------------------------------------------------//
	static int		_init			( lua_State* L );
	static int		_userDidSignificantEvent ( lua_State* L );

public:
	
	DECL_LUA_SINGLETON ( MOAIAppirater );

	//----------------------------------------------------------------//
					MOAIAppirater			();
					~MOAIAppirater			();
	void			ApplicationWillEnterForeground();
	void			RegisterLuaClass	( MOAILuaState& state );
};

#endif

#endif
