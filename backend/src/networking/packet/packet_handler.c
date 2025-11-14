#include "networking/replication/replication.h"
#include "networking/replication/properties.h"
#include "networking/packet/packet_handler.h"
#include "networking/packet/game_packet.h"
#include "utils/payload_handler.h"
#include "utils/vector2.h"
#include <enet/enet.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void SendPacket(ENetPeer* peer, const GamePacket* packet, enet_uint32 flags) {
    if (!peer || !packet) return;

    size_t rawLen = 0;
    uint8_t* raw = GamePacket_ToRaw(packet, &rawLen);
    if (!raw) {
        fprintf(stderr, "failed to serialize packet\n");
        return;
    }

    ENetPacket* enetPacket = enet_packet_create(raw, rawLen, flags);
    free(raw);

    if (!enetPacket) {
        fprintf(stderr, "enet_packet_create failed\n");
        return;
    }

    enet_peer_send(peer, 0, enetPacket);
}

static void csJoin(ReplicationContext* ctx, ENetPeer* peer, PayloadHandler* reader) {
    char* playerName = (char*)reader->data;
    if (!playerName) {
        fprintf(stderr, "failed to read player name from payload\n");
        return;
    }

    // send join accept packet
    uint8_t peerId = (uint8_t)peer->incomingPeerID;
    GamePacket* response = GamePacket_New(SERVER_JOIN_ACCEPT, &peerId, sizeof(peerId));

    if (response) {
        SendPacket(peer, response, ENET_PACKET_FLAG_RELIABLE);
        GamePacket_Destroy(response);
    } else {
        fprintf(stderr, "failed to allocate response packet\n");
    }

    // create replicable player in context
    Replicable* newPlayer = Replicable_New(ctx, REPLICABLE_PLAYER);
    if (!newPlayer) {
        fprintf(stderr, "failed to create replicable player\n");
        return;
    }

    Replicable_SetProperty(newPlayer, PROPERTY_ID, &peer->incomingPeerID);
    Replicable_SetProperty(newPlayer, PROPERTY_NAME, strdup(playerName));

    printf("[join] created player id=%u name=%s\n", peer->incomingPeerID, playerName);
}

static void csMove(ReplicationContext* ctx, ENetPeer* peer, PayloadHandler* reader) {
    float x = PayloadHandler_ReadF32(reader);
    float y = PayloadHandler_ReadF32(reader);

    // find player replicable with matching ID
    Replicable* player = NULL;
    for (Replicable* cur = ctx->head; cur != NULL; cur = cur->next) {
        Property* idProp = Replicable_GetProperty(cur, PROPERTY_ID);
        if (idProp && *(int*)GetPropertyValue(idProp) == (int)peer->incomingPeerID) {
            player = cur;
            break;
        }
    }

    if (!player) {
        fprintf(stderr, "player not found for peer %u\n", peer->incomingPeerID);
        return;
    }

    Vector2 newPos = { x, y };
    Replicable_SetProperty(player, PROPERTY_POSITION, &newPos);
}

static void csRequestReplicate(ReplicationContext* ctx, ENetPeer* peer, PayloadHandler* reader) {
    size_t count = 0;
    Replicable** players = Replicable_GetAllOfType(ctx, REPLICABLE_PLAYER, &count);

    for (size_t i = 0; i < count; i++) {
        Replicable* current = players[i];

        GamePacket* packet = GamePacket_New(SERVER_REPLICATE, &current->id, sizeof(current->id));
        if (packet) {
            SendPacket(peer, packet, ENET_PACKET_FLAG_RELIABLE);
            GamePacket_Destroy(packet);
        } else {
            fprintf(stderr, "failed to allocate replicate packet\n");
        }
    }

    free(players);
}

void HandlePacket(ReplicationContext* ctx, ENetPeer* peer, uint8_t* data, size_t dataLength) {
    if (!ctx || !data || dataLength < 1) {
        fprintf(stderr, "invalid packet\n");
        return;
    }

    PacketType type = data[0];
    PayloadHandler payloadReader = PayloadHandler_New(&data[1], dataLength - 1);

    switch (type) {
        case CLIENT_JOIN:
            csJoin(ctx, peer, &payloadReader);
            break;
        case CLIENT_MOVE:
            csMove(ctx, peer, &payloadReader);
            break;
        case CLIENT_REQUEST_REPLICATE:
            csRequestReplicate(ctx, peer, &payloadReader);
            break;
        default:
            fprintf(stderr, "unknown packet type: %d\n", type);
            break;
    }
}
