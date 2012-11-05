// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef MOAISINAWEIBOIOS_H
#define MOAISINAWEIBOIOS_H

#include <moaicore/moaicore.h>

//================================================================//
// MOAISinaWeiboIOS
//================================================================//
/**	@name	MOAISinaWeiboIOS
	@text	.
*/
class MOAISinaWeiboIOS :
	public MOAIGlobalClass < MOAISinaWeiboIOS, MOAILuaObject > {
private:
	
	//----------------------------------------------------------------//
	static int		_singletonHello		( lua_State* L );

public:
	
	DECL_LUA_SINGLETON ( MOAISinaWeiboIOS )

	//----------------------------------------------------------------//
					MOAISinaWeiboIOS			();
					~MOAISinaWeiboIOS			();
	void			RegisterLuaClass	( MOAILuaState& state );
};

#endif
