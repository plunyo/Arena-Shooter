#pragma once

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

typedef enum ClientPacketType {
    CLIENT_JOIN_REQUEST
} ClientPacketType;

typedef enum ServerPacketType {
    SERVER_JOIN_ACCEPT,
    SERVER_JOIN_DENY
} ServerPacketType;

typedef struct JoinPacket {
    char username[32];
    uint32_t clientId;
} JoinPacket;

typedef struct Packet {
    int type;    // can be ClientPacketType or ServerPacketType depending on context
    void* data;  // points to actual packet data, like JoinPacket
} Packet;