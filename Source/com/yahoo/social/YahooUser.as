/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social
{
	import com.yahoo.oauth.OAuthToken;
	import com.yahoo.social.methodgroups.ConnectionsRequest;
	import com.yahoo.social.methodgroups.ContactsRequest;
	import com.yahoo.social.methodgroups.ProfileRequest;
	import com.yahoo.social.methodgroups.StatusRequest;
	import com.yahoo.social.methodgroups.UpdatesRequest;
	import com.yahoo.social.methodgroups.YQL;
	
	/**
	 * YahooUser contains the session and guid properties of a Yahoo user and the methods to query data from Profiles, Social Directory, Presence and Vitality.
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @example 
	 * <listing version="3.0">
	 *  // create a yahoo session object and pass into it the OAuth credentials, appid and a guid
	 *  YahooSession.YAP_VIEWER = "12345";
	 *  YahooSession.YAP_OWNER = "67890"
	 *  YahooSession.YAP_APPID = "your-appid";
	 *  
	 *  var session:YahooSession = new YahooSession('$consumerKey', '$consumerSecret', '$accessToken', '$accessTokenSecret');
	 *  
	 *  // retrieve the sessioned user
	 *  var user:YahooUser = session.getSessionedUser();
	 * </listing>
	 */	
	public class YahooUser
	{
		/**
		 * The language code query parameter used in all requests by an API method attached to this user.
		 * 
		 * The language code must conform to RFC 4646. 
		 * 
		 * <p>
		 * Examples language codes: 
		 * <ul>
		 * <li>en-US (United States English)</li> 
		 * <li>zh-Hans (Simplified Chinese)</li> 
		 * <li>en-GB (British English)</li>
		 * </ul>
		 * </p> 
		 * 
		 * <p>The default value is <code>en-US</code></p>
		 * 
		 * @see http://developer.yahoo.com/social/rest_api_guide/web-services-i18n.html#web-services-lang-country
		 * @see http://www.ietf.org/rfc/rfc4646.txt  
		 * 
		 * @example
		 * <listing version="3.0">
		 *  var user:YahooUser = _session.getSessionedUser();
		 *  user.lang = "fr-CA";
		 * </listing>
		 */		
		public var lang:String = "en-US";
		
		/**
		 * The region code query parameter represents a country territory in all requests by an API method attached to this user.
		 *
		 * The region code must conform to an ISO 3166-1 alpha-2 country code.
		 * 
		 * <p>
		 * Example regions codes: 
		 * <ul>
		 * <li>DE (Germany)</li>
		 * <li>CN (China)</li>
		 * <li>HK (Hong Kong)</li>
		 * <li>PR (Puerto Rico)</li>
		 * <li>US (United States)</li>
		 * </ul>
		 * </p> 
		 * 
		 * <p>The default value is <code>en-US</code></p>
		 * 
		 * @see http://developer.yahoo.com/social/rest_api_guide/web-services-i18n.html#web-services-region
		 * @see http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2  
		 * 
		 * @example
		 * <listing version="3.0">
		 *  var user:YahooUser = _session.getSessionedUser();
		 *  user.region = "DE";
		 * </listing>
		 */		
		public var region:String = "US";
		
		/**
		 * @private 
		 */		
		private var $session:YahooSession;
		
		/**
		 * @private 
		 */		
		private var $guid:String;
		
		/**
		 * @private 
		 */		
		private var $connections:ConnectionsRequest;
		
		/**
		 * @private 
		 */		
		private var $contacts:ContactsRequest;
		
		/**
		 * @private 
		 */	
		private var $status:StatusRequest;
		
		/**
		 * @private 
		 */		
		private var $profile:ProfileRequest;
		
		/**
		 * @private 
		 */		
		private var $updates:UpdatesRequest;
		
		/**
		 * @private 
		 */		
		private var $yql:YQL
		
		/**
		 * Class constructor.
		 * Creates a new YahooUser object.
		 * 
		 * This should not be called directly, but through the <code>getUser</code> or <code>getSessionedUser</code> methods of YahooSession. 
		 * This is in order to provide session and authentication information to the API methods attached to this user.
		 * 
		 * @see YahooSession.
		 *  
		 * @param session		A YahooSession object.
		 * @param guid			The GUID of the user.
		 */		 
		public function YahooUser(session:YahooSession, guid:String)
		{
			super();
			
			this.$session = session;
			this.$guid = guid;
			
			this.$connections = new ConnectionsRequest();
			this.$connections.user = this;
			
			this.$contacts = new ContactsRequest();
			this.$contacts.user = this;
			
			this.$status = new StatusRequest();
			this.$status.user = this;
			
			this.$profile = new ProfileRequest();
			this.$profile.user = this;
			
			this.$updates = new UpdatesRequest();
			this.$updates.user = this;
			
			this.$yql = new YQL();
			this.$yql.user = this;
		}
		
	//--------------------------------------
	//  Public functions
	//--------------------------------------
		
		/**
		 * Sets the small view for this user.
		 * 
		 * Supports only HTML and YML Lite
		 * 
		 * @param content		HTML and YML Lite contents.
		 */		
		public function setSmallView(content:String):void
		{
			this.$session.application.setSmallView(this.guid,content);
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * Returns a boolean, true if this user is the currently sessioned viewer of the app. 
		 * @return 
		 * 
		 */		
		public function get sessioned():Boolean
		{
			var accessToken:OAuthToken = this.$session.getAccessToken();
			return (accessToken && accessToken.guid == this.$guid);
		}
		
		/**
		 * The global YahooSession object. 
		 * @return 
		 * 
		 */		
		public function get session():YahooSession
		{
			return this.$session;
		}
		
		/**
		 * The GUID of this user, a 26-character string which represents a Yahoo! user. 
		 * 
		 * @return 
		 * @see http://developer.yahoo.com/social/rest_api_guide/web-services-guids.html
		 */		
		public function get guid():String
		{
			return this.$guid;
		}
		
	//--------------------------------------
	//  Method group accessors
	//--------------------------------------
		
		/**
		 * The instance of the ConnectionsRequest API for this user.
		 * @see ConnectionsRequest 
		 * @return 
		 * 
		 */		
		public function get connections():ConnectionsRequest
		{
			return this.$connections;
		}
		
		/**
		 * The instance of the ContactsRequest API for this user.
		 * @see ContactsRequest  
		 * @return 
		 * 
		 */		
		public function get contacts():ContactsRequest
		{
			return this.$contacts;
		}
		
		/**
		 * The instance of the StatusRequest API for this user.
		 * @see StatusRequest  
		 * @return 
		 * 
		 */		
		public function get status():StatusRequest
		{
			return this.$status;
		}
		
		/**
		 * The instance of the ProfileRequest API for this user.
		 * @see ProfileRequest  
		 * @return 
		 * 
		 */		
		public function get profile():ProfileRequest
		{
			return this.$profile;
		}
		
		/**
		 * The instance of the UpdatesRequest API for this user.
		 * @see UpdatesRequest  
		 * @return 
		 * 
		 */		
		public function get updates():UpdatesRequest
		{
			return this.$updates;
		}
		
		/**
		 * The instance of the YQL API for this user. 
		 * @see YQL
		 * @return 
		 * 
		 */		
		public function get yql():YQL
		{
			return this.$yql;
		}
	}
}