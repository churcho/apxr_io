// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket(window.wsEndpoint, {
  params: {token: window.wsToken}, opts: {transport: "Websocket"}})

if ((/experiments/.test(window.location.href)) && (/^((?!all).)*$/.test(window.location.href))) {
  socket.connect()

  let channel           = socket.channel("experiment", {})
  let messagesContainer = document.querySelector("#exp_log_messages")

  channel.on("log", payload => {
    let messageItem = document.createElement("li")
    messageItem.innerText = `[${Date()}] ${payload.body}`
    messagesContainer.appendChild(messageItem)
  })

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default socket