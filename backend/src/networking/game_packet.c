
#include "networking/game_packet.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

GamePacket* GamePacket_New(PacketType type, const void* data, size_t packetLength) {
    GamePacket* instance = malloc(sizeof(GamePacket));
    if (!instance) {
        fprintf(stderr, "GamePacket_New: allocation failed\n");
        return NULL;
    }

    instance->type = type;
    instance->packetLength = packetLength;
    instance->data = NULL;

    if (packetLength > 0) {
        instance->data = malloc(packetLength);
        if (!instance->data) {
            fprintf(stderr, "GamePacket_New: data allocation failed\n");
            free(instance);
            return NULL;
        }
        memcpy(instance->data, data, packetLength);
    }

    return instance;
}

void GamePacket_Destroy(GamePacket* packet) {
    if (!packet) return;
    free(packet->data);
    free(packet);
}

uint8_t* GamePacket_ToRaw(const GamePacket* packet, size_t* outLength) {
    if (!packet) return NULL;

    size_t total = 1 + packet->packetLength; // 1 byte for the type
    uint8_t* raw = malloc(total);
    if (!raw) return NULL;

    raw[0] = packet->type;
    if (packet->packetLength > 0 && packet->data) {
        memcpy(&raw[1], packet->data, packet->packetLength);
    }

    if (outLength) *outLength = total;
    return raw;
}
