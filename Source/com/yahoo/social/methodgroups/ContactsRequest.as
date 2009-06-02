/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.methodgroups
{
	import com.adobe.serialization.json.JSONParseError;
	import com.yahoo.social.YahooUser;
	import com.yahoo.social.events.YahooResultEvent;
	import com.yahoo.social.utils.YahooURL;
	
	import flash.net.URLRequestMethod;
	
	/**
	* Dispatched when the getContacts request executes successfully.
	*/	
	[Event(name="getContactsSuccess", type="YahooResultEvent")]
	
	/**
	* Dispatched when the getContacts request fails.
	*/	
	[Event(name="getContactsFailure", type="YahooResultEvent")]
	
	/**
	 * A wrapper for the Connections API. 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see http://developer.yahoo.com/social/rest_api_guide/contact_api.html
	 * @example 
	 * <listing version="3.0">
	 *  // retrieve the sessioned user
	 * 	var user:YahooUser = _session.getSessionedUser();
	 * 	
	 * 	// add contacts response event listeners
	 * 	user.contacts.addEventListener(YahooResultEvent.GET_CONTACTS_SUCCESS, handleContactsSuccess);
	 * 	user.contacts.addEventListener(YahooResultEvent.GET_CONTACTS_FAILURE, handleContactsFailure);
	 * 	user.contacts.getContacts();
	 * 
	 * 	function handleContactsSuccess(event:YahooResultEvent):void
	 * 	{
	 * 		var contacts:Array = event.data as Array;
	 * 		// do something
	 * 	}
	 * 
	 * 	function handleContactsFailure(event:YahooResultEvent):void
	 * 	{
	 * 		// there was an error fetching the data
	 *      // do something		
	 * 	}
	 * </listing>
	 */	
	public class ContactsRequest extends YOSMethodBase
	{
		/**
		 * Class constructor.
		 * Creates a new ContactsRequest object for the provided user. 
		 * 
		 */	
		public function ContactsRequest()
		{
			super();
			this.$hostname = YOSMethodBase.SOCIAL_WS_HOSTNAME;
			this.$useExplicitEncoding = false;
		}
		
		/**
		 * Gets a list of contacts for the current user. (sessioned user only)
		 * 
		 * @example 
		 * <listing version="3.0">
		 * 
		 * </listing>
		 */		
		public function getContacts(start:int=0, count:int=10):void
		{
			if(!this.$user.sessioned)
			{
				throw new Error("Cannot get contacts for an unsessioned user");
				return;
			}
			
			var url:YahooURL = new YahooURL("http", this.$hostname);
			url.rawResource(this.$version+"/user");
			url.resource(this.$user.guid);
			url.rawResource("contacts");
			
			var args:Object = this.getDefaultArguments();
			args.view = "tinyusercard";
			args.start = start;
			args.count = 10;
			
			var callback:Object = new Object();
			callback.success = handleGetContactsSuccess;
			callback.failure = handleGetContactsFailure;
			callback.security = handleSecurityError;
			
			this.sendRequest(URLRequestMethod.GET, url.toString(), callback, args);
		}
		
		/**
		 * @private
		 * @param response
		 * 
		 */		
		private function handleGetContactsSuccess(response:Object):void
		{
			var rsp:String = response.responseText;
			var json:Object = null;
			var contacts:Array = new Array();
			
			if(this.getResponseStatusOk(response.status))
			{
				try
				{
					json = this.decodeJSON(rsp);
				}
				catch(error:JSONParseError)
				{
					handleGetContactsFailure(response);
					return;
				}
				
				if(json.error)
				{
					handleGetContactsFailure(response);
				}
				
				var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONTACTS_SUCCESS, json.contacts);
				this.dispatchEvent(event);
			}
			else
			{
				handleGetContactsFailure(response);
			}
		}
		
		/**
		 * @private
		 * @param response
		 * 
		 */		
		private function handleGetContactsFailure(response:Object):void
		{
			var event:YahooResultEvent = new YahooResultEvent(YahooResultEvent.GET_CONTACTS_FAILURE, response);
			this.dispatchEvent(event);
		}
		
	}
}