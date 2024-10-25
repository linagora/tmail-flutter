importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");
// Initialize the Firebase app in the service worker by passing in the messagingSenderId.
firebase.initializeApp({
    apiKey: "...",
    authDomain: "...",
    databaseURL: "...",
    projectId: "...",
    storageBucket: "...",
    messagingSenderId: "...",
    appId: "...",
});
// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

const broadcast = new BroadcastChannel('background-message');

messaging.onBackgroundMessage((message) => {
    broadcast.postMessage(message);
});