/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	/**
	 * Base class for OAuth signature method implmentations.
	 * 
	 * This class alone cannot not be used to sign a request. 
	 * Instead, use <code>OAuthSignatureMethod_HMAC_SHA1</code> or 
	 * <code>OAuthSignatureMethod_PLAINTEXT</code>, or your own 
	 * that overrides the methods of this class.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 */	
	public class OAuthSignatureMethod implements IOAuthSignatureMethod
	{
		/**
		 * The name of the signature method. 
		 */		
		protected var $name:String;
		
		/**
		 * Class constructor.
		 * 
		 * <p>Creates a new OAuthSignaureMethod object.</p>
		 */		
		public function OAuthSignatureMethod()
		{
		}
		
		/**
		 * The name of the signature method.
		 * @return 
		 * 
		 */		
		public function get name():String
		{
			return $name;
		}
		
		/**
		 * Signs the request.
		 * @param request
		 * @return 
		 * 
		 */		
		public function buildSignature(request:OAuthRequest):String
		{
			return null;
		}
		
		/**
		 * Validates the given signature against a generated signature from the request. 
		 * @param signature		The signature string to be verified.
		 * @param request		The OAuthRequest to sign and compare against the provided signature.
		 * @return 				Returns true if the signature matches the signature built from the request.
		 * 
		 */		
		public function checkSignature(signature:String, request:OAuthRequest):Boolean
		{
			var built:String = this.buildSignature(request);
			return (built == signature);
		}
	}
}