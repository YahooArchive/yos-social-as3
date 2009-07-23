/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.net
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	/**
	 * A helpful utility class that is used to create and handle basic HTTP requests in Flash and AIR.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 * <p>
	 * Available callback functions are:
	 * <p>
	 * <ul> 
	 * <li><code>security</code></li> 
	 * <li><code>open</code></li>
	 * <li><code>progress</code></li>
	 * <li><code>failure</code></li>
	 * <li><code>success</code></li>
	 * <li><code>httpStatus</code> (Adobe AIR only)</li>
	 * </ul>
	 * </p>
	 * </p>
	 * 
	 * @example 
	 * <listing version="3.0">
	 *	var args:Object = new Object();
	 * 	args.foo = "bar";
	 *  args.format = "xml";
	 * 
	 *	var callback:Object = new Object();
	 * 	callback.success = handleSuccess;
	 * 	callback.failure = handleFailure;
	 * 
	 *	Connection.asyncRequest("GET", "http://example.com/some_feed.xml", callback, args);
	 * 
	 *	function handleSuccess(response:Object):void
	 *	{
	 * 		trace(response.responseText);
	 *      var xml:XML = response.responseXML; // grab the parsed xml object.
	 *	}
	 * 
	 *	function handleFailure(response:Object):void
	 *	{
	 *		trace(response.responseText);
	 *	}
	 * </listing>
	 */	
	public class Connection extends Object
	{
		/*
		  The callback response data type is an Object containing the response / error values.
		  The easiest way to view the data is from within the debugger.
		*/
		 
		/**
		 * @private
		 */
		private static const ELEMENT:String = "element";
		
		/**
		* @private 
		*/
		private static const FUNCTION:String = "function";
		
		/**
		 * Creates and sends a new HTTP request.
		 * 
		 * @param httpMethod 	The URLRequestMethod to use in the request.
		 * @param url 			The URL to call in the URLRequest
		 * @param callback 		An Object containing <code>success</code>, <code>failure</code> and <code>security</code> callback functions.
		 * @param args 			An Object, String, URLVariables or ByteArray to include in the URLRequest.data object.
		 * @param headers		An array of valid URLRequestHeader objects to be set in the URLRequest.requestHeaders property.
		 * 
		 * @return 				The URLRequest object generated.
		 */
		public static function asyncRequest(httpMethod:String, url:String, callback:Object, args:Object=null, headers:Array=null, timeout:int=-1):URLRequest 
		{
			var hasResponse:Boolean;
			var timedOut:Boolean;
			var status:int;
			var responseHeaders:Array;
			var urlLoader:URLLoader;
			
			urlLoader = new URLLoader();
			
			// listen for http response event from AIR runtime. 
			// *uses the string value to avoid compilation errors in non-AIR projects*
			urlLoader.addEventListener("httpResponseStatus", function(event:HTTPStatusEvent):void
			{
				/* AIR-Only */
				status = event.status;
				responseHeaders = event["responseHeaders"];
				
				// handle httpStatus callback
				if(callback.httpStatus && typeof callback.httpStatus == FUNCTION) {
					callback.httpStatus({
						args:args,
						url:url,
						status: status,
						responseHeaders: responseHeaders
					});
				}
			});
			
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(event:HTTPStatusEvent):void 
			{
				status = event.status; // this is pretty useless in flash player, in AIR we can use the httpResponseStatus event.
			});
			
			urlLoader.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void 
			{
				// handle progress callback
				if(callback.progress && typeof callback.progress == FUNCTION) {
					callback.progress({
						args:args,
						url:url,
						bytesLoaded: event.bytesLoaded,
						bytesTotal:event.bytesTotal
					});
				}
			});
			
			urlLoader.addEventListener(Event.OPEN, function(event:Event):void 
			{
				// handle security error callback
				if(callback.open && typeof callback.open == FUNCTION) {
					callback.open({
						url:url,
						args:args
					});
				}
			});
			
			urlLoader.addEventListener(Event.COMPLETE, function(event:Event):void 
			{
				hasResponse = true;
				var responseText:String = urlLoader.data;
				var responseXML:XML;
				var parseSuccess:Boolean=true;
				
				try{
					responseXML = new XML(responseText);
				}catch(e:Error) {
					parseSuccess = false;
				}
				
				if(responseXML) parseSuccess = Connection.isValidXML( responseXML );
				
				// handle success callback event
				if(callback.success && typeof callback.success == FUNCTION) {
					callback.success({
						responseText:responseText,
						responseXML:responseXML,
						responseHeaders:responseHeaders,
						status:status,
						args:args,
						url:url,
						headers:headers,
						method:httpMethod,
						xmlParseSuccess:parseSuccess,
						bytesLoaded: urlLoader.bytesLoaded,
						bytesTotal: urlLoader.bytesTotal
					});
				}
				
				urlLoader = null;
			});
			
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void 
			{
				// handle security error event
				if(callback.security && typeof callback.security == FUNCTION) {
					callback.security({
						args:args,
						url:url,
						text:event.text
					});
				}
			});
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void 
			{
				// handle IOError (!200) callback event.
				if(callback.failure && typeof callback.failure == FUNCTION) {
					callback.failure({
						status:status,
						responseText:event.text,
						responseHeaders:responseHeaders,
						args:args,
						url:url,
						headers:headers,
						method:httpMethod,
						bytesLoaded: urlLoader.bytesLoaded,
						bytesTotal: urlLoader.bytesTotal
					});
				}
			});
			
			if(timeout > 0) {
				flash.utils.setTimeout(function ():void 
				{
					if(!hasResponse) {
						urlLoader.close();
						timedOut = true;
						var data:Object = {
							status:status,
							responseHeaders:responseHeaders,
							args:args,
							url:url,
							headers:headers,
							method:httpMethod,
							bytesLoaded: urlLoader.bytesLoaded,
							bytesTotal: urlLoader.bytesTotal,
							timedOut:timedOut
						};
						if(callback.timeout && typeof callback.timeout == FUNCTION) {
							callback.timeout(data);
						}
						// if(callback.failure && typeof callback.failure == FUNCTION) {
						// 	callback.failure(data);					
						// }
					}
				}, timeout);
			}
			
			var request:URLRequest = new URLRequest(url);
			var n:String = null;
			
			if(args)
			{
				if(args is String || args is ByteArray || args is URLVariables)
				{
					// set the args object as the request data. 
					// must be a POST request.
					request.data = args;
				}
				else if(args is Object)
				{
					// create a URLVariables object 
					var variables:URLVariables = new URLVariables();
					for(n in args) {
						variables[n] = args[n];
					}
					request.data = variables;
				} 
			}
			
			n = null;
			
			if(headers)
			{
				request.requestHeaders = headers;
			}
			
			request.method = httpMethod;
			
			urlLoader.load( request );
			
			return request;
		}
		
		/**
		 * Checks if the provided XML object represents a valid XML document.
		 * @param xml 			An XML object, typically as <code>XML(responseText)</code> to validate as XML
		 */
		public static function isValidXML(xml:XML):Boolean 
		{
			return (xml.nodeKind() == ELEMENT);
		}
		
		/**
		 * Generates URL-encoded query string given an object containing key value pairs.
		 * 
		 * @param args			An object containing the key-value pairs. 
		 * @param separator		A string containing the characters used to seperate each element of the query string.
		 * @return
		 * 
		 */		
		public static function http_build_query(args:Object,separator:String="&"):String
	    {
			var key:String;
			var val:Object;
			var tmp_arr:Array = [];
			
			for(key in args)
			{
				key = encodeURIComponent( key );
				val = encodeURIComponent( args[key].toString() );
				
				tmp_arr.push(key+'='+val);
			}
			
			return tmp_arr.join(separator);
	    }
	    
	    /**
	     * Parses a query string into a native object containing key value pairs. 
	     * @param query			The query string to parse to a native object.
	     * @param separator		The seperator used to split the string into seperate elements.
	     * @return 
	     * 
	     */	     
	    public static function parse_query(query:String,separator:String="&"):Object
	    {
			var pairs:Array = query.split(separator);
			var ret:Object = {};
			
			for each(var item:String in pairs)
			{
				var kv:Array = item.split("=",2);
				ret[kv[0]] = kv[1];
			}
			
			return ret;
	    }
	}
}