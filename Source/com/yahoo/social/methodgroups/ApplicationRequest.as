/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.yahoo.net.Connection;
	import com.yahoo.oauth.OAuthConnection;
	import com.yahoo.oauth.OAuthRequest;
	import com.yahoo.social.events.YahooResultEvent;
	import com.yahoo.social.utils.YahooURL;
	
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	/**
	* Dispatched when the setSmallView request executes successfully.
	*/	
	[Event(name="setSmallViewSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the setSmallView request encounters an error.
	*/	
	[Event(name="setSmallViewFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper over the YAP developer APIs which manages the cached content inside YahooSmallView.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @example
	 * <listing version="3.0">
	 *  YahooSession.YAP_VIEWER = "$viewerGuid";
	 *  
	 * 	var session:YahooSession = new YahooSession(CONSUMER_KEY, CONSUMER_SECRET);
	 * 
	 * 	var content:String = "Hello &lt;yml:name uid=\"viewer\"/&gt; from Flex 3";
	 * 
	 *  session.application.addEventListener(YahooResultEvent.SET_SMALL_VIEW_SUCCESS, handleSetSmallView);
	 * 	session.application.setSmallView(YahooSession.YAP_VIEWER, content);
	 * 
	 * 	function handleSetSmallView(event:YahooResultEvent):void
	 * 	{
	 *  	trace(event.type);
	 * 		// yay!
	 * 	}
	 * </listing>
	 */	
	public class ApplicationRequest extends YOSMethodBase
	{
		/**
		 * Class constructor. 
		 * Creates a new ApplicationRequest object.
		 */		
		public function ApplicationRequest()
		{
			super(null);
			
			this.$hostname = YOSMethodBase.APPSTORE_WS_HOSTNAME;
			this.$oauthRequestType = OAuthRequest.OAUTH_REQUEST_TYPE_HEADER;
		}
		
		/**
		 * Sets the small view for the user given by the GUID.
		 * 
		 * Supports only HTML and YML Lite
		 * 
		 * @param guid			The GUID of the targetted user.
		 * @param content		HTML and YML Lite contents.
		 */		
		public function setSmallView(guid:String, content:String):void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version);
			url.rawResource("cache/view/small");
			url.resource(guid);
			
			var callback:Object = new Object();
			callback.success = handleSetSmallViewSuccess;
			callback.failure = handleSetSmallViewFailure;
			callback.security = handleSecurityError;
			
			// pass an empty args object to be signed.  
			var requestArgs:Object = {};
			var httpMethod:String = URLRequestMethod.POST;
			
			// create a new oauth'd connection using the consumer.
			var oauth_connection:OAuthConnection = OAuthConnection.fromConsumerAndToken(this.consumer);
			oauth_connection.requestType = this.$oauthRequestType;
			
			// build out the headers
			var accept:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var contentType:URLRequestHeader = new URLRequestHeader("Content-Type", "text/html;charset=utf-8");
			var authorization:URLRequestHeader = oauth_connection.signRequest(httpMethod, url.toString(), requestArgs);
			
			// fun fact: you can't send headers with a GET, only with POST. 
			var headers:Array = [contentType,accept,authorization];
			
			oauth_connection.asyncRequest(httpMethod, url.toString(), callback, content, headers);
		}
		
		/**
		 * @private
		 * @param response
		 * 
		 */		
		private function handleSetSmallViewSuccess(response:Object):void
		{
			if(this.getResponseStatusOk(response.status)) {
				var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.SET_SMALL_VIEW_SUCCESS, response);
				this.dispatchEvent(event);
			} else {
				handleSetSmallViewFailure(response);
			}
		}
		
		/**
		 * @private
		 * @param response
		 * 
		 */		
		private function handleSetSmallViewFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.SET_SMALL_VIEW_FAILURE, response);
			this.dispatchEvent(event);
		}
	}
}