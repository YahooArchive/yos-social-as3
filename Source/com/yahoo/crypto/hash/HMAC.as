/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
/**
 * HMAC
 * 
 * Copyright (c) 2007 Henri Torgemane
 * 
 * Adapted by Zach Graves (zachg@yahoo-inc.com)
 * 
 * See LICENSE.txt for full license information.
 */
package com.yahoo.crypto.hash
{
	import com.yahoo.crypto.util.Hex;
	
	import flash.utils.ByteArray;
	
	/**
	 * An ActionScript 3 implementation of HMAC, Keyed-Hashing for Message
 	 * Authentication, as defined by RFC-2104
	 * @private
	 *//* DOCME  */
	public class HMAC
	{
		private var hash:IHash;
		private var bits:uint;
		
		/**
		 * Returns a HMAC-SHA1 object 
		 */		
		public static function get_hmac_sha1():HMAC 
		{
			var hash:IHash = new SHA1();
			var bits:int = 0;
			return new HMAC(hash, bits);
		}
		
		/**
		 * Create a HMAC object, using a Hash function, and 
		 * optionally a number of bits to return. 
		 * The HMAC will be truncated to that size if needed.
		 */
		public function HMAC(hash:IHash, bits:uint=0) 
		{
			this.hash = hash;
			this.bits = bits;
		}
		
		/**
		 * Returns the size of the hash.
		 */
		public function getHashSize():uint 
		{
			if (bits!=0) {
				return bits/8;
			} else {
				return hash.getHashSize();
			}
		}
		
		/**
		 * Compute a HMAC using a key and some data.
		 * It doesn't modify either, and returns a new ByteArray with the HMAC value.
		 */
		public function compute(key:ByteArray, data:ByteArray):ByteArray 
		{
			var hashKey:ByteArray;
			
			if (key.length>hash.getInputSize()) 
			{
				hashKey = hash.hash(key);
			}
			else
			{
				hashKey = new ByteArray;
				hashKey.writeBytes(key);
			}
			
			while (hashKey.length<hash.getInputSize()) 
			{
				hashKey[hashKey.length]=0;
			}
			
			var innerKey:ByteArray = new ByteArray;
			var outerKey:ByteArray = new ByteArray;
			
			for (var i:uint=0;i<hashKey.length;i++) {
				innerKey[i] = hashKey[i] ^ 0x36;
				outerKey[i] = hashKey[i] ^ 0x5c;
			}
			
			// inner + data
			innerKey.position = hashKey.length;
			innerKey.writeBytes(data);
			
			var innerHash:ByteArray = hash.hash(innerKey);
			
			// outer + innerHash
			outerKey.position = hashKey.length;
			outerKey.writeBytes(innerHash);
			
			var outerHash:ByteArray = hash.hash(outerKey);
			
			if (bits>0 && bits<8*outerHash.length) {
				outerHash.length = bits/8;
			}
			
			return outerHash;
		}
		
		/**
		 * Disposes of the hash in memory. 
		 * 
		 */		
		public function dispose():void
		{
			hash = null;
			bits = 0;
		}
		
		public function toString():String 
		{
			return "hmac-"+(bits>0?bits+"-":"")+hash.toString();
		}
	}
}