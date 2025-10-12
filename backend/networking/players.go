package networking

import (
	"github.com/codecat/go-enet"
)

type Player struct {
	Username string
	PosX     int32
	PosY     int32
}

var players = make(map[enet.Peer]*Player)

func AddPlayer(peer enet.Peer, username string) {
	players[peer] = &Player{
		Username: username,
		PosX:     0,
		PosY:     0,
	}
}

func RemovePlayer(peer enet.Peer) {
	delete(players, peer)
}

func SendPacket(peer enet.Peer, packet Packet, flag enet.PacketFlags) {
	peer.SendBytes(packet.ToRaw(), 0, flag)
}

func ParsePlayerPacket(peer enet.Peer, packet []byte) {
	if len(packet) < 1 { return }

	packetID := ClientPacket(packet[0])
	data := packet[1:]

	switch packetID {
	case ClientJoin:
		if len(data) == 0 { return }

		if p, ok := players[peer]; ok {
			p.Username = string(data)
		} else {
			AddPlayer(peer, string(data))
		}

		joinAcceptPacket := CreatePacket(ServerJoinAccept, []byte{})
		SendPacket(peer, joinAcceptPacket, enet.PacketFlagReliable)
	}
}

func GetPlayer(peer enet.Peer) (*Player, bool) {
	p, ok := players[peer]
	return p, ok
}
