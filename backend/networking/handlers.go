package networking

import (
	"encoding/binary"

	"github.com/codecat/go-enet"
)

func ParsePlayerPacket(peer enet.Peer, packet []byte) {
	if len(packet) < 1 {
		return
	}

	packetID := ClientPacket(packet[0])
	data := packet[1:]

	switch packetID {
	case ClientJoin: handleClientJoin(peer, data)
	case ClientMove: handleClientMove(peer, data)
	}
}

func handleClientJoin(peer enet.Peer, data []byte) {
	if len(data) == 0 {
		return
	}

	username := string(data)

	if player, ok := players[peer]; ok {
		player.Username = username
	} else {
		AddPlayer(peer, username)
	}

	joinAcceptPacket := CreatePacket(ServerJoinAccept, []byte{})
	SendPacket(peer, joinAcceptPacket, enet.PacketFlagReliable)
}

func handleClientMove(peer enet.Peer, data []byte) {
	if len(data) < 8 {
		return
	}

	player, ok := players[peer]
	if !ok { return }

	posX := int32(binary.BigEndian.Uint32(data))
	posY := int32(binary.BigEndian.Uint32(data[4:]))

	player.PosX = posX
	player.PosY = posY
}
