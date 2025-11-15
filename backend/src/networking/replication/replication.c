#include "networking/replication/replication.h"
#include "networking/replication/properties.h"
#include <stdlib.h>
#include <string.h>

ReplicationContext* ReplicationContext_New(void) {
    ReplicationContext* ctx = (ReplicationContext*)calloc(1, sizeof(ReplicationContext));
    if (!ctx) return NULL;
    ctx->head = NULL;
    ctx->tail = NULL;
    ctx->count = 0;
    ctx->nextId = 0;
    return ctx;
}

void ReplicationContext_Destroy(ReplicationContext* ctx) {
    if (!ctx) return;

    Replicable* cur = ctx->head;
    while (cur) {
        Replicable* next = cur->next;
        FreePropertyList(cur->propertyList);
        free(cur);
        cur = next;
    }

    free(ctx);
}

Replicable* Replicable_New(ReplicationContext* ctx, ReplicableType type) {
    if (!ctx) return NULL;

    Replicable* obj = (Replicable*)calloc(1, sizeof(Replicable));
    if (!obj) return NULL;

    obj->type = type;
    obj->id = ctx->nextId++;
    obj->propertyList = (PropertyList*)calloc(1, sizeof(PropertyList));
    obj->next = NULL;
    obj->prev = NULL;

    if (!ctx->head) {
        ctx->head = ctx->tail = obj;
    } else {
        obj->prev = ctx->tail;
        ctx->tail->next = obj;
        ctx->tail = obj;
    }

    ctx->count++;

    switch (type) {
        case REPLICABLE_PLAYER:
            AddProperty(obj, PROPERTY_ID, CreateIntProperty(-1));
            AddProperty(obj, PROPERTY_NAME, CreateStringProperty("Player"));
            AddProperty(obj, PROPERTY_POSITION, CreateVector2Property((Vector2){ 0.0f, 0.0f }));
            break;

        case REPLICABLE_ENEMY:
            AddProperty(obj, PROPERTY_POSITION, CreateVector2Property((Vector2){ 0.0f, 0.0f }));
            AddProperty(obj, PROPERTY_HEALTH, CreateIntProperty(100));
            break;

        default:
            break;
    }

    return obj;
}

void Replicable_Destroy(ReplicationContext* ctx, Replicable* obj) {
    if (!ctx || !obj) return;

    if (obj->prev) {
        obj->prev->next = obj->next;
    } else {
        ctx->head = obj->next;
    }

    if (obj->next) {
        obj->next->prev = obj->prev;
    } else {
        ctx->tail = obj->prev;
    }

    ctx->count--;

    FreePropertyList(obj->propertyList);
    free(obj);
}

void Replicable_SetProperty(Replicable* obj, PropertyID id, void* value) {
    if (!obj) return;
    Property* prop = GetProperty(obj, id);
    if (prop) SetProperty(prop, value);
}

Property* Replicable_GetProperty(Replicable* obj, PropertyID id) {
    if (!obj) return NULL;
    return GetProperty(obj, id);
}

Replicable* Replicable_GetFirstOfType(ReplicationContext* ctx, int types) {
    if (!ctx) return NULL;
    for (Replicable* cur = ctx->head; cur != NULL; cur = cur->next) {
        if ((cur->type & types) != 0) return cur;
    }
    return NULL;
}

Replicable** Replicable_GetAllOfType(ReplicationContext* ctx, int types, size_t* outCount) {
    if (!ctx) {
        if (outCount) *outCount = 0;
        return NULL;
    }

    size_t matches = 0;
    for (Replicable* cur = ctx->head; cur != NULL; cur = cur->next) {
        if ((cur->type & types) != 0) matches++;
    }

    if (outCount) *outCount = matches;
    if (matches == 0) return NULL;

    Replicable** result = (Replicable**)malloc(matches * sizeof(Replicable*));
    if (!result) {
        if (outCount) *outCount = 0;
        return NULL;
    }

    size_t i = 0;
    for (Replicable* cur = ctx->head; cur != NULL && i < matches; cur = cur->next) {
        if ((cur->type & types) != 0) {
            result[i++] = cur;
        }
    }

    return result;
}
