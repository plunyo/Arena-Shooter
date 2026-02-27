#include "server/server.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <enet/enet.h>

#define POLL_TIMEOUT 50

int RunServer() {
    ENetAddress address;
    ENetHost* server;

    address.host = ENET_HOST_ANY;
    address.port = 1234;

    server = enet_host_create(&address, 32, 2, 0, 0);

    if (server == NULL) {
        printf("failed to create server\n");
        return EXIT_FAILURE;
    }

    printf("server running on port %u...\n", address.port);

    ENetEvent event;
    while (true) {
        while (enet_host_service(server, &event, POLL_TIMEOUT) > 0) {
            UpdateServer(server, &event);
        }
    }

    enet_host_destroy(server);
    return EXIT_SUCCESS;
} 

void UpdateServer(ENetHost* server, ENetEvent* event) {
    switch (event->type) {
        case ENET_EVENT_TYPE_CONNECT:
            printf("client connected from %x:%u\n", event->peer->address.host, event->peer->address.port);
            break;

        case ENET_EVENT_TYPE_RECEIVE:
            printf("received packet on channel %u with length %zu\n", event->channelID, event->packet->dataLength);
            break;

        case ENET_EVENT_TYPE_DISCONNECT:
            printf("client disconnected\n");
            event->peer->data = NULL;
            break;

        default:
            break;
    }
}