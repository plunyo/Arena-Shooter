#pragma once

#include <enet/enet.h>

int RunServer();
void UpdateServer(ENetHost* server, ENetEvent* event);