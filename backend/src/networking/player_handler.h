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
extern int playerCount;

void AddPlayer(Player* newPlayer);
Player* FindPlayer(int id);
