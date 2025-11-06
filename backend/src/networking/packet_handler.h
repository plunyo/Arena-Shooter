#pragma once

#include <stddef.h>
#include <stdint.h>
#include <enet/enet.h>
#include "networking/game_packet.h"

void SendPacket(ENetPeer* peer, const GamePacket* packet, enet_uint32 flags);
void HandlePacket(ENetPeer* peer, const uint8_t* data, size_t dataLength);