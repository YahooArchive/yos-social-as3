/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.utils
{
	import com.yahoo.oauth.OAuthToken;
	
	/**
	 * IYahooSessionStore provides a basic interface for storing OAuth tokens using the 
	 * <code>com.yahoo.oauth</code> package and <code>YahooSession</code> object. Your implementation 
	 * of this interface allows you to write code to store tokens in anything from local shared objects, 
	 * in the cloud or local files in Adobe AIR.
	 * 
	 * <p>
	 * A basic implementation of this is found in YahooSessionStore, which uses a configurable local
	 * shared object to store tokens.
	 * </p>
	 *  
	 * @author zachg@yahoo-inc.com
	 * @see YahooSession
	 * @see YahooSessionStore
	 * @see OAuthToken
	 */	
	public interface IYahooSessionStore
	{
		/**
		 * Interface method to set an OAuthToken containing an access token key and secret.
		 * @param token
		 * @return 
		 * @see OAuthToken
		 */		
		function setAccessToken(token:OAuthToken):Boolean;
		
		/**
		 * Interface method to get an OAuthToken containing an access token key and secret.
		 * @return 
		 * 
		 */		
		function getAccessToken():OAuthToken;
		
		/**
		 * Interface method to clear the stored access token.
		 * @return 
		 * 
		 */		
		function clearAccessToken():Boolean;
		
		/**
		 * Interface method to set an OAuthToken containing an request token key and secret.
		 * @param token
		 * @return 
		 * 
		 */		
		function setRequestToken(token:OAuthToken):Boolean;
		
		/**
		 * Interface method to get an OAuthToken containing an request token key and secret.
		 * @return 
		 * 
		 */		
		function getRequestToken():OAuthToken;
		
		/**
		 * Interface method to clear the stored request token.
		 * @return 
		 * 
		 */		
		function clearRequestToken():Boolean;
		
		/**
		 * Interface method to clear all session tokens from the store. 
		 * @return 
		 * 
		 */		
		function clearSessionToken():void;
	}
}