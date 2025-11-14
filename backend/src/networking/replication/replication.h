#ifndef REPLICATION_H
#define REPLICATION_H

#include <stdint.h>
#include <stddef.h>
#include "networking/replication/properties.h"

typedef enum ReplicableType {
    REPLICABLE_NONE  = 0,
    REPLICABLE_PLAYER = 1 << 0,
    REPLICABLE_ENEMY  = 1 << 1,
} ReplicableType;

typedef struct Replicable {
    uint32_t id;
    ReplicableType type;

    PropertyList* propertyList;

    struct Replicable* next;
    struct Replicable* prev;
} Replicable;

typedef struct ReplicationContext {
    Replicable* head;
    Replicable* tail;
    size_t count;
    uint32_t nextId;
} ReplicationContext;

/* context management */
ReplicationContext* ReplicationContext_New(void);
void ReplicationContext_Destroy(ReplicationContext* ctx);

/* create/destroy replicables (context required) */
Replicable* Replicable_New(ReplicationContext* ctx, ReplicableType type);
void Replicable_Destroy(ReplicationContext* ctx, Replicable* obj);

/* basic operations */
void Replicable_SetProperty(Replicable* obj, PropertyID id, void* value);
Property* Replicable_GetProperty(Replicable* obj, PropertyID id);

/* queries */
Replicable* Replicable_GetFirstOfType(ReplicationContext* ctx, int types);
Replicable** Replicable_GetAllOfType(ReplicationContext* ctx, int types, size_t* outCount);

#endif /* REPLICATION_H */
