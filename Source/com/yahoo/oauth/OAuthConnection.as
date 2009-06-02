/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	import com.yahoo.net.Connection;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	/**
	 * A utility class that wraps the entire OAuth signing mechanism over the Connection manager. 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 */	
	public class OAuthConnection
	{
		/**
		 * Returns a new OAuthConnection object for the specified OAuth consumer and token. 
		 * @param consumer		A consumer containing a key and secret used to identify an application making a request to the service provider.
		 * @param token			An optional token containing a key and secret, used for signing three-legged requests.
		 * @return 				A new OAuthConnection object.
		 * 
		 */		
		public static function fromConsumerAndToken(consumer:OAuthConsumer, token:OAuthToken=null):OAuthConnection
		{
			var connection:OAuthConnection = new OAuthConnection();
			connection.consumer = consumer;
			connection.token = token;
			
			return connection;
		}
		
		private var $signatureMethod:IOAuthSignatureMethod;
		
		/**
		 * @private
		 */		
		private var $consumer:OAuthConsumer;
		
		/**
		 * @private
		 */		
		private var $token:OAuthToken;
		
		/**
		 * @private
		 */		
		private var $requestType:String;
		
		/**
		 * @private
		 */		
		private var $realm:String;
		
		/**
		 * Determines if the request parameters in the signature base string should be encoded using <code>encodeURIComponent</code>.
		 */		
		public var useExplicitEncoding:Boolean = true;
		
		/**
		 * Creates a new OAuthConnection object.
		 * 
		 */		
		public function OAuthConnection()
		{
			// set the default request type
			$requestType = OAuthRequest.OAUTH_REQUEST_TYPE_OBJECT;
			$signatureMethod = new OAuthSignatureMethod_HMAC_SHA1();
		}
		
		/**
		 * The OAuth consumer.
		 * @return 
		 * 
		 */		
		public function get consumer():OAuthConsumer
		{
			return $consumer;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set consumer(value:OAuthConsumer):void
		{
			$consumer = value;
		}
		
		/**
		 * The optional OAuth token.
		 * @return 
		 * 
		 */		
		public function get token():OAuthToken
		{
			return $token;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set token(value:OAuthToken):void
		{
			$token = value;
		}
		
		/**
		 * The OAuth request type. 
		 * @return 
		 * 
		 */		
		public function get requestType():String
		{
			return $requestType;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set requestType(value:String):void
		{
			$requestType = value;
		}
		
		/**
		 * The service provider realm using in an "Authorization: OAuth..." header.
		 * @return 
		 * 
		 */		
		public function get realm():String
		{
			return $realm;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set realm(value:String):void
		{
			$realm = value;
		}
		
		/**
		 * The signature method to be used when signing the request.
		 * @return 
		 * 
		 */		
		public function get signatureMethod():IOAuthSignatureMethod
		{
			return this.$signatureMethod;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set signatureMethod(value:IOAuthSignatureMethod):void
		{
			this.$signatureMethod = value;
		}
		
		/**
		 * Signs and sends a HTTP request using the OAuth consumer and token and the provided arguments.  
		 * 
		 * @param httpMethod 	The URLRequestMethod to use in the request.
		 * @param url 			The URL to call in the URLRequest
		 * @param callback 		An Object containing <code>success</code>, <code>failure</code> and <code>security</code> callback functions.
		 * @param args 			An Object, String, URLVariables or ByteArray to include in the URLRequest.data object.
		 * @param headers		An array of valid URLRequestHeader objects to be set in the URLRequest.requestHeaders property.
		 * 
		 * @return 				The URLRequest object generated.
		 * @see com.yahoo.net.Connection
		 */		
		public function asyncRequestSigned(httpMethod:String, url:String, callback:Object, args:Object=null, headers:Array=null):URLRequest
		{
			// build the signed request
			var signed:* = this.signRequest(httpMethod, url, args);
			
			if($requestType == OAuthRequest.OAUTH_REQUEST_TYPE_OBJECT) 
			{
				if(httpMethod == URLRequestMethod.GET) {
					// build the signed url, this helps a lot to avoid any auto-encoding 
					// that flash does when you use URLRequest.data with GET.
					url = url+"?"+OAuthUtil.oauth_http_build_query(signed);
					args = null;
				}else{
					args = signed;
				}
			} 
			else if($requestType == OAuthRequest.OAUTH_REQUEST_TYPE_URL_STRING) 
			{
				url = signed;
				args = null; // the URL contains all of our arguments now...
			}
			else if($requestType == OAuthRequest.OAUTH_REQUEST_TYPE_POST || $requestType == OAuthRequest.OAUTH_REQUEST_TYPE_URL_VARIABLES) 
			{
				args = signed;
			}
			else if($requestType == OAuthRequest.OAUTH_REQUEST_TYPE_HEADER) 
			{
				if(!headers) headers = [];
				headers.push(signed);
			} 
			
			return this.asyncRequest(httpMethod, url, callback, args, headers);
		}
		
		/**
		 * Sends a new HTTP request directly.
		 * 
		 * @param httpMethod 	The URLRequestMethod to use in the request.
		 * @param url 			The URL to call in the URLRequest
		 * @param callback 		An Object containing <code>success</code>, <code>failure</code> and <code>security</code> callback functions.
		 * @param args 			An Object, String, URLVariables or ByteArray to include in the URLRequest.data object.
		 * @param headers		An Array of valid URLRequestHeader objects to be set in the URLRequest.requestHeaders property.
		 * 
		 * @return 				The URLRequest object generated.
		 * @see com.yahoo.net.Connection
		 */		
		public function asyncRequest(httpMethod:String, url:String, callback:Object, args:Object=null, headers:Array=null):URLRequest
		{
			return Connection.asyncRequest(httpMethod, url, callback, args, headers);
		}
		
		/**
		 * Signs a request using the provided method, URL and arguments.
		 * @param httpMethod 	The URLRequestMethod to use in the request.
		 * @param url 			The URL to request.
		 * @param args 			An object containing the parameters to be signed.
		 * @return 				An object whose type is determined by the value of <code>requestType</code>.
		 * 
		 */		
		public function signRequest(httpMethod:String, url:String, args:Object=null):*
		{
			var request:OAuthRequest = new OAuthRequest(httpMethod, url, args, this.consumer, this.token);
			request.useExplicitEncoding = this.useExplicitEncoding;
			
			// sign the request, returning an Object containing the key=value pairs.
			var oauth_args:* = request.buildRequest(this.signatureMethod, this.requestType, this.realm);
			
			return oauth_args;
		}
	}
}