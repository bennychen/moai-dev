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
// MOAISinaWeiboIOSDelegate
//================================================================//
@implementation MOAISinaWeiboIOSDelegate

//================================================================//
#pragma mark -
#pragma mark Protocol MOAISinaWeiboIOSDelegate
//================================================================//

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
	
	MOAISinaWeiboIOS::Get().StoreAuthData();
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
	MOAISinaWeiboIOS::Get().RemoveAuthData();
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
	MOAISinaWeiboIOS::Get().RemoveAuthData();
}

@end
//================================================================//
// MOAISinaWeiboRequestIOSDelegate
//================================================================//
@implementation MOAISinaWeiboRequestIOSDelegate

//================================================================//
#pragma mark -
#pragma mark Protocol MOAISinaWeiboRequestIOSDelegate
//================================================================//

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
       
    }
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"])
    {
        
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        NSLog(@"Post status failed with error : %@", error);
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        NSLog(@"Post image status failed with error : %@", error);
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
    }
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"])
    {
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
    }
}

@end

//================================================================//
// lua
//================================================================//

//----------------------------------------------------------------//
/**	@name	_init
	@text	Initialize sina weibo

	@out	nil
*/
int MOAISinaWeiboIOS::_init ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSLog( @"MOAISinaWeiboIOS initialization starts!\n" );
	
	cc8* appKey = lua_tostring ( state, 1 );
	cc8* appSecret = lua_tostring ( state, 2 );
	cc8* appRedirectURI = lua_tostring ( state, 3 );
	
	NSString* key = [[ NSString alloc ] initWithUTF8String:appKey ];
	NSString* secret = [[ NSString alloc ] initWithUTF8String:appSecret ];
	NSString* redirectUri = [[ NSString alloc ] initWithUTF8String:appRedirectURI ];
	
	MOAISinaWeiboIOS::Get().mSinaWeibo = [[SinaWeibo alloc] initWithAppKey:key appSecret:secret appRedirectURI:redirectUri
										andDelegate:MOAISinaWeiboIOS::Get().mWeiboDelegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        MOAISinaWeiboIOS::Get().mSinaWeibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        MOAISinaWeiboIOS::Get().mSinaWeibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        MOAISinaWeiboIOS::Get().mSinaWeibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
	
	[key release];
	[secret release];
	[redirectUri release];
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	_login
 @text	Log in sina weibo
 
 @out	nil
 */
int MOAISinaWeiboIOS::_login ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
    NSLog(@"log in sina weibo");
	
    [MOAISinaWeiboIOS::Get ().mSinaWeibo logIn];
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	_logout
 @text	Log out sina weibo
 
 @out	nil
 */
int MOAISinaWeiboIOS::_logout ( lua_State* L ) {
	
	MOAILuaState state ( L );
	
    NSLog(@"log out sina weibo");
	
    [MOAISinaWeiboIOS::Get ().mSinaWeibo logOut];
	
	return 0;
}

int MOAISinaWeiboIOS::_isAuthValid( lua_State* L) {
	MOAILuaState state ( L );
	
	lua_pushboolean( L, [MOAISinaWeiboIOS::Get ().mSinaWeibo isAuthValid] );
	
	return 1;
}

int MOAISinaWeiboIOS::_isAuthExpired( lua_State *L ) {
	MOAILuaState state( L );
	lua_pushboolean( L, [MOAISinaWeiboIOS::Get().mSinaWeibo isAuthorizeExpired] );
	return 1;
}

int MOAISinaWeiboIOS::_getUserId(lua_State *L){
	MOAILuaState state( L );
	cc8* userId = [ MOAISinaWeiboIOS::Get ().mSinaWeibo.userID UTF8String ];
	lua_pushstring( L, userId );
	return 1;
}

int MOAISinaWeiboIOS::_postText(lua_State *L){
	MOAILuaState state( L );
	
	cc8* text = lua_tostring ( state, 1 );
	NSString* textStr = [[ NSString alloc ] initWithUTF8String:text ];

	[MOAISinaWeiboIOS::Get().mSinaWeibo requestWithURL:@"statuses/update.json"
					   params:[NSMutableDictionary dictionaryWithObjectsAndKeys:textStr, @"status", nil]
					   httpMethod:@"POST"
					   delegate:MOAISinaWeiboIOS::Get().mWeiboRequestDelegate];
	
	[textStr release];
	return 0;
}

int MOAISinaWeiboIOS::_postTextWithImg(lua_State *L){
	MOAILuaState state( L );
	
	cc8* text = lua_tostring( state, 1 );
	cc8* imgFileLoc = lua_tostring( state, 2 );
	NSString* textStr = [[ NSString alloc ] initWithUTF8String:text ];
	NSString* imgLoc = [[ NSString alloc ] initWithUTF8String:imgFileLoc ];
	UIImage *img = [UIImage imageWithContentsOfFile:imgLoc];
	
	if ( img != NULL) //USFileSys::CheckFileExists ( imgFileLoc )) {
	{
		[MOAISinaWeiboIOS::Get().mSinaWeibo requestWithURL:@"statuses/upload.json"
					   params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
							   textStr, @"status",
							   [UIImage imageWithContentsOfFile:imgLoc], @"pic", nil]
								httpMethod:@"POST"
								delegate:MOAISinaWeiboIOS::Get().mWeiboRequestDelegate];
	}
	else
	{
		NSLog(@"File %@ doesn't exist.", imgLoc);
	}
	
	[textStr release];
	return 0;
}

//================================================================//
// MOAISinaWeiboIOS
//================================================================//

//----------------------------------------------------------------//
MOAISinaWeiboIOS::MOAISinaWeiboIOS () {
	
	RTTI_SINGLE ( MOAILuaObject )
	RTTI_SINGLE ( MOAIGlobalEventSource )
	
	mWeiboDelegate = [[ MOAISinaWeiboIOSDelegate alloc ] init];
	mWeiboRequestDelegate = [[ MOAISinaWeiboRequestIOSDelegate alloc ] init ];
}

//----------------------------------------------------------------//
MOAISinaWeiboIOS::~MOAISinaWeiboIOS () {
	[mWeiboDelegate release];
	[mWeiboRequestDelegate release];
	[mSinaWeibo release];
}

void MOAISinaWeiboIOS::RemoveAuthData()
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

void MOAISinaWeiboIOS::StoreAuthData()
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              mSinaWeibo.accessToken, @"AccessTokenKey",
                              mSinaWeibo.expirationDate, @"ExpirationDateKey",
                              mSinaWeibo.userID, @"UserIDKey",
                              mSinaWeibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

void MOAISinaWeiboIOS::HandleOpenURL ( NSURL* url ) {
	
	[ mSinaWeibo handleOpenURL:url ];
}

//----------------------------------------------------------------//
void MOAISinaWeiboIOS::RegisterLuaClass ( MOAILuaState& state ) {
	// also register constants:
	// state.SetField ( -1, "FOO_CONST", ( u32 )FOO_CONST );

	// here are the class methods:
	luaL_Reg regTable [] = {
		{ "init",		_init },
		{ "login",      _login },
		{ "logout",     _logout },
		{ "isAuthValid", _isAuthValid },
		{ "isAuthExpired", _isAuthExpired },
		{ "getUserId", _getUserId },
		{ "postText", _postText },
		{ "postTextWithImg", _postTextWithImg },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

#endif
