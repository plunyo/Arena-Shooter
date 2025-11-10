#include "networking/replication/replication.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

Property CreateIntProperty(int value) {
    Property p;
    p.type = PROPERTY_INT;
    p.value.i = value;
    return p;
}

Property CreateFloatProperty(float value) {
    Property p;
    p.type = PROPERTY_FLOAT;
    p.value.f = value;
    return p;
}

Property CreateStringProperty(const char* value) {
    Property p;
    p.type = PROPERTY_STRING;
    p.value.s = strdup(value);
    return p;
}

void AddProperty(Replicable* obj, Property prop) {
    if (obj->properties.count >= obj->properties.capacity) {
        obj->properties.capacity = obj->properties.capacity == 0 ? 4 : obj->properties.capacity * 2;
        obj->properties.properties = realloc(obj->properties.properties, obj->properties.capacity * sizeof(Property));
    }
    obj->properties.properties[obj->properties.count++] = prop;
}

Property* GetProperty(Replicable* obj, int index) {
    if (index < 0 || index >= obj->properties.count) return NULL;
    return &obj->properties.properties[index];
}

void AddComponent(Replicable* obj, Component* comp) {
    if (obj->componentCount < MAX_COMPONENTS) {
        obj->components[obj->componentCount++] = comp;
        if (comp->init) comp->init(obj);
    } else {
        printf("component limit reached!\n");
    }
}

Replicable* CreateReplicable(ReplicableType type) {
    Replicable* obj = calloc(1, sizeof(Replicable));
    obj->type = type;

    switch (type) {
        case REPLICABLE_PLAYER: {
            AddProperty(obj, CreateIntProperty(100));       
            AddProperty(obj, CreateFloatProperty(5.5f));   
            AddProperty(obj, CreateStringProperty("Player")); 
            break;
        }
    }

    return obj;
}

void DestroyReplicable(Replicable* obj) {
    for (int i = 0; i < obj->properties.count; i++) {
        if (obj->properties.properties[i].type == PROPERTY_STRING) {
            free(obj->properties.properties[i].value.s);
        }
    }
    free(obj->properties.properties);

    for (int i = 0; i < obj->componentCount; i++) {
        if (obj->components[i]->destroy)
            obj->components[i]->destroy(obj);
    }

    free(obj);
}
