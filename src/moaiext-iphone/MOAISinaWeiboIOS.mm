//
//  MOAISinaWeiboIOS.m
//  Sina web support for MOAI SDK (iOS only)
//
//  Created by Benny Chen (rockerbenny@gmail.com) on 11/5/12.
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

#ifndef DISABLE_SINAWEIBO

#include "pch.h"
#include <moaiext-iphone/MOAISinaWeiboIOS.h>

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	_singletonHello
	@text	Prints the string 'MOAISinaWeiboIOS singleton foo!' to the console.

	@out	nil
*/
int MOAISinaWeiboIOS::_singletonHello ( lua_State* L ) {
	UNUSED ( L );

	printf ( "MOAISinaWeiboIOS singleton foo!\n" );
	
	return 0;
}

//================================================================//
// MOAISinaWeiboIOS
//================================================================//

//----------------------------------------------------------------//
MOAISinaWeiboIOS::MOAISinaWeiboIOS () {
	
	// register all classes MOAISinaWeiboIOS derives from
	// we need this for custom RTTI implementation
	RTTI_BEGIN
		RTTI_EXTEND ( MOAILuaObject )
		
		// and any other objects from multiple inheritance...
		// RTTI_EXTEND ( MOAISinaWeiboIOSBase )
	RTTI_END
}

//----------------------------------------------------------------//
MOAISinaWeiboIOS::~MOAISinaWeiboIOS () {
}

//----------------------------------------------------------------//
void MOAISinaWeiboIOS::RegisterLuaClass ( MOAILuaState& state ) {

	// call any initializers for base classes here:
	// MOAIFooBase::RegisterLuaClass ( state );

	// also register constants:
	// state.SetField ( -1, "FOO_CONST", ( u32 )FOO_CONST );

	// here are the class methods:
	luaL_Reg regTable [] = {
		{ "init",		_singletonHello },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

#endif
