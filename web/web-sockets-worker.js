var webSocket;
const broadcast = new BroadcastChannel("background-message");

function connect(url, ticket) {
  webSocket = new WebSocket(`${url}?ticket=${ticket}`);

  webSocket.onopen = () => {
    console.log("websocket open");
    webSocket.send(JSON.stringify({ "@type": "WebSocketPushEnable" }));
  };

  webSocket.onmessage = (event) => {
    console.log(`websocket received message: ${event.data}`);
    broadcast.postMessage(event.data);
  };

  webSocket.onclose = (event) => {
    console.log(
      `websocket connection closed with code: "${event.code}" reason: "${event.reason}" and cleanly: "${event.wasClean}"`
    );
    broadcast.postMessage("webSocketClosed");
    webSocket = null;
  };
}

function disconnect() {
  if (webSocket == null) {
    return;
  }
  webSocket.close();
}

self.addEventListener("install", (event) => {
  self.skipWaiting().then(() => {
    console.log("Service worker installed");
  });
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    self.clients.claim().then(() => {
      console.log("Service worker activated");
    })
  );
});

self.addEventListener("message", (event) => {
  console.log(`web socket worker received message: ${event.data}`);
  if (event.data.action === "connect") {
    connect(event.data.url, event.data.ticket);
  } else if (event.data.action === "disconnect") {
    disconnect();
  }
});
