#pragma once
#include "networking/replication/properties.h"

typedef enum ReplicableType {
    REPLICABLE_PLAYER,
    REPLICABLE_ENEMY
} ReplicableType;

typedef struct Replicable {
    ReplicableType type;
    int id;
    PropertyList propertyList;
    struct Replicable* next;
} Replicable;

extern Replicable* headReplicable;
extern int replicableCount;

Replicable* CreateReplicable(ReplicableType type);
void SetReplicableProperty(Replicable* obj, PropertyID id, void* value);
void DestroyReplicable(Replicable* obj);
