package networking

import "github.com/codecat/go-enet"

type PacketID = uint8

type ClientPacket = PacketID
const (
	ClientJoin ClientPacket = iota
	ClientMove
	ClientRequestSync
	ClientChat
)

type ServerPacket = PacketID
const (
	ServerJoinAccept ServerPacket = iota
	ServerJoinDeny
	ServerUpdatePlayers
	ServerPlayerSync
	ServerUpdateChat
)

type Packet struct {
	Id PacketID
	Data []byte
}

func (p Packet) ToRaw() []byte {
	rawPacket := make([]byte, 1, 1+len(p.Data))

	rawPacket[0] = byte(p.Id)
    rawPacket = append(rawPacket, p.Data...)

    return rawPacket	
}		

func CreatePacket(packetId uint8, data []byte) Packet {
	return Packet{ Id: packetId, Data: data }
}

func SendPacket(peer enet.Peer, packet Packet, flags enet.PacketFlags) {
	peer.SendBytes(packet.ToRaw(), 0, flags)
}

