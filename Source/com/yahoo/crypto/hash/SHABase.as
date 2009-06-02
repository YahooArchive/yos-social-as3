/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
/**
 * SHABase
 * 
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.yahoo.crypto.hash
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * An ActionScript 3 abstract class for the SHA family of hash functions
	 * @private
	 */
	internal class SHABase implements IHash
	{
		/**
		 * Returns the input size of the hash.
		 */		
		public function getInputSize():uint
		{
			return 64;
		}
		
		/**
		 * Returns the size of the hash.
		 */		
		public function getHashSize():uint
		{
			return 0;
		}
		
		/**
		 * 
		 */		
		public function hash(src:ByteArray):ByteArray
		{
			var savedLength:uint = src.length;
			var savedEndian:String = src.endian;
			
			src.endian = Endian.BIG_ENDIAN;
			var len:uint = savedLength *8;
			
			// pad to nearest int.
			while (src.length%4!=0) {
				src[src.length]=0;
			}
			
			// convert ByteArray to an array of uint
			src.position=0;
			var a:Array = [];
			
			for (var i:uint=0;i<src.length;i+=4) {
				a.push(src.readUnsignedInt());
			}
			
			var h:Array = core(a, len);
			var out:ByteArray = new ByteArray;
			var words:uint = getHashSize()/4;
			
			for (i=0;i<words;i++) {
				out.writeUnsignedInt(h[i]);
			}
			
			// unpad, to leave the source untouched.
			src.length = savedLength;
			src.endian = savedEndian;
			
			return out;
		}
		
		/**
		 * @private
		 */		
		protected function core(x:Array, len:uint):Array 
		{
			return null;
		}
		
		/**
		 * Returns the name of the hash.
		 */		
		public function toString():String
		{
			return "sha";
		}
	}
}