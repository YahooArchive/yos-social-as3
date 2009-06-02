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
	* Dispatched when the getStatus request executes successfully.
	*/	
	[Event(name="getStatusSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getStatus request fails.
	*/	
	[Event(name="getStatusFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper for the Status API.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/social/rest_api_guide/status_api.html
	 * @example 
	 * <listing version="3.0">
	 * 	// retrieve the sessioned user
	 * 	var user:YahooUser = _session.getSessionedUser();
	 * 	
	 * 	// add presence response event listeners
	 * 	user.presence.addEventListener(YahooResultEvent.GET_STATUS_SUCCESS, handleGetStatusSuccess);
	 * 	user.presence.addEventListener(YahooResultEvent.GET_STATUS_FAILURE, handleGetStatusFailure);
	 * 	user.presence.getStatus();
	 * 
	 * 	function handleGetStatusSuccess(event:YahooResultEvent):void
	 * 	{
	 * 		var status:Object = event.data;
	 *      var message:String = status.message;
	 * 		// do something
	 * 	}
	 * 
	 * 	function handleGetStatusFailure(event:YahooResultEvent):void
	 * 	{
	 * 		// there was an error fetching the data
	 *      // do something		
	 * 	}
	 * </listing>
	 */	
	public class StatusRequest extends YOSMethodBase
	{
		/**
		 * Class constructor.
		 * Creates a new StatusRequest object for the provided user. 
		 */
		public function StatusRequest()
		{
			super();
			this.$hostname = YOSMethodBase.SOCIAL_WS_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Retrieves the current status message for this user. 
		 * 
		 * @example 
		 * <listing version="3.0">
		 * 
		 * </listing>
		 */		
		public function getStatus():void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version);
			url.rawResource("user");
			url.resource(this.$user.guid);
			url.rawResource("profile/status");
			
			var args:Object = this.getDefaultArguments();
			
			var callback:Object = new Object();
			callback.success = handleGetStatusSuccess;
			callback.failure = handleGetStatusFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
	    
		/**
		 * Handles the success response from the getPresence request. 
		 * Parses the JSON responseText into a native object and dispatches a YEvent.USER_GET_PRESENCE_SUCCESS event.
		 * 
		 * @private 
		 * @param response
		 * 
		 */	    
		private function handleGetStatusSuccess(response:Object):void
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
					handleGetStatusFailure(response);
					return;
				}
				
				if(json.error)
				{
					handleGetStatusFailure(response);
				}
				else
				{
					var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_STATUS_SUCCESS, json.status);
					this.dispatchEvent(event);
				}
			}
			else
			{
				handleGetStatusFailure(response);
			}
		}
	    
		/**
		 * Handles the failure response from the getPresence request. 
		 * Dispatches a YEvent.USER_GET_PRESENCE_SUCCESS event containing the response object.
		 * 
		 * @private 
		 * @param response
		 * 
		 */
		private function handleGetStatusFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_STATUS_FAILURE, response);
			this.dispatchEvent(event);
		}
	}
}