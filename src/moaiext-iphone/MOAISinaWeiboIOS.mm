// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

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
