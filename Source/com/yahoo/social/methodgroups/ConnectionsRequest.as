/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.adobe.serialization.json.JSONParseError;
	import com.yahoo.social.events.YahooResultEvent;
	import com.yahoo.social.utils.YahooURL;
	
	import flash.net.URLRequestMethod;
	
	/**
	* Dispatched when the getConnections request executes successfully.
	*/	
	[Event(name="getConnectionsSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getConnections request fails.
	*/	
	[Event(name="getConnectionsFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper for the Connections API. 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/social/rest_api_guide/connections.html
	 * @example 
	 * <listing version="3.0">
	 * 	// retrieve the sessioned user
	 * 	var user:YahooUser = _session.getSessionedUser();
	 * 	
	 * 	// add connections response event listeners
	 * 	user.connections.addEventListener(YahooResultEvent.GET_CONNECTIONS_SUCCESS, handleConnectionsSuccess);
	 * 	user.connections.addEventListener(YahooResultEvent.GET_CONNECTIONS_FAILURE, handleConnectionsFailure);
	 * 	user.connections.getConnections(0,50);
	 * 
	 * 	function handleConnectionsSuccess(event:YahooResultEvent):void
	 * 	{
	 * 		var connections:Array = event.data as Array;
	 * 		// do something
	 * 	}
	 * 
	 * 	function handleConnectionsFailure(event:YahooResultEvent):void
	 * 	{
	 * 		// do something	
	 * 	}
	 * </listing>
	 */	
	public class ConnectionsRequest extends YOSMethodBase
	{
		/**
		 * Class constructor.
		 * Creates a new ConnectionsRequest object for the provided user. 
		 * 
		 */
		public function ConnectionsRequest()
		{
			super();
			this.$hostname = YOSMethodBase.SOCIAL_WS_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Retrieves a list of connections for this user. 
		 * @param start		Defines the starting point of the search.
		 * @param count		Defines the number of connections to return.
		 * 
		 */		
		public function getConnections(start:int, count:int):void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version+"/user");
			url.resource(this.$user.guid);
			url.rawResource("connections");
			
			var args:Object = getDefaultArguments();
			args.view = "usercard";
			args.start = start;
			args.count = count;
			
			var callback:Object = new Object();
			callback.success = handleGetConnectionsSuccess;
			callback.failure = handleGetConnectionsFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetConnectionsSuccess(response:Object):void
		{
			var rsp:String = response.responseText;
			var json:Object = null;
			var connections:Array = new Array();
			
			if(this.getResponseStatusOk(response.status))
			{
				try
				{
					json = this.decodeJSON(rsp);
				}
				catch(error:JSONParseError)
				{
					handleGetConnectionsFailure(response);
					return;
				}
				
				if(json.error) 
				{
					handleGetConnectionsFailure(response);
				}
				else
				{
					var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTIONS_SUCCESS, json.connections);
					this.dispatchEvent(event);
				}
			}
			else
			{
				handleGetConnectionsFailure(response);
			}
		}
	    
		/**
		 * @private 
		 * @param response
		 * 
		 */	    
		private function handleGetConnectionsFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTIONS_FAILURE, response);
			this.dispatchEvent(event);
		}
	}
}