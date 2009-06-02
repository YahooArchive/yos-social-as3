/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.utils
{
	import com.yahoo.net.Connection;
	
	/**
	 * This class handles the creation of URLs to YOS web-services.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 * @example 
	 * <listing version="3.0">
	 * var url:YahooURL = new YahooURL("http", HOST_NAME);
	 * url.rawResource("v1/user");
	 * url.resource(guid);
	 * 
	 * var req:URLRequest = new URLRequest(url.toString());
	 * </listing>
	 */	
	public class YahooURL
	{
		/**
		 * @private 
		 */		
		private var $protocol:String;
		
		/**
		 * @private 
		 */		
		private var $path:Array;
		
		/**
		 * @private
		 */
		private var $queryParameters:Object;
		
		/**
		 * The hostname. 
		 */		
		public var hostname:String;
		
		/**
		 * The port. (Default=80)
		 */		
		public var port:int;
			
		/**
		 * Creates a new YahooURL object.
		 * 
		 * @param protocol	The request protocol.
		 * @param hostname	The server hostname.
		 * @param port		The server port.
		 * 
		 */		
		public function YahooURL(protocol:String, hostname:String, port:int=80)
		{
			this.protocol = protocol;
			this.hostname = hostname;
			this.port = port;
			
			$path = new Array();
		}
		
		/**
		 * The valid protocols for use with this object.
		 * @return 
		 * 
		 */		
		public function get validProtocols():Array
		{
			return ["http","https"];
		}
		
		/**
		 * The request protocol. 
		 * If the value is not valid, it will fall back on <code>http</code>.
		 * @param value
		 * 
		 */		
		public function set protocol(value:String):void
		{
			if(this.validProtocols.indexOf(value) == -1)
			{
				value = validProtocols[0];
			}
			
			$protocol = value;
		}
		
		/**
		 * The request protocol. 
		 * @return 
		 * 
		 */		
		public function get protocol():String
		{
			return $protocol;
		}
		
		/**
		 * Returns the relative path represented as an array. 
		 * @return 
		 * 
		 */		
		public function get path():Array
		{
			return $path;
		}
		
		/**
		 * Returns an object containing the query parameters.  
		 * @return 
		 * 
		 */		
		public function get queryParameters():Object
		{
			return this.$queryParameters;
		}
		
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set queryParameters(value:Object):void
		{
			this.$queryParameters = value;
		}
		
		/**
		 * Resets the relative path. 
		 * 
		 */		
		public function resetPath():void
		{
			$path = new Array();
		}
		
		/**
		 * Applies a resource value (url-encoded) to the URL path. 
		 * @param value
		 * 
		 */		
		public function resource(value:String):void
		{
			$path.push( encodeURIComponent(value) );
		}
		
		/**
		 * Applies a raw resource value to the URL path. 
		 * @param value
		 * 
		 */		
		public function rawResource(value:String):void
		{
			$path.push( value );
		}
		
		/**
		 * Applies a filter to the URL path. 
		 * @param filtername
		 * @param arguments
		 * 
		 */		
		public function filter(filtername:String, arguments:*):void
		{
			var args:String;
			if(arguments is Array)
			{
				var args_arr:Array = (arguments as Array);
				args_arr = args_arr.map(_encodeURI);
				args = args_arr.join(",");
			}
			else if(arguments is String)
			{
				args = (arguments as String);
				args = encodeURIComponent(args);
			}
			
			$path.push(filtername+"("+args+")");
		}
		
		
		
		/**
		 * Returns the full URL. 
		 * @return 
		 * 
		 */		
		public function toString():String
		{
			var url:String = $protocol+"://"+this.hostname;
			
			if(!isNaN(this.port) && this.port != 80) { 
				url += ":"+this.port;
			}
			
			url += toPathString();
			
			if(this.$queryParameters) {
				url += "?"+Connection.http_build_query(this.$queryParameters,"&");
			}
			
			return url;
		}
		
		/**
		 * Returns the relative URL as a representation of <code>path</code>, delimited by slashes. 
		 * @return 
		 * 
		 */		
		public function toPathString():String
		{
			return "/"+$path.join("/");
		}
		
		/**
		 * Helper method for the filter function's Array.map requirement.
		 * @private 
		 * @param element
		 * @param index
		 * @param arr
		 * @return 
		 * 
		 */		
		private function _encodeURI(element:*, index:int, arr:Array):String
		{
			return encodeURIComponent(String(element));
		}
	}
}