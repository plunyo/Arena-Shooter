#pragma once

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

typedef enum PacketType {
    // client packets
    CLIENT_JOIN_REQUEST, 
    SERVER_JOIN_ACCEPT,

    // server packets
    SERVER_JOIN_DENY
} PacketType;

typedef struct Packet {
    PacketType type;

    uint8_t* data;
    size_t  dataLength;
} Packet;