#include "networking/replication/properties.h"
#include "networking/replication/replication.h"
#include "utils/vector2.h"
#include <stdlib.h>
#include <string.h>

// ---------- creation ----------
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

Property CreateVector2Property(Vector2 value) {
    Property p;
    p.type = PROPERTY_VECTOR2;
    p.value.v2 = value;
    return p;
}

void DestroyProperty(Property* prop) {
    if (prop->type == PROPERTY_STRING && prop->value.s != NULL) {
        free(prop->value.s);
        prop->value.s = NULL;
    }
}

void AddProperty(Replicable* obj, PropertyID id, Property prop) {
    PropertyList* list = &obj->propertyList;

    if (list->count >= list->capacity) {
        list->capacity = list->capacity == 0 ? 4 : list->capacity * 2;
        list->properties = realloc(list->properties, list->capacity * sizeof(Property));
    }

    prop.id = id;
    list->properties[list->count++] = prop;
}

Property* GetProperty(Replicable* obj, PropertyID id) {
    PropertyList* list = &obj->propertyList;

    for (int i = 0; i < list->count; i++) {
        if (list->properties[i].id == id)
            return &list->properties[i];
    }

    return NULL;
}

void SetProperty(Property* property, void* value) {
    switch (property->type) {
        case PROPERTY_INT: property->value.i = *(int*)value; break;
        case PROPERTY_FLOAT: property->value.f = *(float*)value; break;
        case PROPERTY_VECTOR2: property->value.v2 = *(Vector2*)value; break;
        case PROPERTY_STRING:
            if (property->value.s) free(property->value.s);
            property->value.s = strdup((char*)value);
            break;
    }
}


void* GetPropertyValue(Property* property) {
    switch (property->type) {
        case PROPERTY_STRING: return property->value.s;
        case PROPERTY_FLOAT: return &property->value.f;
        case PROPERTY_VECTOR2: return &property->value.v2;
        case PROPERTY_INT: return &property->value.i;
    }
}

void FreePropertyList(PropertyList* list) {
    for (int i = 0; i < list->count; i++) {
        DestroyProperty(&list->properties[i]);
    }
    free(list->properties);
    list->properties = NULL;
    list->count = 0;
    list->capacity = 0;
}
