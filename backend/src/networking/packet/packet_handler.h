#pragma once

#include <stddef.h>
#include <stdint.h>
#include <enet/enet.h>
#include "networking/packet/game_packet.h"
#include "networking/replication/replication.h"

void SendPacket(ENetPeer* peer, const GamePacket* packet, enet_uint32 flags);
void HandlePacket(ReplicationContext* ctx, ENetPeer* peer, uint8_t* data, size_t dataLength);