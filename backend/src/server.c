#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <enet/enet.h>

#include "networking/packet_handler.h"

#define EVENT_POLL_TIME 20

static void handle_event(ENetEvent* event) {
    switch (event->type) {
        case ENET_EVENT_TYPE_NONE:
            break;

        case ENET_EVENT_TYPE_CONNECT:
            printf("client with id (%u) connected\n", event->peer->incomingPeerID);
            break;

        case ENET_EVENT_TYPE_DISCONNECT:
            printf("client with id (%u) disconnected\n", event->peer->incomingPeerID);
            break;

        case ENET_EVENT_TYPE_RECEIVE: {
            ENetPacket* packet = event->packet;
            HandlePacket(event->peer, packet->data, packet->dataLength);
            enet_packet_destroy(packet);
            break;
        }
    }
}

int main(int argc, char** argv) {
    if (enet_initialize() != 0) {
        fprintf(stderr, "enet failed to initialize\n");
        return EXIT_FAILURE;
    }
    atexit(enet_deinitialize);

    ENetAddress address;
    ENetHost* server;

    address.host = ENET_HOST_ANY;
    address.port = 30067;

    server = enet_host_create(&address, 32, 2, 0, 0);
    if (!server) {
        fprintf(stderr, "could NOT create server\n");
        return EXIT_FAILURE;
    }

    printf("server running on %u\n", address.port);

    ENetEvent event;
    while (true) {
        while (enet_host_service(server, &event, EVENT_POLL_TIME) > 0) {
            handle_event(&event);
        }
    }

    enet_host_destroy(server);
    return EXIT_SUCCESS;
}