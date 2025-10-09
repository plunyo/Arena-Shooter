package main

import (
	"log"

	"github.com/codecat/go-enet"
)

const (
	MAX_PEERS       uint64 = 32
	EVENT_POLL_TIME uint32 = 20
	LISTEN_PORT     uint16 = 30067
)

func main() {
	enet.Initialize()
	defer enet.Deinitialize()

	host, err := enet.NewHost(enet.NewListenAddress(LISTEN_PORT), MAX_PEERS, 1, 0, 0)
	if err != nil {
		log.Fatalf("Couldn't create host: %s", err)
	}
	defer host.Destroy()
	log.Println("Server running on port:", LISTEN_PORT)

	for {
		event := host.Service(EVENT_POLL_TIME)

		switch event.GetType() {
		case enet.EventNone: continue

		case enet.EventConnect:
			log.Printf("New peer connected: %s", event.GetPeer().GetAddress())

		case enet.EventDisconnect:
			log.Printf("Peer disconnected: %s", event.GetPeer().GetAddress())

		case enet.EventReceive:
			packet := event.GetPacket()
			log.Printf("Received %d bytes from %s", len(packet.GetData()), event.GetPeer().GetAddress())
			packet.Destroy()
		}
	}
}
