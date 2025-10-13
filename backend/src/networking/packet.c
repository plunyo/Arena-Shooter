#include "networking/packet.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

uint8_t* GamePacket_ToRaw(GamePacket* packet) {
    uint8_t* raw = malloc(packet->packetLength);
    if (!raw) return NULL;

    raw[0] = packet->type;
    memcpy(&raw[1], packet->data, packet->packetLength);

    return raw;
}