/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var options,oauth;
var noteStoreURL, authTokenEvernote;

var evernoteAuthenticator = {
    consumerKey : 'sohocoke',
    consumerSecret : '80af1fd7b40f65d0',
    evernoteHostName : 'https://sandbox.evernote.com', // change this to https://www.evernote.com to switch to production
    // Application Constructor
    initialize: function() {
        this.bindEvents();

        this.setupOauth();
        this.fetchAccessToken(window.location.href);
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'evernoteAuthenticator.receivedEvent(...);'
    onDeviceReady: function() {
        evernoteAuthenticator.receivedEvent('deviceready');
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        var paramsText;
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
    },

     success: function(data) {
         var isCallBackConfirmed = false;
         var tempToken = '';
         var vars = data.text.split("&");
         for (var i = 0; i < vars.length; i++) {
             var y = vars[i].split('=');
             if(y[0] === 'oauth_token')  {
                 tempToken = y[1];
             }
             else if(y[0] === 'oauth_token_secret') {
                 this.oauth_token_secret = y[1];
                 localStorage.setItem("oauth_token_secret", y[1]);
             }
             else if(y[0] === 'oauth_callback_confirmed') {
                 isCallBackConfirmed = true;
             }
         }
         var ref;
         if(isCallBackConfirmed) {
             // step 2
             ref = window.location = evernoteAuthenticator.evernoteHostName + '/OAuth.action?oauth_token=' + tempToken;
             // ref.addEventListener('loadstart', function(event) {
                                  // });
             
         }
         else {
             var querystring = evernoteAuthenticator.getQueryParams(data.text);
             noteStoreURL = querystring.edam_noteStoreUrl;
             authTokenEvernote = querystring.oauth_token; 

             // authenticated and authorised.
             evernoteAuthenticator.postAuthenticationCallback();
         }
         
     },
    failure: function(error) {
        console.log('error ' + error.text);
    },
    setupOauth: function() {
        options = {
            consumerKey: evernoteAuthenticator.consumerKey,
            consumerSecret: evernoteAuthenticator.consumerSecret,
            // callbackUrl : "gotOAuth.html",
            callbackUrl : window.location.origin + window.location.pathname + "#/action=gotOAuth.html",
            signatureMethod : "HMAC-SHA1"
        };
        oauth = OAuth(options);
        evernoteAuthenticator.oauth = oauth;
    },
    loginWithEvernote: function() {
        // step 1
        evernoteAuthenticator.oauth.request({'method': 'GET', 'url': evernoteAuthenticator.evernoteHostName + '/oauth', 'success': evernoteAuthenticator.success, 'failure': evernoteAuthenticator.failure});
    },

    getQueryParams:function(queryParams) {
        var i, query_array,
        query_array_length, key_value, decode = OAuth.urlDecode,querystring = {};
        // split string on '&'
        query_array = queryParams.split('&');
        // iterate over each of the array items
        for (i = 0, query_array_length = query_array.length; i < query_array_length; i++) {
            // split on '=' to get key, value
            key_value = query_array[i].split('=');
            if (key_value[0] != "") {
                querystring[key_value[0]] = decode(key_value[1]);
            }
        }
        return querystring;
    },

    fetchAccessToken: function(loc) {
        //alert(event.type + ' - ' + event.url);
        if (loc.indexOf('oauth_token') >= 0) {
            var index, verifier = '';
            var got_oauth = '';
            var params = loc.substr(loc.indexOf('?') + 1);
            params = params.split('&');
            for (var i = 0; i < params.length; i++) {
                var y = params[i].split('=');
                if (y[0] === 'oauth_verifier') {
                    verifier = y[1];
                } else if (y[0] === 'oauth_token') {
                    got_oauth = y[1];
                }
            }

            // step 3
            evernoteAuthenticator.oauth.setVerifier(verifier);
            evernoteAuthenticator.oauth.setAccessToken([got_oauth, localStorage.getItem("oauth_token_secret")]);

            var getData = {
                'oauth_verifier': verifier
            };
            evernoteAuthenticator.oauth.request({
                'method': 'GET',
                'url': evernoteAuthenticator.evernoteHostName + '/oauth',
                'success': evernoteAuthenticator.success,
                'failure': evernoteAuthenticator.failure
            });

        } else {
            console.log("not ready to fetch access token.");
        }
    },

    listNotebooksAndCreateNewNote: function () {
         var noteStoreTransport = new Thrift.BinaryHttpTransport(noteStoreURL);
         var noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport);
         var noteStore = new NoteStoreClient(noteStoreProtocol);

         noteStore.listNotebooks(authTokenEvernote, function (notebooks) {
                                 console.log(notebooks);
                                 },
                                 function onerror(error) {
                                 console.log(error);
                                 });
         var note = new Note;
         note.content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\"><en-note><span style=\"font-weight:bold;\">Hello photo note.</span><br /><span>Evernote logo :</span><br /></en-note>";
         note.title = "Hello javascript lib";
         noteStore.createNote(authTokenEvernote,note,function (noteCallback) {
                              console.log(noteCallback.guid + " created");
                              });
    },

    postAuthenticationCallback: function() {
        this.listNotebooksAndCreateNewNote();
    }
};

