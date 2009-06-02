/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
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
	 * Dispatched when the getUpdates request executes successfully.
	 */	
	[Event(name="getUpdatesSuccess", type="YahooResultEvent")]
	
	/**
	 * Dispatched when the getUpdates request fails.
	 */	
	[Event(name="getUpdatesFailure", type="YahooResultEvent")]
	
	/**
	 * Dispatched when the getConnectionUpdates request executes successfully.
	 */	
	[Event(name="getConnectionUpdatesSuccess", type="YahooResultEvent")]
	
	/**
	 * Dispatched when the getConnectionUpdates request fails.
	 */	
	[Event(name="getConnectionUpdatesFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper for the Updates API.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/social/rest_api_guide/updates_api.html
	 * @example 
	 * <listing version="3.0">
	 * 	// retrieve the sessioned user
	 * 	var user:YahooUser = _session.getSessionedUser();
	 * 	
	 * 	// add updates response event listeners
	 * 	user.updates.addEventListener(YahooResultEvent.GET_UPDATES_SUCCESS, handleGetUpdatesSuccess);
	 * 	user.updates.addEventListener(YahooResultEvent.GET_UPDATES_FAILURE, handleGetUpdatesFailure);
	 * 	user.updates.getUpdates();
	 * 
	 * 	function handleGetUpdatesSuccess(event:YahooResultEvent):void
	 * 	{
	 * 		var updates:Array = event.data as Array;
	 * 		// do something
	 * 	}
	 * 
	 * 	function handleGetUpdatesFailure(event:YahooResultEvent):void
	 * 	{
	 * 		// there was an error fetching the data
	 *      // do something	
	 * 	}
	 * </listing>
	 */	
	public class UpdatesRequest extends YOSMethodBase
	{
		protected var $transform:String = "%28sort%20%22pubDate%22%20numeric%20descending%20%28all%29%29";
		
		/**
		 * Class constructor.
		 * Creates a new UpdatesRequest object for the provided user. 
		 * 
		 * @param user		A YahooUser object.
		 * 
		 */
		public function UpdatesRequest()
		{
			super();
			this.$hostname = YOSMethodBase.SOCIAL_WS_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Lists all updates for the specified user. 
		 * @param start
		 * @param count
		 * 
		 * @example 
		 * <listing version="3.0">
		 * 
		 * </listing>
		 */		
		public function getUpdates(start:int=0, count:int=10):void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource("v1/user");
			url.resource(this.$user.guid);
			url.rawResource("updates");
			
			var args:Object = this.getDefaultArguments();
			args.start = start;
			args.count = count;
			args.transform = $transform;
			
			var callback:Object = new Object();
			callback.success = handleGetUpdatesSuccess;
			callback.failure = handleGetUpdatesFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetUpdatesSuccess(response:Object):void
		{
			var updates:Array = this.getUpdatesRsp(response);
			
			if(updates)
			{
				var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_UPDATES_SUCCESS, updates);
				this.dispatchEvent(event);
			}
			else
			{
				handleGetUpdatesFailure(response);
			}
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetUpdatesFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_UPDATES_FAILURE, response);
			this.dispatchEvent(event);
		}
		
		/**
		 * Lists all updates for the specified users connections.
		 * @param start
		 * @param count
		 * 
		 * @example 
		 * <listing version="3.0">
		 * 
		 * </listing>
		 */		
		public function getConnectionUpdates(start:int=0, count:int=10):void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource("v1/user");
			url.resource(this.$user.guid);
			url.rawResource("updates/connections");
			
			var args:Object = this.getDefaultArguments();
			args.start = start;
			args.count = count;
			args.transform = $transform;
			
			var callback:Object = new Object();
			callback.success = handleGetConnUpdatesSuccess;
			callback.failure = handleGetConnUpdatesFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetConnUpdatesSuccess(response:Object):void
		{
			var updates:Array = this.getUpdatesRsp(response);
			
			if(updates)
			{
				var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTION_UPDATES_SUCCESS, updates);
				this.dispatchEvent(event);
			}
			else
			{
				handleGetUpdatesFailure(response);
			}			
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetConnUpdatesFailure(response:Object, errorDesc:String = null):void
		{
			response.yahooErrorDesc = errorDesc;
			
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTION_UPDATES_FAILURE, response);
			this.dispatchEvent(event);
		}
		
		/**
		 * Helper function to parse an Updates response. 
		 * @param response
		 * @return 
		 * 
		 */		
		private function getUpdatesRsp(response:Object):Array
		{
			var rsp:String = response.responseText;
			var json:Object = null;
			
			if(this.getResponseStatusOk(response.status))
			{
				try
				{
					json = this.decodeJSON(rsp);
				}
				catch(error:JSONParseError)
				{
					return null;
				}
				
				if(!json['error'])
				{
					return json.updates;
				}
			}
			
			return null;
		}
	}
}