#pragma once
#include <stddef.h>

#define MAX_COMPONENTS 16

// -------------------- property system --------------------
typedef enum PropertyType {
    PROPERTY_INT,
    PROPERTY_FLOAT,
    PROPERTY_STRING
} PropertyType;

typedef struct Property {
    PropertyType type;
    union {
        int i;
        float f;
        char* s;
    } value;
} Property;

typedef struct PropertyList {
    Property* properties;
    int count;
    int capacity;
} PropertyList;

// -------------------- component system --------------------
struct Replicable; // forward declare

typedef struct Component {
    void (*init)(struct Replicable* owner);
    void (*update)(struct Replicable* owner, float delta);
    void (*destroy)(struct Replicable* owner);
} Component;

// -------------------- replicable object --------------------
typedef enum ReplicableType {
    REPLICABLE_PLAYER
} ReplicableType;

typedef struct Replicable {
    ReplicableType type;
    PropertyList properties;

    Component* components[MAX_COMPONENTS];
    int componentCount;
} Replicable;

// -------------------- api --------------------
Replicable* CreateReplicable(ReplicableType type);
void DestroyReplicable(Replicable* obj);

Property CreateIntProperty(int value);
Property CreateFloatProperty(float value);
Property CreateStringProperty(const char* value);

void AddProperty(Replicable* obj, Property prop);
Property* GetProperty(Replicable* obj, int index);

void AddComponent(Replicable* obj, Component* comp);
