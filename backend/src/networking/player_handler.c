#include "networking/player_handler.h"

Player* headPlayer = NULL;

void AddPlayer(Player* newPlayer) {
    if (!headPlayer) {
        headPlayer = newPlayer;
        newPlayer->next = NULL;
        return;
    }

    Player* lastPlayer = headPlayer;
    while (lastPlayer->next != NULL) {
        lastPlayer = lastPlayer->next;
    }

    lastPlayer->next = newPlayer;
    newPlayer->next = NULL;
}
