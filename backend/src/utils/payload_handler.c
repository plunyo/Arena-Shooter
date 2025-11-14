#include "payload_handler.h"
#include <string.h>

PayloadHandler PayloadHandler_New(uint8_t* data, size_t size) {
    PayloadHandler handler = { data, size, 0 };
    return handler;
}

int PayloadHandler_CanRead(const PayloadHandler* handler, size_t bytes) {
    return handler && (handler->offset + bytes <= handler->size);
}

int PayloadHandler_CanWrite(const PayloadHandler* handler, size_t bytes) {
    return handler && (handler->offset + bytes <= handler->size);
}

/* --------------------------- READ FUNCTIONS --------------------------- */

int8_t PayloadHandler_ReadI8(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 1)) return 0;
    return (int8_t)handler->data[handler->offset++];
}

uint8_t PayloadHandler_ReadU8(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 1)) return 0;
    return handler->data[handler->offset++];
}

int16_t PayloadHandler_ReadI16(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 2)) return 0;
    int16_t value = (int16_t)((handler->data[handler->offset] << 8) |
                              handler->data[handler->offset + 1]);
    handler->offset += 2;
    return value;
}

uint16_t PayloadHandler_ReadU16(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 2)) return 0;
    uint16_t value = (uint16_t)((handler->data[handler->offset] << 8) |
                                handler->data[handler->offset + 1]);
    handler->offset += 2;
    return value;
}

int32_t PayloadHandler_ReadI32(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 4)) return 0;
    int32_t value = (int32_t)((handler->data[handler->offset] << 24) |
                              (handler->data[handler->offset + 1] << 16) |
                              (handler->data[handler->offset + 2] << 8) |
                               handler->data[handler->offset + 3]);
    handler->offset += 4;
    return value;
}

uint32_t PayloadHandler_ReadU32(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 4)) return 0;
    uint32_t value = (uint32_t)((handler->data[handler->offset] << 24) |
                                (handler->data[handler->offset + 1] << 16) |
                                (handler->data[handler->offset + 2] << 8) |
                                 handler->data[handler->offset + 3]);
    handler->offset += 4;
    return value;
}

float PayloadHandler_ReadF32(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 4)) return 0.0f;
    uint32_t tmp = (handler->data[handler->offset] << 24) |
                   (handler->data[handler->offset + 1] << 16) |
                   (handler->data[handler->offset + 2] << 8) |
                    handler->data[handler->offset + 3];
    handler->offset += 4;
    float f;
    memcpy(&f, &tmp, sizeof(f));
    return f;
}

double PayloadHandler_ReadF64(PayloadHandler* handler) {
    if (!PayloadHandler_CanRead(handler, 8)) return 0.0;
    uint64_t tmp = ((uint64_t)handler->data[handler->offset] << 56) |
                   ((uint64_t)handler->data[handler->offset + 1] << 48) |
                   ((uint64_t)handler->data[handler->offset + 2] << 40) |
                   ((uint64_t)handler->data[handler->offset + 3] << 32) |
                   ((uint64_t)handler->data[handler->offset + 4] << 24) |
                   ((uint64_t)handler->data[handler->offset + 5] << 16) |
                   ((uint64_t)handler->data[handler->offset + 6] << 8)  |
                    (uint64_t)handler->data[handler->offset + 7];
    handler->offset += 8;
    double f;
    memcpy(&f, &tmp, sizeof(f));
    return f;
}

/* ---------------------------    WRITE FUNCTIONS    --------------------------- */

void PayloadHandler_WriteI8(PayloadHandler* handler, int8_t value) {
    if (!PayloadHandler_CanWrite(handler, 1)) return;
    handler->data[handler->offset++] = (uint8_t)value;
}

void PayloadHandler_WriteU8(PayloadHandler* handler, uint8_t value) {
    if (!PayloadHandler_CanWrite(handler, 1)) return;
    handler->data[handler->offset++] = value;
}

void PayloadHandler_WriteI16(PayloadHandler* handler, int16_t value) {
    if (!PayloadHandler_CanWrite(handler, 2)) return;
    handler->data[handler->offset++] = (uint8_t)((value >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(value & 0xFF);
}

void PayloadHandler_WriteU16(PayloadHandler* handler, uint16_t value) {
    if (!PayloadHandler_CanWrite(handler, 2)) return;
    handler->data[handler->offset++] = (uint8_t)((value >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(value & 0xFF);
}

void PayloadHandler_WriteI32(PayloadHandler* handler, int32_t value) {
    if (!PayloadHandler_CanWrite(handler, 4)) return;
    handler->data[handler->offset++] = (uint8_t)((value >> 24) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((value >> 16) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((value >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(value & 0xFF);
}

void PayloadHandler_WriteU32(PayloadHandler* handler, uint32_t value) {
    if (!PayloadHandler_CanWrite(handler, 4)) return;
    handler->data[handler->offset++] = (uint8_t)((value >> 24) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((value >> 16) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((value >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(value & 0xFF);
}

void PayloadHandler_WriteF32(PayloadHandler* handler, float value) {
    if (!PayloadHandler_CanWrite(handler, 4)) return;
    uint32_t tmp;
    memcpy(&tmp, &value, sizeof(tmp));
    handler->data[handler->offset++] = (uint8_t)((tmp >> 24) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 16) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(tmp & 0xFF);
}

void PayloadHandler_WriteF64(PayloadHandler* handler, double value) {
    if (!PayloadHandler_CanWrite(handler, 8)) return;
    uint64_t tmp;
    memcpy(&tmp, &value, sizeof(tmp));
    handler->data[handler->offset++] = (uint8_t)((tmp >> 56) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 48) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 40) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 32) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 24) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 16) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)((tmp >> 8) & 0xFF);
    handler->data[handler->offset++] = (uint8_t)(tmp & 0xFF);
}
