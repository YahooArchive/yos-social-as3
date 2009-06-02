/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social.events
{
	import flash.events.Event;
	
	/**
	 * Event class for the Y! Social web service responses.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * 
	 */	
	public class YahooResultEvent extends Event
	{
		/**
		 * Constant defining the name of the event fired when a security error in encountered while attempting a data request.
		 * @see SecurityErrorEvent 
		 */		
		public static const SECURITY_ERROR:String = "securityError";
		
		/**
		 * Constant defining the name of the event fired when the <code>getImages</code> request completes successfully.
		 * @see Images
		 */		
		public static const GET_IMAGES_SUCCESS:String = "getImagesSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getImages</code> request encounters an error.
		 * @see Images
		 */		
		public static const GET_IMAGES_FAILURE:String = "getImagesFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getContacts</code> request completes successfully.
		 * @see Contacts
		 */		
		public static const GET_CONTACTS_SUCCESS:String = "getContactsSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getContacts</code> request encounters an error.
		 * @see Contacts
		 */		
		public static const GET_CONTACTS_FAILURE:String = "getContactsFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getStatus</code> request completes successfully.
		 * @see StatusRequest
		 */		
		public static const GET_STATUS_SUCCESS:String = "getStatusSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getStatus</code> request encounters an error.
		 * @see StatusRequest
		 */		
		public static const GET_STATUS_FAILURE:String = "getStatusFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getProfile</code> request completes successfully.
		 * @see Profile
		 */		
		public static const GET_PROFILE_SUCCESS:String = "getProfileSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getProfile</code> request encounters an error.
		 * @see Profile
		 */		
		public static const GET_PROFILE_FAILURE:String = "getProfileFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getConnectionProfiles</code> request completes successfully.
		 * @see Profile
		 */		
		public static const GET_CONNECTION_PROFILES_SUCCESS:String = "getConnectionProfilesSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getConnectionProfiles</code> request encounters an error.
		 * @see Profile
		 */		
		public static const GET_CONNECTION_PROFILES_FAILURE:String = "getConnectionProfilesFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getConnections</code> request completes successfully.
		 * @see Connections
		 */		
		public static const GET_CONNECTIONS_SUCCESS:String = "getConnectionsSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getConnections</code> request encounters an error.
		 * @see Connections
		 */		
		public static const GET_CONNECTIONS_FAILURE:String = "getConnectionsFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>listUpdates</code> request completes successfully.
		 * @see Updates
		 */		
		public static const GET_UPDATES_SUCCESS:String = "getUpdatesSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>listUpdates</code> request encounters an error.
		 * @see Updates
		 */		
		public static const GET_UPDATES_FAILURE:String = "getUpdatesFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>listConnectionUpdates</code> request completes successfully.
		 * @see Updates
		 */		
		public static const GET_CONNECTION_UPDATES_SUCCESS:String = "getConnectionUpdatesSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>listConnectionUpdates</code> request encounters an error.
		 * @see Updates
		 */		
		public static const GET_CONNECTION_UPDATES_FAILURE:String = "getConnectionUpdatesFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>query</code> request completes successfully.
		 * @see YQL 
		 */		
		public static const YQL_QUERY_SUCCESS:String = "yqlQuerySuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>query</code> request encounters an error.
		 * @see YQL 
		 */		
		public static const YQL_QUERY_FAILURE:String = "yqlQueryFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>setSmallView</code> request completes successfully.
		 * @see ApplicationRequest 
		 */		
		public static const SET_SMALL_VIEW_SUCCESS:String = "setSmallViewSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>query</code> request encounters an error.
		 * @see ApplicationRequest 
		 */		
		public static const SET_SMALL_VIEW_FAILURE:String = "setSmallViewFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getAccessToken</code> request completes.
		 * @see YahooAuthentication 
		 */		
		public static const GET_ACCESS_TOKEN_SUCCESS:String = "getAccessTokenSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getAccessToken</code> request encounters an error.
		 * @see YahooAuthentication 
		 */		
		public static const GET_ACCESS_TOKEN_FAILURE:String = "getAccessTokenFailure";
		
		/**
		 * Constant defining the name of the event fired when the <code>getAccessToken</code> request completes.
		 * @see YahooAuthentication 
		 */		
		public static const GET_REQUEST_TOKEN_SUCCESS:String = "getRequestTokenSuccess";
		
		/**
		 * Constant defining the name of the event fired when the <code>getAccessToken</code> request encounters an error.
		 * @see YahooAuthentication 
		 */		
		public static const GET_REQUEST_TOKEN_FAILURE:String = "getRequestTokenFailure";
		
		/**
		 * The event data object.
		 */		
		protected var $data:Object;
		
		/**
		 * Creates a new YahooEvent object.
		 * @param type
		 * @param data
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function YahooResultEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.$data = data;
		}
		
		/**
		 * The event data object. 
		 * @return 
		 * 
		 */		
		public function get data():Object
		{
			return $data;
		}
		
		/**
		 * The event data object.
		 * @param value
		 * 
		 */		
		public function set data(value:Object):void
		{
			this.$data = value;
		}
		
		/**
		 * Duplicates an instance of an YahooResultEvent class.
		 * @return
		 */
		override public function clone():Event
		{
			return new YahooResultEvent(type,data,bubbles,cancelable);
		}
		
		/**
		 * Returns a string containing all the properties of the Event object.
		 * @return
		 */ 
		override public function toString():String 
		{
			return formatToString("YahooResultEvent", "type", "data", "bubbles", "cancelable", "eventPhase");
		}
	}
}