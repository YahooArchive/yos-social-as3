/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	/**
	 * Interface for all OAuth signature methods.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://oauth.net/core/1.0#signing_process
	 */	
	public interface IOAuthSignatureMethod
	{
		/**
		 * Class contructor.
		 * 
		 * Creates a new signature method object
		 * @return 
		 * 
		 */		
		function IOAuthSignatureMethod();
		
		/**
		 * The name of the signature method.
		 * @return 
		 * 
		 */		
		function get name():String;
		
		/**
		 * Signs the request.
		 * @param request
		 * @return 
		 * 
		 */		
		function buildSignature(request:OAuthRequest):String;
		
		/**
		 * Validates the given signature against a generated signature from the request. 
		 * @param signature
		 * @param request
		 * @return A Boolean, true if the signature provided matches the signature built from the request.
		 * 
		 */		
		function checkSignature(signature:String, request:OAuthRequest):Boolean;
	}
}