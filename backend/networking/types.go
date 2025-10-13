package networking

import "github.com/codecat/go-enet"

type Player struct {
	Username string
	PosX     int32
	PosY     int32
}

var players = make(map[enet.Peer]*Player)
