#include "networking/replication/replication.h"
#include "networking/replication/properties.h"
#include <stdlib.h>

Replicable* headReplicable;
int replicableCount = 0;

Replicable* CreateReplicable(ReplicableType type) {
    Replicable* obj = calloc(1, sizeof(Replicable));
    obj->type = type;

    if (!headReplicable) {
        headReplicable = obj;
    } else {
        Replicable* endReplicable = headReplicable;
        while (endReplicable->next != NULL) { // go to the last node
            endReplicable = endReplicable->next;
        }
        endReplicable->next = obj; // append the new object
    }

    obj->id = replicableCount++;


    switch (type) {
        case REPLICABLE_PLAYER:
            AddProperty(obj, PROPERTY_ID, CreateIntProperty(-1));
            AddProperty(obj, PROPERTY_NAME, CreateStringProperty("Player"));
            AddProperty(obj, PROPERTY_POSITION, CreateVector2Property((Vector2){ 0.0f, 0.0f }));
            break;

        case REPLICABLE_ENEMY:
            AddProperty(obj, PROPERTY_POSITION, CreateVector2Property((Vector2){0, 0}));
            AddProperty(obj, PROPERTY_HEALTH, CreateIntProperty(100));
            break;
    }

    return obj;
}

void SetReplicableProperty(Replicable* obj, PropertyID id, void* value) {
    Property* prop = GetProperty(obj, id);
    if (prop) SetProperty(prop, value);
}

void DestroyReplicable(Replicable* obj) {
    FreePropertyList(&obj->propertyList);
    free(obj);
}
