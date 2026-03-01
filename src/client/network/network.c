#include "network.h"
#include <stdio.h>
#include <stdlib.h>

ENetHost* InitNetwork(void) {
    ENetHost* host = enet_host_create(NULL, 1, 2, 0, 0);
    if (!host) {
        printf("failed to create client\n");
        exit(EXIT_FAILURE);
    }

    return host;
}

ENetPeer* ConnectNetwork(ENetHost* host, const char* address_str, int port) {
    ENetAddress address;
    enet_address_set_host(&address, address_str);
    address.port = port;

    ENetPeer* peer = enet_host_connect(host, &address, 2, 0);
    if (!peer) {
        printf("no available peers\n");
        exit(EXIT_FAILURE);
    }

    return peer;
}

void UpdateNetwork(ENetHost* host) {
    ENetEvent event;

    while (enet_host_service(host, &event, 0) > 0) {
        switch (event.type) {
            case ENET_EVENT_TYPE_CONNECT:
                printf("connected\n");
                break;

            case ENET_EVENT_TYPE_RECEIVE:
                printf("got packet: %s\n", event.packet->data);
                enet_packet_destroy(event.packet);
                break;

            case ENET_EVENT_TYPE_DISCONNECT:
                printf("disconnected\n");
                event.peer->data = NULL;
                break;

            default:
                break;
        }
    }
}

void CloseNetwork(ENetHost* host) {
    enet_host_destroy(host);
}