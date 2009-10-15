/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.adobe.serialization.json.JSONParseError;
	import com.yahoo.net.Connection;
	import com.yahoo.oauth.OAuthRequest;
	import com.yahoo.social.events.YahooResultEvent;
	import com.yahoo.social.utils.YahooURL;
	
	import flash.net.URLRequestMethod;
	
	/**
	 * Dispatched when the query request executes successfully.
	 */	
	[Event(name="yqlQuerySuccess", type="YahooResultEvent")]
	
	/**
	 * Dispatched when the query request fails.
	 */	
	[Event(name="yqlQueryFailure", type="YahooResultEvent")]
	
	/**
	 * Wraps the Yahoo! YQL web service. 
	 * Response objects are JSON decoded containing the search results.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/yql/
	 * @see http://developer.yahoo.com/yql/console/
	 * @example 
	 * <listing version="3.0">
	 * 
	 *  var session:YahooSession = new YahooSession('$consumerKey','$consumerSecret');
	 *  session.yql.addEventListener(YahooResultEvent.YQL_QUERY_SUCCESS, handleQuerySuccess);
	 *  session.yql.query("select * from geo.places where text='YVR'");
	 * 
	 * 	function handleQuerySuccess(event:YahooResultEvent):void
	 * 	{
	 *      // get the query result
	 * 		var results:Object = event.data.results;
	 * 		// and then do something awesome
	 * 	}
	 * </listing>
	 * 
	 * @example 
	 * <listing version="3.0">
	 *  // provide access tokens to get the sessioned user in order to access their profile information
	 * 
	 *  var session:YahooSession = new YahooSession('$consumerKey','$consumerSecret','$accessToken','$accessTokenSecret');
	 *  
	 *  var user:YahooUser = session.getSessionedUser();
	 *  user.yql.addEventListener(YahooResultEvent.YQL_QUERY_SUCCESS, handleQuerySuccess);
	 *  user.yql.query("select * from social.profile where guid=me");
	 * 
  	 *  function handleQuerySuccess(event:YahooResultEvent):void
	 * 	{
	 *      // get the query result
	 * 		var results:Object = event.data.results;
	 * 		// and then do something awesome
	 * 	}
	 * </listing>
	 * 
	 * @example 
	 * <listing version="3.0">
	 *  // Directly create a YQL object and use the queryPublic method to access any public information.
	 * 
	 *  var yql:YQL = new YQL();
	 *  yql.addEventListener(YahooResultEvent.YQL_QUERY_SUCCESS, handleQuerySuccess);
	 *  yql.queryPublic("select * from weather.forecast where location=98101");
	 * 
  	 *  function handleQuerySuccess(event:YahooResultEvent):void
	 * 	{
	 *      // get the query result
	 * 		var results:Object = event.data.results;
	 * 		// and then do something awesome
	 * 	}
	 * </listing>
	 */	
	public class YQL extends YOSMethodBase
	{
		/**
		 * Storage variable for environmentFile property.
		 * @private 
		 */		
		private var $environmentFile:String;
		
		/**
		 * Storage variable for diagnostics property.
		 * @private 
		 */	
		private var $diagnostics:Boolean = true;
		
		/**
		 * Class constructor.
		 * Creates a new YQL object.
		 */	
		public function YQL()
		{
			super();
			
			this.$hostname = YOSMethodBase.YQL_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Sends a single query to the YQL web service. 
		 * @param query			A string, using a SQL-like SELECT syntax. 
		 */		
		public function query(query:String):void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version);
			
			var requestHasConsumer:Boolean = (this.consumer != null);
			
			// switch to public/yql when there is no consumer.
			var yqlResource:String = (requestHasConsumer) ? "yql" : "public/yql"; 
			url.rawResource(yqlResource);
			
			var callback:Object = new Object();
			callback.success = handleExecuteQuerySuccess;
			callback.failure = handleExecuteQueryFailure;
			callback.security = handleSecurityError;
			
			var args:Object = this.getDefaultArguments();
			args.q = (requestHasConsumer) ? this.escapeQuery(query) : query; // oauth needs the query to be encoded correctly.
			args.diagnostics = this.diagnostics; 
			
			var method:String = URLRequestMethod.GET;
			
			// support YQL open data tables
			if(this.environmentFile) args.env = this.environmentFile;
			
			if(requestHasConsumer) {
				this.sendRequest(method, url.toString(), callback, args);
			}else{
				Connection.asyncRequest(method, url.toString(), callback, args);
			}
		}
		
		/**
		 * Determines if YQL will return a detailed diagnostics report within the response.
		 * @return 
		 * 
		 */		
		public function get diagnostics():Boolean
		{
			return $diagnostics;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set diagnostics(value:Boolean):void
		{
			$diagnostics = value;
		}
		
		/**
		 * The optional YQL environment file.
		 * @return 
		 * 
		 */		
		public function get environmentFile():String
		{
			return $environmentFile;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set environmentFile(value:String):void
		{
			$environmentFile = value;
		}
		
		/**
		 * Escapes and replaces all * characters from a YQL query
		 * @private 
		 * @param query			A string, using a SQL-like SELECT syntax.
		 * @return 
		 */		
		private function escapeQuery(query:String):String
		{
			var ret:String = escape(query);
			
			// replace any * with %2A
			var pattern:RegExp = /\x2a/g;
			ret = ret.replace(pattern,"%2A");
			
			return ret;
		}
		
		/**
		 * Handler method for the YQL success callback.
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleExecuteQuerySuccess(response:Object):void
		{
			var rsp:String = response.responseText;
			var json:Object = null;
			
			if(this.getResponseStatusOk(response.status)) {
				try {
					json = this.decodeJSON(rsp);
				} catch(error:JSONParseError) {
					handleExecuteQueryFailure(response);
					return;
				}
				
				//check for an error
				if(json.error)  {
					handleExecuteQueryFailure(response);
				} else {
					var query:Object = json.query;
					var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.YQL_QUERY_SUCCESS, query);
					this.dispatchEvent(event);
				}
			} else {
				handleExecuteQueryFailure(response);
			}
		}
		
		/**
		 * Handler method for the YQL failure/error callback.
		 * @private 
		 * @param response
		 * @param errorDesc
		 * 
		 */		
		private function handleExecuteQueryFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.YQL_QUERY_FAILURE, response);
			this.dispatchEvent(event);
		}
	}
}