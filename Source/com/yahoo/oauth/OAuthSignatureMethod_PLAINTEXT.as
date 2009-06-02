/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	/**
	 * Signs a request as plain-text.
	 * 
	 * The <code>PLAINTEXT</code> method does not provide any security protection 
	 * and SHOULD only be used over a secure channel such as HTTPS. 
	 * It does not use the Signature Base String. 
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://oauth.net/core/1.0#anchor22
	 * @see http://oauth.net/core/1.0#anchor35
	 * 
	 */	
	public class OAuthSignatureMethod_PLAINTEXT extends OAuthSignatureMethod
	{
		/**
		 * Class contructor
		 * 
		 * <p>Creates a new OAuthSignatureMethod_PLAINTEXT object.</p>
		 */		
		public function OAuthSignatureMethod_PLAINTEXT()
		{
			this.$name = "PLAINTEXT";
		}
		
		/**
		 * Signs the request as plain-text.
		 * @param request		An OAuthRequest object to be signed.
		 * @return 				A plain-text string containing the consumer and token secrets joined by an ampersand.
		 * 
		 */		
		override public function buildSignature(request:OAuthRequest):String 
		{
			var secret_parts:Array = new Array(
				request.consumer.secret,
				(request.token) ? request.token.secret : ""
			);
			
			var secrets:String = secret_parts.join("&");
				
			return secrets;
		}
	}
}