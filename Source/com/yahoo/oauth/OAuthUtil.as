/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	import com.yahoo.crypto.hash.HMAC;
	import com.yahoo.crypto.hash.MD5;
	import com.yahoo.crypto.util.Base64;
	import com.yahoo.crypto.util.Hex;
	
	import flash.utils.ByteArray;
	
	/**
	 * A utility class for various OAuth functionality.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 */	
	public class OAuthUtil
	{
		/**
		 * The version of OAuth. 
		 */		
		public static const OAUTH_VERSION:String = "1.0";
		
		/**
		 * Copies the specified Object and returns a reference to the copy. 
		 * 
		 * The copy is made using a native serialization technique. 
		 * 
		 * @see 			http://livedocs.adobe.com/flex/3/langref/mx/utils/ObjectUtil.html#copy()
		 * @param value		The object to copy.
		 * @return 			Copy of the specified Object.
		 */
		public static function copyObject(value:Object):*
		{
			// code borrowed from mx.utils.ObjectUtil.copyObject
			// this is done to avoid using the mx package 
			// in what i'd like to keep as a pure AS3 lib
			
			var buffer:ByteArray = new ByteArray();
			buffer.writeObject(value);
			buffer.position = 0;
			
			return buffer.readObject();
		}
		
		/**
		 * Generate a keyed hash value using the HMAC-SHA1 encryption method.
		 * 
		 * @param data		Message to be hashed.
		 * @param key		Shared secret key used for generating the signature.
		 * @return 			
		 * 
		 */		
		public static function hmac_sha1(data:String, key:String):String
		{
			var key_bytes:ByteArray = Hex.toArray(Hex.fromString(key));
			var message_bytes:ByteArray = Hex.toArray(Hex.fromString( data ));
			
			var hmac:HMAC = HMAC.get_hmac_sha1();
			var bytes:ByteArray = hmac.compute(key_bytes,message_bytes);
			
			var hash:String = Base64.encodeByteArray( bytes );
			hmac.dispose();
			
			return hash;
		}
		
		/**
		 * Generates an MD5 encoded string based on the current date and a random number.
		 * 
		 * Used in the OAuth request parameters as a method to prevent replay 
		 * attacks by generating a string which is not likely to recur. 
		 * 
		 * @param date		A Date object. If null, the function will use the current date.
		 * @return 
		 */		
		public static function generate_nonce(date:Date=null):String
		{
			if(!date) date = new Date();
			
			// current time + random number string
			var toHash:String = (date.getTime()+Math.random()).toString();
			var hex:String = Hex.fromString(toHash);
			var bytes:ByteArray = Hex.toArray(hex);
			
			// get an MD5 string.
			var digest:ByteArray = new MD5().hash(bytes);
			var hash:String = Hex.fromArray(digest);
			
			return hash;
		}
		
		/**
		 * Generates a timestamp (seconds) given the current date. 
		 * @param date
		 * @return
		 * 
		 */		
		public static function generate_timestamp(date:Date=null):String
		{
			if(!date) date = new Date();
			
			return Math.round(date.time/1000).toString();
		}
		
		/**
		 * Encodes a string using RFC-3986. 
		 * @param value
		 * @return 
		 * 
		 */				
		public static function urlencodeRFC3986(value:String):String
		{
			/* adds an extra replace for tilde (~) */
			return encodeURIComponent(value).replace('%7E', '~');
		}
    	
		/**
		 * Decodes a string using RFC-3986.
		 * @param value
		 * @return 
		 * 
		 */    	
		public static function urldecodeRFC3986(value:String):String 
		{
			/* but actually it's just a wrapper over the global decodeURIComponent. */
			return decodeURIComponent(value);
  		}
  		
  		/**
		 * Generates query string suitable for OAuth, given an object containing key=value pairs.
		 * 
		 * @param args
		 * @param separator
		 * @return 
		 * 
		 */		
		public static function oauth_http_build_query(args:Object,separator:String="&"):String
	    {
			var key:String;
			var val:Object;
			var tmp_arr:Array = new Array();
			
			for(key in args) {
				val = args[key].toString();
				
				tmp_arr.push(key+'='+val);
			}
			
			return tmp_arr.join(separator);
	    }
	}
}