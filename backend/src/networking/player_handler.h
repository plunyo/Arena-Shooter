#pragma once

#include <enet/enet.h>

typedef struct Player {
    ENetPeer* peer;
    int id;
    char* username;
    float positionX;
    float positionY;

    struct Player* next;
} Player;

extern Player* headPlayer;

void AddPlayer(Player* newPlayer);
Player* FindPlayerFromId(int id);
