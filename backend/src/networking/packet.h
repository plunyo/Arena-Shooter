#pragma once

#include <stddef.h>
#include <stdint.h>

typedef enum ClientPacket {
	CLIENT_JOIN = 0x00,
	CLIENT_MOVE = 0x01,
	CLIENT_REQUEST_PLAYER_SYNC = 0x02,
	CLIENT_KICK_PLAYER = 0x03,
	CLIENT_LEAVE = 0x04,
	CLIENT_REQUEST_SESSION_ID = 0x05,
} ClientPacket;

typedef enum ServerPacket {
	SERVER_JOIN_ACCEPT = 0x00,
	SERVER_JOIN_DENY = 0x01,
	SERVER_UPDATE_PLAYERS = 0x02,
	SERVER_SYNC_PLAYERS = 0x03, 
	SERVER_KICK_PLAYER = 0x04,
	SERVER_CLIENT_ID = 0x05,
	SERVER_SESSION_ID = 0x06,
} ServerPacket;

typedef uint8_t PacketType;

typedef struct GamePacket {
    PacketType type;
    uint8_t* data;
    size_t packetLength;
} GamePacket;

uint8_t* GamePacketToRaw(const GamePacket* packet);