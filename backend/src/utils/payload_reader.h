#pragma once

#include <stddef.h>
#include <stdint.h>

typedef struct PayloadReader {
    const uint8_t* data;
    size_t size;
    size_t offset;
} PayloadReader;

PayloadReader PayloadReader_New(const uint8_t* data, size_t size);
int PayloadReader_CanRead(const PayloadReader* reader, size_t bytes);

int8_t   PayloadReader_ReadI8(PayloadReader* reader);
uint8_t  PayloadReader_ReadU8(PayloadReader* reader);
int16_t  PayloadReader_ReadI16(PayloadReader* reader);
uint16_t PayloadReader_ReadU16(PayloadReader* reader);
int32_t  PayloadReader_ReadI32(PayloadReader* reader);
uint32_t PayloadReader_ReadU32(PayloadReader* reader);
float    PayloadReader_ReadF32(PayloadReader* reader);
double   PayloadReader_ReadF64(PayloadReader* reader);
