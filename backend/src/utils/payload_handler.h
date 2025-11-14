#pragma once

#include <stddef.h>
#include <stdint.h>

typedef struct PayloadHandler {
    uint8_t* data;
    size_t size;
    size_t offset;
} PayloadHandler;

PayloadHandler PayloadHandler_New(uint8_t* data, size_t size);
int PayloadHandler_CanRead(const PayloadHandler* reader, size_t bytes);

int8_t   PayloadHandler_ReadI8(PayloadHandler* reader);
uint8_t  PayloadHandler_ReadU8(PayloadHandler* reader);
int16_t  PayloadHandler_ReadI16(PayloadHandler* reader);
uint16_t PayloadHandler_ReadU16(PayloadHandler* reader);
int32_t  PayloadHandler_ReadI32(PayloadHandler* reader);
uint32_t PayloadHandler_ReadU32(PayloadHandler* reader);
float    PayloadHandler_ReadF32(PayloadHandler* reader);
double   PayloadHandler_ReadF64(PayloadHandler* reader);
