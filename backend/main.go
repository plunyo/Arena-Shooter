package main

import (
	"log"
	"social_server/networking"

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
	if err != nil { log.Fatalf("Couldn't create host: %s", err) }
	defer host.Destroy()

	log.Println("Server running on port:", LISTEN_PORT)

	for {
		event := host.Service(EVENT_POLL_TIME)

		switch event.GetType() {
		case enet.EventNone: continue

		case enet.EventConnect:
			peer := event.GetPeer()
			log.Printf("New peer with id %d connected: %s", peer.GetConnectId(), peer.GetAddress())

		case enet.EventDisconnect:
			networking.RemovePlayer(event.GetPeer())
			log.Printf("Peer disconnected: %s", event.GetPeer().GetAddress())

		case enet.EventReceive:
			packet := event.GetPacket()
			networking.ParsePlayerPacket(event.GetPeer(), packet.GetData())
			packet.Destroy()
		}
	}
}
