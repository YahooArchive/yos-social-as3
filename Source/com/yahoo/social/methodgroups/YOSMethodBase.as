/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.adobe.serialization.json.JSON;
	import com.yahoo.oauth.OAuthConnection;
	import com.yahoo.oauth.OAuthConsumer;
	import com.yahoo.oauth.OAuthRequest;
	import com.yahoo.oauth.OAuthToken;
	import com.yahoo.social.YahooUser;
	
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestHeader;
	
	/**
	 * Dispatched when a request fails due to a security error.
	 */	
	[Event(name="securityError", type="SecurityErrorEvent")]
	
	/**
	 * The base class for all YOS API wrappers. 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 */	
	public class YOSMethodBase extends EventDispatcher
	{
	
	//--------------------------------------
	//  Constants (namespaces & host names)
	//--------------------------------------	
		
		/**
		 * The hostname for Yahoo Social APIs.
		 */
		protected static const SOCIAL_WS_HOSTNAME:String = "social.yahooapis.com";

		/**
		 * The hostname for the Yahoo Application Platform data store. 
		 */
		protected static const APPSTORE_WS_HOSTNAME:String = "appstore.apps.yahooapis.com";
		
		/**
		 * The hostname for the YQL API. 
		 */
		protected static const YQL_HOSTNAME:String = "query.yahooapis.com";
		
		/**
		 * The hostname for the Yahoo login service (OAuth) API. 
		 */		
		protected static var OAUTH_HOSTNAME:String = "api.login.yahoo.com";
		
		/**
		 * The name of the OAuth realm for Yahoo! web-services. 
		 */		
		protected static var OAUTH_REALM:String = "yahooapis.com";
		
		/**
		 * The Yahoo namespace used in XML responses.
		 * @private 
		 */		
		private static const YAHOOAPIS_NAMESPACE:Namespace = new Namespace("http://yahooapis.com/v1/base.rng");
		
	//--------------------------------------
	//  Protected variables
	//--------------------------------------	
		
		/**
		 * The YahooUser to reference in all requests. 
		 */		
		protected var $user:YahooUser;
		
		/**
		 * The response format to apply to all requests. 
		 */		
		protected var $format:String = "json";
		
		/**
		 * The version of the API.  
		 */		
		protected var $version:String = "v1";
		
		/**
		 * The hostname to be used in constructing URLs for all requests. 
		 */		
		protected var $hostname:String;

		/**
		 * An OAuthConsumer object containing consumer key and secret values.
		 */		
		protected var $consumer:OAuthConsumer;
		
		/**
		 * An OAuthToken object containing access token key and secret values. 
		 */		
		protected var $token:OAuthToken;
		
		/**
		 * The name of the OAuth request type used for all requests in this class. 
		 */		
		protected var $oauthRequestType:String;
		
		/**
		 * Determines if the request parameters in the signature base string 
		 * should be encoded using <code>encodeURIComponent</code> when signing the request.
		 */		
		protected var $useExplicitEncoding:Boolean=true;
	
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * Constructor
		 * 
		 * Creates a new YOSMethodBase object. This is the base class for all YOS API wrappers. 
		 * @param user
		 * 
		 */		
		public function YOSMethodBase(user:YahooUser=null)
		{
			super();
			this.$user = user;
			
			this.$oauthRequestType = OAuthRequest.OAUTH_REQUEST_TYPE_OBJECT;
		}
		
		/**
		 * An OAuthConsumer object containing consumer key and secret values.
		 * 
		 * If you wish to make a 2-legged OAuth request, do not pass a YahooUser in the 
		 * constructor and set this value with your consumer credentials. 
		 * @see OAuthConsumer
		 */		
		public function get consumer():OAuthConsumer
		{
			if(this.$user) {
				this.consumer = this.$user.session.getConsumer();
			}
			
			return $consumer;
		}
		
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set consumer(value:OAuthConsumer):void
		{
			this.$consumer = value;
		}
		
		/**
		 * An OAuthToken object containing access token key and secret values
		 * 
		 * This value is only used if a user is not defined when signing a request with OAuth. 
		 * 
		 * If you wish to make a 3-legged OAuth request, do not pass a YahooUser in the 
		 * constructor and set this value with your access token credentials. 
		 * @see OAuthToken
		 */		
		public function get token():OAuthToken
		{
			if(this.$user) {
				this.token = this.$user.session.getAccessToken();
			}
			
			return $token;
		}
		
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set token(value:OAuthToken):void
		{
			this.$token = value;
		}
		
		/**
		 * The user referenced in all data requests.
		 * @return 
		 * 
		 */		
		public function get user():YahooUser
		{
			return this.$user;
		}
		
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set user(value:YahooUser):void
		{
			this.$user = value;
		}
	
	//--------------------------------------
	//  Protected Methods
	//--------------------------------------	
	
		/**
		 * Returns an object containing the required or default request parameters. 
		 * @return 
		 * 
		 */		
		protected function getDefaultArguments():Object
		{
			var args:Object = new Object();
			args.format = this.$format;
			
			if(this.$user) { // if there is a user, apply the language and region to the request.
				args.lang = this.$user.lang;
				args.region = this.$user.region;
			}
			
			return args;
		}
		
		/**
		 * A simple wrapper of the JSON::decode function.
		 * @param s
		 * @return 
		 * @see http://code.google.com/p/as3corelib/
		 */		
		protected function decodeJSON(s:String):*
		{
			return JSON.decode(s);	
		}
		
		/**
		 * A simple wrapper of the JSON::encode function.
		 * @param o
		 * @return 
		 * @see http://code.google.com/p/as3corelib/
		 */		
		protected function encodeJSON(o:Object):String
		{
			return JSON.encode(o);
		}
		
		/**
		 * Signs the request with OAuth credentials then sends the request to the web-service with the supplied callbacks.
		 * @param httpMethod
		 * @param url
		 * @param callback
		 * @param args
		 * 
		 */		
		protected function sendRequest(httpMethod:String, url:String, callback:Object, args:Object=null, headers:Array=null):void
		{
			if(!headers) headers = [];
			// headers.push( new URLRequestHeader("Accept","application/json") );
			
			var connection:OAuthConnection = OAuthConnection.fromConsumerAndToken(this.consumer, this.token);
			connection.realm = OAUTH_REALM;
			connection.requestType = $oauthRequestType;
			connection.useExplicitEncoding = $useExplicitEncoding;
			connection.asyncRequestSigned(httpMethod, url, callback, args, headers);
		}
		
		/**
		 * Dispatches a <code>SECURITY_ERROR</code> event.
		 * @param response
		 */
		protected function handleSecurityError(response:Object):void
		{
			var event:SecurityErrorEvent = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
			event.text = response.responseText;
			
			this.dispatchEvent(event);
		}
		
		/**
		 * Returns true if the status code is 200. (AIR-Only)
		 * 
		 * Will also return true if the code is 0 to bypass the browser not providing an http status code. 
		 *  
		 * @param status
		 * @return 
		 * 
		 */		
		protected function getResponseStatusOk(status:int):Boolean
		{
			return (status == 200 || status == 0);
		}
	}
}