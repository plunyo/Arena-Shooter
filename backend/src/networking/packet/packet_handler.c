#include "networking/packet/packet_handler.h"
#include "networking/replication/properties.h"
#include "networking/replication/replication.h"
#include "networking/packet/game_packet.h"
#include "utils/payload_reader.h"
#include <enet/enet.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void SendPacket(ENetPeer* peer, const GamePacket* packet, enet_uint32 flags) {
    if (!peer || !packet) return;

    size_t rawLen = 0;
    uint8_t* raw = GamePacket_ToRaw(packet, &rawLen);
    if (!raw) {
        fprintf(stderr, "failed to serialize packet\n");
        return;
    }

    ENetPacket* enetPacket = enet_packet_create(raw, rawLen, flags);
    if (!enetPacket) {
        fprintf(stderr, "enet_packet_create failed\n");
        free(raw);
        return;
    }

    free(raw);

    enet_peer_send(peer, 0, enetPacket);
}

void HandlePacket(ENetPeer* peer, const uint8_t* data, size_t dataLength) {
    if (!data || dataLength < 1) {
        fprintf(stderr, "invalid packet\n");
        return;
    }

    PacketType type = data[0];
    const uint8_t* payload = &data[1];
    size_t payloadLen = dataLength - 1;
    
    PayloadReader payloadReader = PayloadReader_New(payload, payloadLen);

    GamePacket* packet = GamePacket_New(type, payload, payloadLen);
    if (!packet) {
        fprintf(stderr, "failed to allocate GamePacket\n");
        return;
    }

    switch (packet->type) {
        case CLIENT_JOIN: {
            GamePacket* response = GamePacket_New(
                SERVER_JOIN_ACCEPT, 
                (uint8_t[]){ peer->incomingPeerID }, 
                0
            );
            
            if (response) {
                SendPacket(peer, response, ENET_PACKET_FLAG_RELIABLE);
                GamePacket_Destroy(response);

                Replicable* newPlayer = CreateReplicable(REPLICABLE_PLAYER);
                SetReplicableProperty(newPlayer, PROPERTY_ID, &peer->incomingPeerID);
                SetReplicableProperty(newPlayer, PROPERTY_NAME, strdup((char*)payload));
            } else {
                fprintf(stderr, "failed to allocate response packet\n");
            }
            break;
        }
        case CLIENT_MOVE: {
            Player* player = FindPlayer(peer->incomingPeerID);
            player->positionX = PayloadReader_ReadF32(&payloadReader);
            player->positionY = PayloadReader_ReadF32(&payloadReader);
            break;
        }
        case CLIENT_REQUEST_REPLICATE: {
            
        }
        default: {
            fprintf(stderr, "unknown packet with id: %d\n", packet->type);
            break;
        }
    }

    GamePacket_Destroy(packet);
}