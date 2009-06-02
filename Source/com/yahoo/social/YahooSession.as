/*
	Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
	The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.social
{
	import com.yahoo.oauth.OAuthConsumer;
	import com.yahoo.oauth.OAuthToken;
	import com.yahoo.social.methodgroups.ApplicationRequest;
	import com.yahoo.social.methodgroups.AuthorizationRequest;
	import com.yahoo.social.methodgroups.YQL;
	import com.yahoo.social.utils.IYahooSessionStore;
	import com.yahoo.social.utils.YahooSessionStore;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	/**
	 * The YahooSession object defines a session between an application and the Yahoo! Platform. 
	 * It is the gateway to accessing user information with the Yahoo! Social APIs.
	 * 
	 * @author Zach Graves (zachg@yahoo-inc.com)
	 * @see AuthenticationRequest
	 * @example 
	 * <listing version="3.0">
	 *  // create a yahoo session object and pass 
	 *  //into it the oauth credentials, appid and a guid
	 *  var session:YahooSession = new YahooSession('consumerKey', 'consumerSecret', 'appid');
	 * </listing>
	 * 
	 */	
	public class YahooSession extends EventDispatcher
	{
		/**
		 * A string containing the connectionName set in the <code>localConnection</code> object. 
		 * @private 
		 */		
		private static const LOCAL_CONNECTION_NAME:String = "_yapFlashProxy";
		
		/**
		 * 
		 * @private
		 */
		private var $yql:YQL;
		
		/**
		 * 
		 * @private
		 */
		private var $application:ApplicationRequest;
		
		/**
		 * 
		 * @private 
		 */		
		private var $auth:AuthorizationRequest;
		
		/**
		 * The OAuthConsumer object containing the key / secret for this application.
		 * @private 
		 */		
		private var $consumer:OAuthConsumer;
		
		/**
		 * The OAuthToken object containing the access token key / secret for this application and user.
		 * @private 
		 */		
		private var $accessToken:OAuthToken;
		
		/**
		 * The OAuthToken object containing the request token key / secret for this application and user.
		 * @private 
		 */		
		private var $requestToken:OAuthToken;
		
		/**
		 * The application for this session.
		 * @private 
		 */		
		private var $applicationId:String;
		
		/**
		 * The guid of the owning user.
		 */		
		public var ownerGuid:String;
		
		/**
		 * The guid of the viewing user.
		 */		
		public var viewerGuid:String;
		
		/**
		 * The LocalConnection object used to communicate with the YAP bridge swf.
		 * @private
		 */		
		private var $local:LocalConnection;
		
		/**
		 * Storage property for an IYahooSessionStore implementation. 
		 * @private
		 */		
		private var $sessionStore:IYahooSessionStore;
		
		/**
		 *  
		 * @param consumerKey
		 * @param consumerSecret
		 * @param applicationId
		 * @param accessTokenKey
		 * @param accessTokenSecret
		 * @param viewerGUID
		 * @return 
		 * 
		 */		
		public static function sessionFromYAP(consumerKey:String, 
											  consumerSecret:String, 
											  applicationId:String, 
											  accessTokenKey:String, 
											  accessTokenSecret:String, 
											  viewerGUID:String):YahooSession
		{
			var session:YahooSession = new YahooSession(consumerKey, consumerSecret, applicationId);
			
			var accessToken:OAuthToken = new OAuthToken(accessTokenKey, accessTokenSecret);
			accessToken.consumer = consumerKey;
			accessToken.guid = viewerGUID;
			
			session.setAccessToken(accessToken);
			
			return session;
		} 
		
		/**
		 * Creates a new YahooSession object.
		 * 			
		 * @param consumerKey					A String containing the OAuth consumer key. (API Key)
		 * @param consumerSecret				A String containing the OAuth consumer secret.
		 * @param applicationId					A String containing the application ID to identify this session.
		 * @param sessionStore					An optional implementation of <code>IYahooSessionStore</code> used to cache OAuth tokens.
		 * 
		 * <strong>Note:</strong> An access token key/secret must be obtained by a server-side component or via the 
		 * <code>auth</code> property of YahooSession.
		 * 
		 */		
		public function YahooSession(consumerKey:String, consumerSecret:String, applicationId:String, sessionStore:IYahooSessionStore=null)
		{
			super();
			
			this.$consumer = new OAuthConsumer(consumerKey, consumerSecret);
			
			if($consumer.empty) throw new Error("Consumer key and/or secret must not have empty or null values.");
			
			// create the default session store if none was provided.
			if(!sessionStore) sessionStore = new YahooSessionStore();
			
			this.$sessionStore = sessionStore;
			
			this.$auth = AuthorizationRequest.fromSession(this);
			
			this.$yql = new YQL();
			this.$yql.consumer = $consumer;
			
			this.$application = new ApplicationRequest();
			this.$application.consumer = $consumer;
		}
		
		/**
		 * The instance of the ApplicationRequest API for this session. 
		 * @return 
		 * 
		 */		
		public function get application():ApplicationRequest
		{
			return this.$application;
		}
		
		/**
		 * The instance of the YQL API for this session. 
		 * @return 
		 * 
		 */		
		public function get yql():YQL
		{
			return this.$yql;
		}
		
		/**
		 * The instance of the AuthorizationRequest request object for the consumer of this session. 
		 * @return 
		 * 
		 */		
		public function get auth():AuthorizationRequest
		{
			return $auth;
		}
		
		/**
		 * The implementation of IYahooSessionStore attached to this session.
		 * @return 
		 * @default YahooSessionStore
		 * @see YahooSessionStore
		 * @see IYahooSessionStore
		 */		
		public function get sessionStore():IYahooSessionStore
		{
			return $sessionStore;
		}
		
		/**
		 * @private
		 * @param value
		 * 
		 */		
		public function set sessionStore(value:IYahooSessionStore):void
		{
			$sessionStore = value;
		}
		
	//--------------------------------------
	//  Public methods
	//--------------------------------------
		
		/**
		 * The OAuthToken object for this session.
		 * @see OAuthToken
		 * @return 
		 */		
		public function getAccessToken():OAuthToken
		{
			return this.$accessToken;
		}
		
		/**
		 * Sets the session access token object. 
		 * 
		 * If the token contains a GUID, this function will over-ride the <code>YahooSession.YAP_VIEWER</code> value 
		 * with the guid defined by the token.
		 * 
		 * <p>The function will also check if the token expiration time has approached. 
		 * If it is expired it will return false. At this point you should request a new access token.</p>
		 * 
		 * <p>If the consumer key does not match the consumer key found in the access token it will return false
		 * and not set the session.</p>
		 * 
		 * @param token An OAuthToken object containing the access token and secret.
		 * @return A Boolean True if the token is valid. 
		 * 
		 */		 
		public function setAccessToken(token:OAuthToken):Boolean
		{
			// check if the session consumer key and access token consumer match
			// if not, the consumer key has changed in the
			// app and the token is now invalid
			var consumerKeyMatch:Boolean = ($consumer.key == token.consumer);
			
			// check if the token is expired
			// if so, the developer will need to use this 
			// now old token to request a new one.
			var isExpired:Boolean = AuthorizationRequest.checkExpires(token);
			
			if(!token.empty && consumerKeyMatch && !isExpired)
			{
				this.$accessToken = token;
				this.viewerGuid = token.guid;
				
				// a pretty awesome undocumented event. have fun.
				this.dispatchEvent(new Event("SESSION_ACCESS_TOKEN_CHANGE"));
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Saves the session's request and access token to the token store.
		 * @return 
		 */		
		public function saveSession():void
		{
			if($sessionStore)
			{
				if($accessToken) this.sessionStore.setAccessToken($accessToken);
				if($requestToken) this.sessionStore.setRequestToken($requestToken);
			}
		}
		
		/**
		 * Clears the session access token and removes all tokens from the session store.
		 * @return
		 */		
		public function clearSession():void
		{
			this.$accessToken = null;
			this.$requestToken = null;
			
			this.dispatchEvent(new Event("SESSION_ACCESS_TOKEN_CHANGE"));
			
			if(this.$sessionStore) $sessionStore.clearSessionToken();
		}
		
		/**
		 * The OAuthConsumer object for this application.
		 * @see OAuthConsumer
		 * @return 
		 */		
		public function getConsumer():OAuthConsumer
		{
			return this.$consumer;
		}
		
		/**
		 * Returns a YahooUser object representing the currently sessioned user (the viewer of the application) 
		 * defined by <code>YahooSession.YAP_VIEWER</code> or the OAuth access token.
		 * @see YahooUser
		 * @return 
		 */		
		public function getSessionedUser():YahooUser
		{
			// might want to make this a class-level var that is set whenever the access token is updated 
			return ($accessToken.guid) ? new YahooUser(this, $accessToken.guid) : null;
		}
		
		/**
		 * Returns a YahooUser object representing the profile owner defined by 
		 * <code>YahooSession.YAP_OWNER</code> or the OAuth access token.
		 * 
		 * Only valid when a owner GUID is supplied by YAP, otherwise will 
		 * default to the logged-in user.
		 * @see YahooUser
		 * @return 
		 */	
		public function getOwner():YahooUser
		{
			// might want to make this a class-level var that is set whenever the access token is updated
			return ($accessToken.owner) ? getUser($accessToken.owner) : this.getSessionedUser();
		}
		
		/**
		 * Gets the user indicated by the GUID given. 
		 * @param guid 			The GUID of the user to get.
		 * @return YahooUser 	The user indicated by the GUID given.
		 * @see YahooUser
		 */		
		public function getUser(guid:String):YahooUser
		{
			return new YahooUser(this, guid);
		}
		
		/**
		 * Directs the container to open the yml:share dialog. 
		 * 
		 * Only valid in applications within YAP.
		 * 
		 * @param to_guids			An array of GUIDs in which this message should be addressed to.
		 * @param subject			The message subject.
		 * @param body				The message body.
		 * @param image				A URL to an image to show in the dialog.
		 * 
		 */		
		public function openShareDialog(to_guids:Array=null, subject:String=null, body:String=null, image:String=null):void
		{	
			this.lcDialogCall("yml_openShareDialog", to_guids, subject, body, image);
		}
		
		/**
		 * Directs the container to open the yml:message dialog. 
		 * 
		 * Only valid in applications within YAP.
		 *  
		 * @param to_guids			An array of GUIDs in which this message should be addressed to.
		 * @param subject			The message subject.
		 * @param body				The message body.
		 * @param image				A URL to an image to show in the dialog.
		 * 
		 */		
		public function openMessageDialog(to_guids:Array=null, subject:String=null, body:String=null, image:String=null):void
		{
			this.lcDialogCall("yml_openMessageDialog", to_guids, subject, body, image);
		}
		
		/* UPCOMING *********************************************************************************
		/**
		 * Opens or replaces a window in the application that contains the Flash Player container (usually a browser). 
		 * @param url		The URL to browse to. (HTTP protocol must be specified as either 'http' or 'https')
		 * @param window 	The browser window or HTML frame in which to display the document indicated by the request parameter.
		 * 
		 */		
		/* UPCOMING *********************************************************************************
		public function navigateToURL(url:String, window:String=null):void
		{
			var method:String = "navigateToURL";
			getLocalConnection().send(getLocalConnectionName(), method, url, window);
		}
		
		/* UPCOMING *********************************************************************************
		public function navigateToView(view:String, mode:String=null, content:String=null):void
		{
			var method:String = "navigateToView";
			getLocalConnection().send(getLocalConnectionName(), method, view, mode, content);
		}
		*********************************************************************************************/
		
	//--------------------------------------
	//  Private methods
	//--------------------------------------
		
		/**
		 * Returns the unique-to-application name of the local connection.
		 * @private 
		 * @return 
		 * 
		 */		
		private function getLocalConnectionName():String
		{
			// todo: add a timestamp to allow multiple instances of an app.
			return LOCAL_CONNECTION_NAME+"-"+$applicationId;
		}
		
		/**
		 * Returns the name of the LocalConnection to connect to. 
		 * @return 
		 * 
		 */		
		private function getLocalConnection():LocalConnection
		{
			if(!$applicationId || $applicationId.length==0) 
				throw new Error("Required application ID string is null or empty. Set YahooSession.YAP_APPID to a non-null value.");
			
			// this will ensure you create the LocalConnection 
			// once and only when you need it.
			if(!$local)  {
				var domainPolicy:String = "*";
				
				$local = new LocalConnection();
				$local.allowDomain(domainPolicy);
				$local.client = this;
				$local.addEventListener(StatusEvent.STATUS, handleLocalStatus);
				$local.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleAsyncError);
			}
			
			return $local;
		}
		
		/**
		 * Calls a method on a LocalConnection given a method and required parameters.
		 * 
		 * @private 
		 * @param method
		 * @param to_guids
		 * @param subject
		 * @param body
		 * @param image
		 * 
		 */		
		private function lcDialogCall(method:String,to_guids:Array=null, subject:String=null, body:String=null, image:String=null):void
		{
			subject = (subject) ? subject : "";
			body = (body) ? body : "";
			getLocalConnection().send(getLocalConnectionName(), method, to_guids, subject, body, image);
		}
		
		/**
		 * Clones and dispatches the AsyncErrorEvent from the local connection.
		 * @private 
		 * @param event
		 * 
		 */		
		private function handleAsyncError(event:AsyncErrorEvent):void
		{
			this.dispatchEvent(event.clone());
		}
		
		/**
		 * Clones and dispatches the StatusEvent from the local connection.
		 * @param event
		 * 
		 */		
		private function handleLocalStatus(event:StatusEvent):void
		{
			this.dispatchEvent(event.clone());
		}		
	}
}