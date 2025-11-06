#pragma once

#include <enet/enet.h>

typedef struct Player {
    ENetPeer* peer;
    float positionX;
    float positionY;
    struct Player* next;
} Player;

extern Player* headPlayer;

