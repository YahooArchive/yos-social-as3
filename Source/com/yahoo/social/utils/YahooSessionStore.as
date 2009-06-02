/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.utils
{
	import com.yahoo.crypto.util.Base64;
	import com.yahoo.oauth.OAuthToken;
	import com.yahoo.social.methodgroups.AuthorizationRequest;
	
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.ByteArray;
	
	/**
	 * An implementation of IYahooSessionStore that uses a SharedObject to keep OAuth
	 * request and access tokens cached on the users machine for later use.
	 * @author zachg
	 * 
	 * @example 
	 * <listing version="3.0">
	 *  YahooSession.YAP_APPID = "your-appid";
	 *  
	 *  var _session:YahooSession = new YahooSession(CONSUMER_KEY, CONSUMER_SECRET);
	 *  var _accessToken:OAuthToken = _session.sessionStore.getAccessToken();
	 *  
	 *  if( _accessToken ) {
	 *     // try to set the token
	 *     var hasSession:Boolean = _session.setAccessToken(_accessToken);
	 *     
	 *     if(hasSession == false) {
	 *        _session.auth.addEventListener(YahooResultEvent.GET_ACCESS_TOKEN_SUCCESS, handleGetAccessToken);
	 *        _session.auth.getAccessToken(_accessToken);
	 *     } else {
	 *        doStuff();
	 *     }
	 *  } else {
	 *     // start request token and user authorization flow.
	 *  }
	 * 
	 * 
	 *  function handleGetAccessToken(event:YahooResultEvent):void
	 *  {
	 *     _accessToken = event.data as OAuthToken;
	 *     
	 *     _session.setAccessToken(_accessToken);
	 *     _session.sessionStore.setAccessToken(_accessToken);
	 * 
	 *     doStuff();
	 *  }
	 *  
	 *  function doStuff():void 
	 *  {
	 *     // load profile, connections or updates
	 *  }
	 * </listing>
	 */	
	public class YahooSessionStore extends Object implements IYahooSessionStore
	{
		/**
		 *  @private 
		 *  Storage for the sharedObject property.
		 */		
		private var $sharedObject:SharedObject;
		
		/**
		 *  @private
		 *  Storage for the shareData property.
		 */
		private var $shareData:Boolean = false;
		
		/**
		 * @private
		 * Storage for the sharedObjectPath property
		 */	
		private var $sharedObjectPath:String = "YahooSessionData";
    	
		/**
		 * Class constructor
		 * Creates 
		 */    	
		public function YahooSessionStore()
		{
			super();
			
			initSharedObject();
		}
		
		/**
		 * Determines Whether to share the auto-complete data with other applications
		 * or keep it private to this application.
		 * 
		 * <p>Please note that setting this to <code>true</code> will all applications in the domain
	     * to access any information in the Shared Object. For instance, if a third party
	     * application hosted on the same domain knows the name of the Shared Object 
	     * (which is by default "YahooSessionData"), they may be able to read and write to it.</p>
	     * 
	     * <p>If you choose to set this to <code>true</code>, you should consider setting the 
	     * <code>sharedObjectPath</code> to a value only your applications are aware of,
	     * especially a password-like value or some value returned from a server.
	     * In this way, you make it difficult or impossible for a third party 
	     * to access this information.</p>
	     * 
	     * @see #sharedObjectPath
	     * @see flash.net.SharedObject
	     * @default false
		 * @return 
		 * 
		 */		
		public function get shareData():Boolean
		{
			return $shareData;
		}
		
		/**
		 *  @private
		 */
		public function set shareData(value:Boolean):void
		{
			$shareData = value;
			initSharedObject();
		}
		
		/**
		 * The name of the SharedObject in which to store session token entries.
		 * @return 
		 * 
		 */		
		public function get sharedObjectPath():String
		{
			return $sharedObjectPath;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set sharedObjectPath(value:String):void
		{
			$sharedObjectPath = value;
			initSharedObject();
		}
		
		/**
		 * Sets the accessToken value of the SharedObject data and flushes the data.
		 * @param session
		 * @return 
		 * 
		 */		
		public function setAccessToken(token:OAuthToken):Boolean
		{
			$sharedObject.data.accessToken = (token && !token.empty) ? encodeToken(token) : null;
			
			return flush();
		}
		
		/**
		 * Reads the access token data and returns an OAuthToken object.
		 * @return 
		 * 
		 */		
		public function getAccessToken():OAuthToken
		{
			var token:OAuthToken = null;
			
			// if the accessToken object is present in the cache
			// decode it and convert back into an OAuthToken
			if($sharedObject.data.accessToken)
			{
				var data:Object = decodeToken($sharedObject.data.accessToken);
				token = (data) ? AuthorizationRequest.toAccessToken(data) : null;
			}
			
			return token;
		}
		
		/**
		 * Removes the access token from the SharedObject.
		 * @return 
		 * 
		 */		
		public function clearAccessToken():Boolean
		{
			$sharedObject.data.accessToken = null;
			
			return flush();
		}
		
		/**
		 * 
		 * @param session
		 * @return 
		 * 
		 */		
		public function setRequestToken(token:OAuthToken):Boolean
		{
			$sharedObject.data.requestToken = (token && !token.empty) ? encodeToken(token) : null;
			
			return flush();
		}
		
		/**
		 * Reads the request token data and returns an OAuthToken object.
		 * @return 
		 * 
		 */		
		public function getRequestToken():OAuthToken
		{
			var token:OAuthToken = null;
			
			// if the requestToken object is present in the cache
			// decode it and convert back into an OAuthToken
			if($sharedObject.data.requestToken)
			{
				var data:Object = this.decodeToken($sharedObject.data.requestToken);
				token = (data) ? AuthorizationRequest.toRequestToken(data) : null;
			}
			
			return token;
		}
		
		/**
		 * Removes the request token from the SharedObject.
		 * @return 
		 * 
		 */		
		public function clearRequestToken():Boolean
		{
			$sharedObject.data.requestToken = null;
			
			return flush();
		}
		
		/**
		 * Removes the request and access tokens from the shared object by
		 * purging all of the data and deleting the shared object from the disk.
		 * @return 
		 * 
		 */		
		public function clearSessionToken():void
		{
			$sharedObject.clear();
		}
		
		/**
		 * Creates a Base64 encoded string representing the token provided.
		 * 
		 * @param token
		 * @return 
		 * 
		 */		
		protected function encodeToken(token:OAuthToken):String
		{
			// write the token into a byte array, then encode the bytes to base64
			// this method ensures that dynamic properties of the token are included
			var bytes:ByteArray = new ByteArray()
			bytes.writeObject(token);
			bytes.position=0;
			
			return Base64.encodeByteArray(bytes);
		}
		
		/**
		 * Decodes a Base64 encoded string returning a native object containing
		 * the OAuth token variables.
		 * 
		 * @param str
		 * @return 
		 * 
		 */		
		protected function decodeToken(str:String):Object
		{
			// push the base64 decoded value into a byte array
			// then return the object
			var bytes:ByteArray = Base64.decodeToByteArray(str);
			bytes.position=0;
			
			return bytes.readObject();
		}
		
		/**
		 * Flushes the shared object.
		 * @return Returns true if the flush was successfully completed. 
		 * 
		 */		
		protected function flush():Boolean
		{
			// confirm the shared object was sucessfully flushed.
			return ($sharedObject && $sharedObject.flush()==SharedObjectFlushStatus.FLUSHED);
		}
		
		/**
		 *  
		 * @private
		 */		
		private function initSharedObject():void
		{
			$sharedObject = SharedObject.getLocal(sharedObjectPath, $shareData?"/":null);
		}
		
	}
}