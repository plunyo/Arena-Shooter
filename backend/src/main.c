#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <enet/enet.h>

#define EVENT_POLL_TIME 20

void handle_event(ENetEvent* event) {
    switch (event->type) {
        case ENET_EVENT_TYPE_NONE:
            break;

        case ENET_EVENT_TYPE_CONNECT:
            printf("client with id (%d) connected twinarang!\n", event->peer->incomingPeerID);
            break;

        case ENET_EVENT_TYPE_DISCONNECT:
            printf("client with id (%d) disconnected twinarang!\n", event->peer->incomingPeerID);
            break;

        case ENET_EVENT_TYPE_RECEIVE: {
            ENetPacket* packet = event->packet;
            
            enet_packet_destroy(packet);
        }
    }
}

int main(int argc, char** argv) {
    if (enet_initialize() != 0) {
        fprintf(stderr, "enet failed to initialize twinarang ;(\n");
        return EXIT_FAILURE;
    }
    atexit(enet_deinitialize);

    ENetAddress address;
    ENetHost* server;
    
    address.host = ENET_HOST_ANY;
    address.port = 30067;
    
    server = enet_host_create(&address, 32, 2, 0, 0);
    if (!server) {
        fprintf(stderr, "could NOT create server twinarang ;(\n");
        return EXIT_FAILURE;
    }

    printf("server running on %d twinarang!", address.port);
    
    ENetEvent event;
    while (true) {
        while (enet_host_service(server, &event, EVENT_POLL_TIME) > 0) {
            handle_event(&event);
        }
    }

    return EXIT_SUCCESS;
}
