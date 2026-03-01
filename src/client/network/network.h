#ifndef NETWORK_H
#define NETWORK_H

#include <enet/enet.h>

ENetHost* InitNetwork(void);
ENetPeer* ConnectNetwork(ENetHost* host, const char* address, int port);
void UpdateNetwork(ENetHost* host);
void CloseNetwork(ENetHost* host);

#endif