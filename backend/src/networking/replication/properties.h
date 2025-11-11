#pragma once

#include "utils/vector2.h"

typedef struct Replicable Replicable;

typedef enum PropertyType {
    PROPERTY_INT,
    PROPERTY_FLOAT,
    PROPERTY_STRING,
    PROPERTY_VECTOR2,
} PropertyType;

typedef enum PropertyID {
    PROPERTY_POSITION,
    PROPERTY_VELOCITY,
    PROPERTY_NAME,
    PROPERTY_HEALTH,
    PROPERTY_ID,
} PropertyID;

typedef struct Property {
    PropertyID id;
    PropertyType type;

    union {
        int i;
        float f;
        char* s;
        Vector2 v2;
    } value;
} Property;

typedef struct PropertyList {
    Property* properties;

    int count;
    int capacity;
} PropertyList;

Property CreateIntProperty(int value);
Property CreateFloatProperty(float value);
Property CreateStringProperty(const char* value);
Property CreateVector2Property(Vector2 value);

void DestroyProperty(Property* prop);
void AddProperty(Replicable* obj, PropertyID id, Property prop);
Property* GetProperty(Replicable* obj, PropertyID id);
void SetProperty(Property* property, void* value);
void* GetPropertyValue(Property* property);
void FreePropertyList(PropertyList* list);
