/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{	
	import flash.utils.ByteArray;
	
	/**
	 * Signs a request using HMAC-SHA1 encryption.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://oauth.net/core/1.0#anchor16
	 */	
	public class OAuthSignatureMethod_HMAC_SHA1 extends OAuthSignatureMethod
	{
		/**
		 * Class contructor.
		 * 
		 * <p>Creates a new OAuthSignatureMethod_HMAC_SHA1 object.</p>
		 */		
		public function OAuthSignatureMethod_HMAC_SHA1()
		{
			this.$name = "HMAC-SHA1";
		}
		
		/**
		 * Signs the request using HMAC-SHA1 encryption.
		 * @param request	An OAuthRequest object to be signed.
		 * @return 			The signature as a Base64 encoded keyed hash value.
		 * 
		 */		
		override public function buildSignature(request:OAuthRequest):String 
		{
			var request_signableString:String = request.getSignableString();
			
			// get the secrets 
			var secret_parts:Array = new Array(
				request.consumer.secret,
				(request.token) ? request.token.secret : ""
			);
			
			var secrets:String = secret_parts.join("&");
			var signature:String = OAuthUtil.hmac_sha1(request_signableString, secrets);
			
//			trace("request_signableString:", request_signableString, "secrets:", secrets, "signature:", signature);
			
			return signature;
		}
	}
}