/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.oauth
{
	/**
	 * The OAuthConsumer class contains the consumer key and secret provided by a service provider.
	 * 
	 * This class is dynamic in order to support extensions.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://oauth.net/core/1.0#anchor6
	 */	
	dynamic public class OAuthConsumer
	{
		/**
		 * @private 
		 */		
		private var $key:String;
		
		/**
		 * @private 
		 */		
		private var $secret:String;
		
		/**
		 * Class constructor 
		 * 
		 * Creates a new OAuthConsumer object.
		 * 
		 * @param key Consumer key.
		 * @param secret Consumer secret.
		 */
		public function OAuthConsumer(key:String="", secret:String="")
		{
			this.$key = key;
			this.$secret = secret;
		}
		
		/**
		 * Consumer key
		 * 
		 * @return A value used by the Consumer to identify itself to the Service Provider.
		 */
		public function get key():String 
		{
			return this.$key;
		}
		
		/**
		 * @private
		 */
		public function set key(value:String):void 
		{
			if (value != this.$key)
			{
				this.$key = value;
			}
		}
		
		/**
		 * Consumer secret
		 * 
		 * @return A secret used to establish ownership of the consumer key. 
		 */
		public function get secret():String 
		{
			return this.$secret;
		}
		
		/**
		 * @private
		 */
		public function set secret(value:String):void 
		{
			if (value != this.$secret)
			{
				this.$secret = value;
			}
		}
		
		/**
		 * Returns true if the token or key values are empty or null. 
		 * @return 
		 * 
		 */		
		public function get empty():Boolean
		{
			return ($key == "" || $secret == "");
		}
	}
}