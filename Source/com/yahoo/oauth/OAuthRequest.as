/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	
	/**
	 * The OAuthRequest is used to create a request and apply a signature.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://oauth.net/core/1.0
	 */
	public class OAuthRequest
	{
		/**
		 * A string which is used in <code>buildRequest</code> that the 
		 * returned data type should be a url encoded string.
		 */		
		public static const OAUTH_REQUEST_TYPE_URL_STRING:String = "OAUTH_REQUEST_TYPE_URL_STRING";
		
		/**
		 * A string which is used in <code>buildRequest</code> that the 
		 * returned data type should be an URLVariables object.
		 */		
		public static const OAUTH_REQUEST_TYPE_URL_VARIABLES:String = "OAUTH_REQUEST_TYPE_URL_VARIABLES";
		
		/**
		 * A string which is used in <code>buildRequest</code> that the 
		 * returned data type should be a string, usable as POST data. 
		 */		
		public static const OAUTH_REQUEST_TYPE_POST:String = "OAUTH_REQUEST_TYPE_POST";
		
		/**
		 * A string which is used in <code>buildRequest</code> that the 
		 * returned data type should be an URLRequestHeader type, containing 
		 * an OAuth Authorization header.
		 * 
		 * @see http://oauth.net/core/1.0#auth_header
		 */		
		public static const OAUTH_REQUEST_TYPE_HEADER:String = "OAUTH_REQUEST_TYPE_HEADER";
		
		/**
		 * A string which is used in <code>buildRequest</code> that the 
		 * returned data type should be an Object. 
		 */		
		public static const OAUTH_REQUEST_TYPE_OBJECT:String = "OAUTH_REQUEST_TYPE_OBJECT";
		
		/**
		 * @private 
		 */		
		private var $consumer:OAuthConsumer;
		
		/**
		 * @private 
		 */		
		private var $httpMethod:String;
		
		/**
		 * @private 
		 */		
		private var $requestURL:String;
		
		/**
		 * @private 
		 */		
		private var $requestParams:Object;
		
		/**
		 * @private 
		 */		
		private var $token:OAuthToken;
		
		/**
		 * Determines if the request parameters in the signature base string should be encoded using <code>encodeURIComponent</code>.
		 */		
		public var useExplicitEncoding:Boolean = true;
		
		
		/**
		 * Class constructor.
		 * 
		 * Creates a new OAuthRequest object.
		 * 
		 * @param httpMethod		The HTTP request method used to send the request. The value MUST be a member of URLRequestMethod 
		 * @param requestURL		The URL of the request, it must include the protocol, host, port (optional) and path. 
		 * @param requestParams		An optional object containing the key=value pairs to be used in the request.
		 * @param consumer			An optional OAuthConsumer object used to sign the request.
		 * @param token				An optional OAuthToken object used to sign the request.
		 * 
		 * @see flash.net.URLRequestMethod
		 * @see OAuthConsumer
		 * @see OAuthToken
		 * 
		 */		
		public function OAuthRequest(httpMethod:String, requestURL:String, requestParams:Object=null, 
									 consumer:OAuthConsumer=null, token:OAuthToken=null)
		{
			$httpMethod = httpMethod;
			$requestURL = requestURL;
			
			$requestParams = (requestParams != null) ? OAuthUtil.copyObject(requestParams) : {};
			
			$consumer = consumer;
			$token = token;
		}
		
	//-------------------------
	//	Public Properties
	//-------------------------
	
		/**
		 * The HTTP request method used to send the request. Value MUST be a member of URLRequestMethod
		 * @see flash.net.URLRequestMethod
		 */
		public function get httpMethod():String 
		{
			return $httpMethod;
		}

		/**
		 * @private
		 */
		public function set httpMethod(value:String):void 
		{
			if (value != $httpMethod)
			{
				$httpMethod = value;
			}
		}

		/**
		 * The URL of the resource.
		 * 
		 * The request URL MUST include scheme, authority, and path and must exclude the query string in 
		 * favor of the <code>requestParams</code> object.
		 *  
		 * @see http://oauth.net/core/1.0#request_urls
		 */
		public function get requestURL():String 
		{
			return $requestURL;
		}

		/**
		 * @private
		 */
		public function set requestURL(value:String):void 
		{
			if (value != $requestURL)
			{
				$requestURL = value;
			}
		}

		/**
		 * An object containing key=value pairs used in the request and signing. 
		 * 
		 * OAuth Protocol Parameter names and values are case sensitive. 
		 * 
		 * Each OAuth Protocol Parameters must not appear more than once per request, 
		 * are required unless otherwise noted. 
		 * 
		 * @see http://oauth.net/core/1.0#anchor7
		 */
		public function get requestParams():Object 
		{
			return $requestParams;
		}

		/**
		 * @private
		 */
		public function set requestParams(value:Object):void 
		{
			if (value != $requestParams)
			{
				$requestParams = value;
			}
		}

		/**
		 * The OAuth consumer.
		 * 
		 * @see OAuthConsumer
		 */
		public function get consumer():OAuthConsumer 
		{
			return $consumer;
		}

		/**
		 * @private
		 */
		public function set consumer(value:OAuthConsumer):void 
		{
			$consumer = value;
		}

		/**
		 * The OAuth access token.
		 * @see OAuthToken
		 */
		public function get token():OAuthToken 
		{
			return $token;
		}

		/**
		 * @private
		 */
		public function set token(value:OAuthToken):void 
		{
			$token = value;
		}
		
		/**
		 * An array of the valid request types used to build and sign a request. 
		 * @return 
		 * 
		 */		
		public function get validRequestTypes():Array
		{
			return [OAUTH_REQUEST_TYPE_URL_STRING,
					OAUTH_REQUEST_TYPE_URL_VARIABLES,
					OAUTH_REQUEST_TYPE_POST,
					OAUTH_REQUEST_TYPE_HEADER,
					OAUTH_REQUEST_TYPE_OBJECT];
		}
		
		/**
		 * Returns all non-OAuth parameters. 
		 * @return 
		 * 
		 */		
		public function getNonOAuthParams():Object
		{
			var params:Object = {};
			
			for(var key:String in $requestParams)
			{
				if(key.indexOf("oauth_") == -1)
					params[key] = $requestParams[key];
			}
			
			return params;
		}
		
		/**
		 * Returns all OAuth parameters. 
		 * @return 
		 * 
		 */		
		public function getOAuthParams():Object
		{
			var params:Object = {};
			
			for(var key:String in $requestParams)
			{
				if(key.indexOf("oauth_") == 0)
					params[key] = $requestParams[key];
			}
			
			return params;
		}
		
	//-------------------------
	//	Public Functions
	//-------------------------
	
		/**
		 * Builds a signable request string containing the http method, url and parameters.
		 * 
		 * @return 
		 */		 
		public function getSignableString():String 
		{
			var signable:Array = [null,null,null];
			
			signable[0] = ( encodeURIComponent( $httpMethod ) );
			signable[1] = ( encodeURIComponent( $requestURL ) );
			signable[2] = ( encodeURIComponent( getSignableParameters() ) );
			
			return signable.join("&");
		}
		
		/**
		 * Builds and signs the request using the provided signature method and result type requested. 
		 * 
		 * @param signatureMethod	An object implemented with IOAuthSignature method. Typically <code>OAuthSignatureMethod_PLAINTEXT</code> or <code>OAuthSignatureMethod_HMAC_SHA1</code>. 
		 * @param requestType		A request type that determines what OAuth signature is returned.
		 * @param realm				A string which specifies a realm which will be used in the request header. Used only if the <code>requestType</code> equals <code>OAUTH_REQUEST_TYPE_HEADER</code>.
		 * @return					An object whose type is determined by the <code>requestType</code>. 
		 * 
		 * @see OAuthSignatureMethod_PLAINTEXT
		 * @see OAuthSignatureMethod_HMAC_SHA1
		 * @see IOAuthSignatureMethod
		 * @throws Error Throws an Error if the signature method or request type is invalid and the request cannot be signed.
		 */		
		public function buildRequest(signatureMethod:IOAuthSignatureMethod, requestType:String=OAUTH_REQUEST_TYPE_URL_STRING, realm:String=null):* 
		{
			// check that the signature method is valid
			if(!signatureMethod.name) 
				throw new Error("OAuth signature method not implemented.");
			
			// check that the requestType is valid.
			if(this.validRequestTypes.indexOf(requestType) == -1) 
				throw new Error("The OAuth request type: "+requestType+", is not implemented. Value must be a property of OAuthRequest::validRequestTypes");
			
			// use the current date for the oauth_timestamp and to generate the nonce. 
			var date:Date = new Date();

			// add the required oauth params.
			$requestParams.oauth_consumer_key = this.$consumer.key;
			$requestParams.oauth_nonce = OAuthUtil.generate_nonce(date);
			$requestParams.oauth_signature_method = signatureMethod.name; 
			$requestParams.oauth_timestamp = OAuthUtil.generate_timestamp(date);
			$requestParams.oauth_version = OAuthUtil.OAUTH_VERSION;
			
			// to support two-legged auth, add the token key only if theres a token present
			if(this.$token) {
				$requestParams.oauth_token = this.$token.key;
			}
			
			// generate the signature
			$requestParams.oauth_signature = signatureMethod.buildSignature(this);
			
			var request:* = null;
			
			// build the request object based on the type selected. 
			switch (requestType) 
			{
				case OAUTH_REQUEST_TYPE_URL_STRING:
					request = this.buildURLString();
					break;
				case OAUTH_REQUEST_TYPE_URL_VARIABLES:
					request = this.buildURLVariables();
					break;
				case OAUTH_REQUEST_TYPE_OBJECT:
					request = this.buildURLObject();
					break;
				case OAUTH_REQUEST_TYPE_POST:
					request = this.getParameters();
					break;
				case OAUTH_REQUEST_TYPE_HEADER:
					request = this.buildAuthorizationHeader(realm);
					break;
			}
			
			return request;
		}
		
	//-------------------------
	//	Private Functions
	//-------------------------
		
		/**
		 * Builds the request parameters as a URLVariables object containing the key=value pairs.
		 * @return 
		 * 
		 */		
		private function buildURLVariables():URLVariables
		{
			var args:URLVariables = new URLVariables();
					
			for (var param:Object in $requestParams) 
			{
				args[param] = $requestParams[param];
			}

			return args;
		}
		
		/**
		 * Builds the request parameters as an Object containing key value pairs.
		 * @return 
		 * 
		 */		
		private function buildURLObject():Object
		{
			var args:Object = {};
			
			var signableParams:Object = OAuthUtil.copyObject($requestParams);
			for (var param:Object in signableParams) 
			{
				// fugly
				if( String(param).indexOf("oauth_") == 0)
				{
					$requestParams[param] = encodeURIComponent($requestParams[param]);
//					trace(param, $requestParams[param]);
				}
				
				args[param] = $requestParams[param];
			}
			return args;
		}
		
		/**
		 * Builds the request parameters as a URL.
		 *  
		 * @return 		A String containing the requestURL and the parameter query string. 
		 * 
		 */		
		private function buildURLString():String
		{
			return $requestURL+"?"+getParameters();
		}
		
		/**
		 * Builds the request parameters as an OAuth Authorization header.
		 * 
		 * @param realm		A string which specifies the OAuth realm.
		 * @return 
		 * @private
		 * @see http://oauth.net/core/1.0/#auth_header
		 */		
		private function buildAuthorizationHeader(realm:String=null):URLRequestHeader
		{
			var signableParams:Object = OAuthUtil.copyObject($requestParams);
			var headerParams:Array = [];
			
			if(realm && realm != "") {
				headerParams.push("realm=\""+realm+"\"");
			}
			
			headerParams.push("oauth_consumer_key=\""+$requestParams.oauth_consumer_key+"\"");
			headerParams.push("oauth_signature_method=\""+$requestParams.oauth_signature_method+"\"");
			headerParams.push("oauth_signature=\""+$requestParams.oauth_signature+"\"");
			headerParams.push("oauth_timestamp=\""+$requestParams.oauth_timestamp+"\"");
			headerParams.push("oauth_nonce=\""+$requestParams.oauth_nonce+"\"");
			headerParams.push("oauth_version=\""+$requestParams.oauth_version+"\"");
			
			if($requestParams.oauth_token && $requestParams.oauth_token != "") {
				headerParams.push("oauth_token=\""+$requestParams.oauth_token+"\"");
			}
			
			return new URLRequestHeader("Authorization", "OAuth "+headerParams.join(','));
		}
		
		/**
		 * Builds a query string that consists of all the parameters that need to be signed.
		 * 
		 * @return 
		 * @private
		 */		
		private function getSignableParameters():String 
		{
			var signableParameters:Array = [];
			var temp:Array = [];
			
			// be safe, copy the object so we dont attempt to alter the original object.
			var params:Object = OAuthUtil.copyObject($requestParams);
			
			// delete the signature, we dont want it in the sig.
			delete params.oauth_signature;
			
			// urlencode the oauth_token, causes problems sometimes with making valid signatures.
			if(params.oauth_token) {
				params.oauth_token = encodeURIComponent(params.oauth_token);
			}
			
			var value:String = null;
			
			for (var key:String in params) 
			{
				key = OAuthUtil.urlencodeRFC3986(key);
				value = params[key].toString();
				
				if(this.useExplicitEncoding) value = OAuthUtil.urlencodeRFC3986(value);
				
				signableParameters.push(key+"="+value);
			}

			// oauth expects the parameter string 
			// to be sorted alphabetically by key.
			// technically, this isn't good 
			// since "=" can mess up the sort
			signableParameters.sort();
			
			// return a query string.
			return signableParameters.join("&");
		}
		
		/**
		 * Builds an encoded query string that consists of all the parameters.
		 * 
		 * @return
		 * @private
		 */
		private function getParameters():String 
		{
			var params:Array = [];
			
			var value:String = null;
			
			// build a key=value string
			for (var key:String in $requestParams) 
			{
				value = $requestParams[key].toString();
				params.push(key+"="+encodeURIComponent(value));
			}

			// oauth expects the parameter string 
			// to be sorted alphabetically by key.
			params.sort();
			
			// return as a query string.
			return params.join("&");
		}
	}
}