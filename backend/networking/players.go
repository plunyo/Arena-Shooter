package networking

import (
	"github.com/codecat/go-enet"
)

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

func GetPlayer(peer enet.Peer) (*Player, bool) {
	p, ok := players[peer]
	return p, ok
}
