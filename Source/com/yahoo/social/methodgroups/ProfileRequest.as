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
	* Dispatched when the loadProfile request executes successfully.
	*/	
	[Event(name="getProfileSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the loadProfile request fails.
	*/	
	[Event(name="getProfileFailure", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getConnectionProfiles request executes successfully.
	*/	
	[Event(name="getConnectionProfilesSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getConnectionProfiles request fails.
	*/	
	[Event(name="getConnectionProfilesFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper for the Profiles API. 
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/social/rest_api_guide/extended-profile-resource.html
	 * @example 
	 * <listing version="3.0">
	 * 	// retrieve the sessioned user
	 * 	var user:YahooUser = _session.getSessionedUser();
	 * 	
	 * 	// add profile response event listeners
	 * 	user.profile.addEventListener(YahooResultEvent.GET_PROFILE_SUCCESS, handleGetProfileSuccess);
	 * 	user.profile.addEventListener(YahooResultEvent.GET_PROFILE_FAILURE, handleGetProfileFailure);
	 * 	user.profile.getPresence();
	 * 
	 * 	function handleGetProfileSuccess(event:YahooResultEvent):void
	 * 	{
	 * 		var profile:Object = event.data;
	 * 		// do something
	 * 	}
	 * 
	 * 	function handleGetProfileFailure(event:YahooResultEvent):void
	 * 	{
	 * 		// there was an error fetching the data
	 *      // do something	
	 * 	}
	 * </listing>
	 */	
	public class ProfileRequest extends YOSMethodBase
	{
		/**
		 * The resource type determines the kind of profile information returned. Default is null (extended profile).
		 * 
		 * Acceptable values are <code>tinyusercard</code>, <code>usercard</code>, <code>idcard</code>, <code>works</code> and <code>schools</code>.
		 */		
		public var type:String = null;
		
		/**
		 * Class constructor.
		 * Creates a new ProfileRequest object for the provided user. 
		 * 
		 */
		public function ProfileRequest()
		{
			super();
			this.$hostname = YOSMethodBase.SOCIAL_WS_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Loads the profile information for this user. 
		 * 
		 */		
		public function getProfile():void
		{
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version+"/user");
			url.resource(this.$user.guid);
			url.rawResource("profile");
			
			if(type) url.resource(type);
			
			var args:Object = this.getDefaultArguments();
			
			var callback:Object = new Object();
			callback.success = handleGetProfileSuccess;
			callback.failure = handleGetProfileFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
		
		/**
		 * @private 
		 * @param response
		 * 
		 */		
		private function handleGetProfileSuccess(response:Object):void
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
					handleGetProfileFailure(response);
					return;
				}
				
				if(json.error)
				{
					handleGetProfileFailure(response);
				}
				else
				{
					var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_PROFILE_SUCCESS, json.profile);
					this.dispatchEvent(event);
				}
			}
			else
			{
				handleGetProfileFailure(response);
			}
		}
	    
		/**
		 * @private 
		 * @param response
		 * 
		 */	    
		private function handleGetProfileFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_PROFILE_FAILURE, response);
			this.dispatchEvent(event);
		}
		
		/**
		 * Retrieves the profiles of all the users connections. 
		 * @param start		Defines the starting point of the search.
		 * @param count		Defines the number of profiles to return.
		 * 
		 */				
		public function getConnectionProfiles(start:int=0, count:int=10):void
		{
			var page:Array = [start,count];
			
			var yql:YQL = new YQL();
			yql.user = this.user;
			yql.addEventListener(YahooResultEvent.YQL_QUERY_SUCCESS, handleConnectionProfilesSuccess);
			yql.addEventListener(YahooResultEvent.YQL_QUERY_FAILURE, handleConnectionProfilesFailure);
			
			var join:String = "select guid from social.connections("+page.join(",")+") where owner_guid=\""+$user.guid+"\"";
			yql.query("select * from social.profile where guid in ("+join+")");
		}
		
		/**
		 * @private
		 * @param event
		 * 
		 */		
		private function handleConnectionProfilesSuccess(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTION_PROFILES_SUCCESS, response.data.results);
			this.dispatchEvent(event);
		}
		
		/**
		 * 
		 * @private
		 * @param event
		 * 
		 */		
		private function handleConnectionProfilesFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONNECTION_PROFILES_FAILURE, response);
			this.dispatchEvent(event);
		}
	}
}