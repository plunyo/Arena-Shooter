#include "networking/player_handler.h"
#include <stdio.h>

Player* headPlayer = NULL;
int playerCount = 0;

void AddPlayer(Player* newPlayer) {
    if (!headPlayer) {
        headPlayer = newPlayer;
        newPlayer->next = NULL;
    } else {
        Player* lastPlayer = headPlayer;

        while (lastPlayer->next != NULL) {
            lastPlayer = lastPlayer->next;
        }

        lastPlayer->next = newPlayer;
        newPlayer->next = NULL;
    }
    
    playerCount++;
    printf("new player with username: %s, id: %d, joined!\n", newPlayer->username, newPlayer->id);
}

Player* FindPlayer(int id) {
    if (!headPlayer) {
        fprintf(stderr, "no players!\n");
        return NULL;
    }

    Player* currentPlayer = headPlayer;
    while (currentPlayer != NULL) {
        if (currentPlayer->id == id) {
            return currentPlayer;
        }

        currentPlayer = currentPlayer->next;
    }

    fprintf(stderr, "player with id %d not found\n", id);
    return NULL;
}