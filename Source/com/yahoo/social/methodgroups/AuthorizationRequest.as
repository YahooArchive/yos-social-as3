/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.yahoo.net.Connection;
	import com.yahoo.oauth.OAuthConsumer;
	import com.yahoo.oauth.OAuthRequest;
	import com.yahoo.oauth.OAuthToken;
	import com.yahoo.social.YahooSession;
	import com.yahoo.social.events.YahooResultEvent;
	import com.yahoo.social.utils.YahooURL;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	
	/**
	* Dispatched when the getRequestToken request executes successfully.
	*/	
	[Event(name="getRequestTokenSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getRequestToken request encounters an error.
	*/	
	[Event(name="getRequestTokenFailure", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getAccessToken request executes successfully.
	*/	
	[Event(name="getAccessTokenSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getAccessToken request encounters an error.
	*/	
	[Event(name="getAccessTokenFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper over the OAuth authorization APIs for Yahoo!.
	 * 
	 * Allows for the full authorization flow to occur inside an application. (Most useful for AIR applications)
	 * 
	 * @author zachg
	 * @see http://developer.yahoo.com/oauth
	 * @see http://developer.yahoo.com/oauth/guide/
	 * 
	 * @example
	 * <listing version="3.0">
	 *  var _session:YahooSession = new YahooSession('consumerKey', 'consumerSecret','appId');
	 *  var _user:YahooUser;
	 * 
	 *  var _token:OAuthToken;
	 *  
	 *  var _callbackUrl = "http://myapp.com/";
	 *  
	 *  _session.auth.addEventListener(YahooResultEvent.GET_REQUEST_TOKEN_SUCCESS, handleRequestTokenSuccess);
	 *  _session.auth.getRequestToken(_callbackUrl);
	 *  
	 *  function handleRequestTokenSuccess(event:YahooResultEvent):void
	 *  {
	 *    // save the request token and use it to send the user to the authorize page
	 *    // then after the user has finished, use it again to request an access token.
	 * 
	 *    _token = event.data as OAuthToken; 
	 *    _session.auth.sendToAuthorization(_token);
	 *  }
	 * 
	 *  // call userAuthFinish after the user has indicated that they have finished the authorization process
	 * 
	 *  function userAuthFinish():void
	 *  {
	 *    // fetch the oauth_verifier. this string may be typed 
	 *    // into your application by the user or returned via the callback url.
	 *    var verifier:String = "abc123";
	 * 
	 *    // reuse the request token to request an access token.
	 * 
	 *    _session.auth.addEventListener(YahooResultEvent.GET_ACCESS_TOKEN_SUCCESS, handleAccessTokenSuccess);
	 *    _session.auth.getAccessToken(_token, verifier);
	 *  }
	 *  
	 *  function handleAccessTokenSuccess(event:YahooResultEvent):void
	 *  {
	 *    // save the access token and create a new session.
	 *    _token = event.data as OAuthToken;
	 *    
	 *    // set the sessions token.
	 *    _session.setAccessToken(_token);
	 * 
	 *    _user = _session.getSessionedUser();
	 *  }
	 * 
	 * </listing>
	 */	
	public class AuthorizationRequest extends YOSMethodBase
	{
		/**
		 * The OAuth Language Preference. (xoauth_lang_pref, OAuth 1.0)
		 * 
		 * Set to null if your service provider does not not accept this argument.
		 */		
		public var oAuthLang:String = "en_US";
		
		/**
		 * Out-of-band
		 * 
		 * OAuth 1.0 'Rev A' parameter indicating a consumer cannot recieve callbacks. 
		 */		
		protected static const OUT_OF_BAND:String = "oob";
		
		/**
		 * Creates a new AuthenticationRequest object.
		 * 
		 */		
		public function AuthorizationRequest()
		{
			super(null);
			
			this.$oauthRequestType = OAuthRequest.OAUTH_REQUEST_TYPE_POST;
			this.$hostname = YOSMethodBase.OAUTH_HOSTNAME;
			this.$version = "v2";
		}
		
		/**
		 * Sends a request to fetch a request token.
		 * @param callbackUrl		An optional callback url used after the user has authorized the application.
		 */		
		public function getRequestToken(callbackUrl:String=null):void
		{	
			var url:YahooURL = new YahooURL("https", this.$hostname);
			url.rawResource("oauth");
			url.rawResource(this.$version);
			url.rawResource("get_request_token");
			
			var httpMethod:String = URLRequestMethod.POST;
			
			var args:Object = new Object();
			
			// adding oauth_callback per OAuth Core 1.0 Rev A 
			args.oauth_callback = (callbackUrl) ? callbackUrl : OUT_OF_BAND;
			
			if(oAuthLang) {
				args.xoauth_lang_pref = this.oAuthLang;
			}
			
			var callback:Object = new Object();
			callback.success = handleRequestTokenSuccess;
			callback.failure = handleRequestTokenFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(httpMethod, url.toString(), callback, args);
		}
		
		/**
		 * Generates an authorization url and navigates the browser to the page.
		 * @param token			A request token object.
		 * @param window		The window of the browser to open the URL in.
		 */		
		public function sendToAuthorization(token:OAuthToken, window:String="_blank"):void
		{
			flash.net.navigateToURL(new URLRequest(this.createAuthorizationUrl(token)), window);
		}
		
		/**
		 * Returns a URL to be used to send a user to the OAuth authorization page.
		 * @param requestToken		An OAuthToken object containing a token key and secret.
		 * @return 
		 * 
		 */		
		public function createAuthorizationUrl(requestToken:OAuthToken):String
		{
			if(!requestToken.key) {
				throw new Error("Value of OAuth request token key must not be null.");
			}
			
			var url:YahooURL = new YahooURL("https", this.$hostname);
			url.rawResource("oauth");
			url.rawResource(this.$version);
			url.rawResource("request_auth");
			
			var args:Object = new Object();
			args.oauth_token = requestToken.key;
			
			url.queryParameters = args;
			
			return url.toString();
		}
		
		/**
		 * Sends a request to fetch an access token.
		 * @param token				A request token to be authorized.
		 * @param verifier 			The oauth_verifier returned to the application by the service provider.
		 */		
		public function getAccessToken(token:OAuthToken, verifier:String=null):void
		{
			this.token = token;
			
			var url:YahooURL = new YahooURL("https", this.$hostname);
			url.rawResource("oauth");
			url.rawResource(this.$version);
			url.rawResource("get_token");
			
			var httpMethod:String = URLRequestMethod.POST;
			
			var args:Object = new Object();
			
			if(verifier) {
				// adding oauth_verifier per OAuth Core 1.0 Rev A 
				args.oauth_verifier = verifier;
			}
			
			if(token.sessionHandle) {
				args.oauth_session_handle = token.sessionHandle;
			}
			
			var callback:Object = new Object();
			callback.success = handleAccessTokenSuccess;
			callback.failure = handleAccessTokenFailure;
			callback.security = handleSecurityError;
			
			var headers:Array = [new URLRequestHeader("Content-Type","application/x-www-form-urlencoded")];
			
			this.sendRequest(httpMethod, url.toString(), callback, args, headers);
		}
		
		/////////////////////////////
		// Private callback methods
		/////////////////////////////
		
		/**
		 * Handles the request token success event.
		 * @private
		 * @param response
		 * 
		 */		
		private function handleRequestTokenSuccess(response:Object):void
		{
			if(!this.getResponseStatusOk(response.status)) {
				handleRequestTokenFailure(response);
			} else {
				var token:OAuthToken = this.parseRequestToken(response.responseText);
				var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_REQUEST_TOKEN_SUCCESS, token);
				
				this.dispatchEvent(event);
			}
		}
		
		/**
		 * Handles the request token failure event.
		 * @private
		 * @param response
		 * 
		 */		
		private function handleRequestTokenFailure(response:Object):void
		{
			this.dispatchEvent(new YahooResultEvent(YahooResultEvent.GET_REQUEST_TOKEN_FAILURE, response));
		}
		
		/**
		 * Handles the access token success event.
		 * @private
		 * @param response
		 * 
		 */		
		private function handleAccessTokenSuccess(response:Object):void
		{
			if(!this.getResponseStatusOk(response.status))  {
				handleRequestTokenFailure(response);
			} else {
				var token:OAuthToken = parseAccessToken(response.responseText);
				
				if(token) {
					var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_ACCESS_TOKEN_SUCCESS, token);
					this.dispatchEvent(event);
				}
			}
		}
		
		/**
		 * Handles the access token failure event.
		 * @private
		 * @param response
		 * 
		 */		
		private function handleAccessTokenFailure(response:Object):void
		{
			this.dispatchEvent(new YahooResultEvent(YahooResultEvent.GET_ACCESS_TOKEN_FAILURE, response));
		}
		
		/////////////////////////////
		// Protected methods
		/////////////////////////////
		
		/**
		 * Parses an OAuth <code>get_token</code> response into a valid OAuthToken object.
		 * @private
		 * @param responseText	The responseText from the request.
		 * @return 
		 * 
		 */		
		protected function parseAccessToken(responseText:String):OAuthToken
		{
			var data:Object = Connection.parse_query(responseText);
			
			var token:OAuthToken = new OAuthToken();
			token.key = decodeURIComponent(data["oauth_token"]); // decode the token
			token.secret = data["oauth_token_secret"];
			
			// extensions
			token.guid = data["xoauth_yahoo_guid"];
			token.sessionHandle = data["oauth_session_handle"];
			token.consumer = this.$consumer.key;
				
			if(data["oauth_expires_in"]) {
				var now:Number = new Date().getTime();
				var expires:Number = (data["oauth_expires_in"]*1000);
				
        		token.tokenExpires = now+expires;
			}
			
			return token;
		}
		
		/**
		 * Parses an OAuth <code>get_request_token</code> response into a new OAuthToken object.
		 * @private
		 * @param responseText	The responseText from the request.
		 * @return 
		 * 
		 */		
		protected function parseRequestToken(responseText:String):OAuthToken
		{
			var data:Object = Connection.parse_query(responseText);
			
			var token:OAuthToken = new OAuthToken();
			token.key = data["oauth_token"];
			token.secret = data["oauth_token_secret"];
			
			// extensions
			token.requestAuthUrl = decodeURIComponent(data["xoauth_request_auth_url"]);
			token.callbackConfirmed = Boolean(data["oauth_callback_confirmed"]); // 1.0a Draft 3
			
			if(data["oauth_expires_in"]) {
				var now:Number = new Date().getTime();
				var expires:Number = (data["oauth_expires_in"]*1000);
				
        		token.tokenExpires = now+expires;	
			}
			
			return token;
		}
		
		/////////////////////////////
		// Public static functions
		/////////////////////////////
		
		/**
		 * Converts a native object containing request token values into a new OAuthToken object.
		 * 
		 * Most useful in AIR you are storing the request token in a File and 
		 * need to turn in back into an OAuthToken after reading the file contents.
		 * 
		 * @param data
		 * @return 
		 * 
		 */		
		public static function toRequestToken(data:Object):OAuthToken
		{
			var token:OAuthToken = new OAuthToken();
			token.key = data["key"];
			token.secret = data["secret"];
			
			// extensions
			token.requestAuthUrl = data["requestAuthUrl"];
			token.tokenExpires = data["tokenExpires"];
			token.callbackConfirmed = data["callbackConfirmed"];
			
			return token;
		}
		
		/**
		 * Converts a native object containing access token values into a new OAuthToken object.
		 * 
		 * Most useful in AIR you are storing the access token in a File and 
		 * need to turn the Object back into an OAuthToken after reading the file contents.
		 * 
		 * @param data
		 * @return 
		 * 
		 */		
		public static function toAccessToken(data:Object):OAuthToken
		{
			var token:OAuthToken = new OAuthToken();
			token.key = data["key"];
			token.secret = data["secret"];
			
			// extensions
			token.guid = data["guid"];
			token.consumer = data["consumer"];
			token.sessionHandle = data["sessionHandle"];
			token.tokenExpires = data["tokenExpires"];
			
			return token;
		}
		
		/**
		 * Checks if a token is about to expire (up to 30 seconds).
		 * 
		 * Returns true if expired.
		 * 
		 * @param token		An OAuthToken containing a token key, secret and a tokenExpires property.
		 * @param buffer	The total amount of seconds to pad the expires time with.
		 * @return 
		 * 
		 */		
		public static function checkExpires(token:OAuthToken, buffer:int=30):Boolean
		{
			var expired:Boolean=false;
			
			if(token.tokenExpires) {
				var now:Number = (new Date().getTime());
				expired = ((token.tokenExpires >= 0) && (token.tokenExpires-now) < buffer);
			}
			
			return expired;
		}
		
		/**
		 * Generates a new AuthorizationRequest object using the OAuth consumer credentials from a YahooSession instance.
		 * 
		 * @param session
		 * @return 
		 * 
		 */		
		public static function fromSession(session:YahooSession):AuthorizationRequest
		{
			var consumer:OAuthConsumer = session.getConsumer();
			
			if(consumer.empty) return null;
			
			var auth:AuthorizationRequest = new AuthorizationRequest();
			auth.consumer = consumer;
			
			return auth;
		}
	}	
}