//
//  MOAIAppirater.m
//  Appirater support for MOAI SDK (iOS only)
//
//  Created by Benny Chen (rockerbenny@gmail.com) on 11/27/12.
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

#ifndef DISABLE_APPIRATER

#include "pch.h"

#import <moaiext-iphone/MOAIAppirater.h>
#import "Appirater.h"

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	_init
	@text	Initialize appirater

	@out	nil
*/
int MOAIAppirater::_init ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSLog( @"MOAIAppirater initialization starts!\n" );
	
	cc8* appId = state.GetValue < cc8* >( 1, NULL );
	int daysUntilPrompt = state.GetValue < int >( 2, 1 );
	int usesUntilPrompt = state.GetValue < int >( 3, 10 );
	int timeBeforeReminding = state.GetValue < int >( 4, 2 );
	int significantEventsUntilPrompt = state.GetValue < int >( 5, -1 );
	bool isDebug = state.GetValue<bool>( 6, false);
	
	NSString* idString = [[ NSString alloc ] initWithUTF8String:appId ];
	
	[Appirater setAppId:idString];
	[Appirater setDaysUntilPrompt:daysUntilPrompt];
	[Appirater setUsesUntilPrompt:usesUntilPrompt];
	[Appirater setTimeBeforeReminding:timeBeforeReminding];
	[Appirater setSignificantEventsUntilPrompt:significantEventsUntilPrompt];
	[Appirater setDebug:isDebug];
	
	[Appirater appLaunched:YES];
	
	return 0;
}
//----------------------------------------------------------------//
/**	@name	_userDidSignificantEvent
 @text	
 
 @out	nil
 */
int MOAIAppirater::_userDidSignificantEvent( lua_State* L )
{
	[Appirater userDidSignificantEvent:YES];
	return 0;
}


//================================================================//
// MOAIAppirater
//================================================================//

//----------------------------------------------------------------//
MOAIAppirater::MOAIAppirater () {
	
	RTTI_SINGLE ( MOAILuaObject )
	
}

//----------------------------------------------------------------//
MOAIAppirater::~MOAIAppirater () {

}

//----------------------------------------------------------------//
void MOAIAppirater::ApplicationWillEnterForeground()
{
	[Appirater appEnteredForeground:YES];
}

//----------------------------------------------------------------//
void MOAIAppirater::RegisterLuaClass ( MOAILuaState& state ) {
	// also register constants:

	// here are the class methods:
	luaL_Reg regTable [] = {
		{ "init",					_init },
		{ "userDidSignificantEvent",					_userDidSignificantEvent },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

#endif
