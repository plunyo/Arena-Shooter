#include "payload_reader.h"
#include <string.h>

PayloadReader PayloadReader_New(const uint8_t* data, size_t size) {
    PayloadReader reader = { data, size, 0 };
    return reader;
}

int PayloadReader_CanRead(const PayloadReader* reader, size_t bytes) {
    return reader && (reader->offset + bytes <= reader->size);
}

int8_t PayloadReader_ReadI8(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 1)) return 0;
    return (int8_t)reader->data[reader->offset++];
}

uint8_t PayloadReader_ReadU8(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 1)) return 0;
    return reader->data[reader->offset++];
}

int16_t PayloadReader_ReadI16(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 2)) return 0;
    int16_t value = (int16_t)((reader->data[reader->offset] << 8) |
                              reader->data[reader->offset + 1]);
    reader->offset += 2;
    return value;
}

uint16_t PayloadReader_ReadU16(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 2)) return 0;
    uint16_t value = (uint16_t)((reader->data[reader->offset] << 8) |
                                reader->data[reader->offset + 1]);
    reader->offset += 2;
    return value;
}

int32_t PayloadReader_ReadI32(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 4)) return 0;
    int32_t value = (int32_t)((reader->data[reader->offset] << 24) |
                              (reader->data[reader->offset + 1] << 16) |
                              (reader->data[reader->offset + 2] << 8) |
                               reader->data[reader->offset + 3]);
    reader->offset += 4;
    return value;
}

uint32_t PayloadReader_ReadU32(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 4)) return 0;
    uint32_t value = (uint32_t)((reader->data[reader->offset] << 24) |
                                (reader->data[reader->offset + 1] << 16) |
                                (reader->data[reader->offset + 2] << 8) |
                                 reader->data[reader->offset + 3]);
    reader->offset += 4;
    return value;
}

float PayloadReader_ReadF32(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 4)) return 0.0f;
    uint32_t tmp = (reader->data[reader->offset] << 24) |
                   (reader->data[reader->offset + 1] << 16) |
                   (reader->data[reader->offset + 2] << 8) |
                   reader->data[reader->offset + 3];
    reader->offset += 4;
    float f;
    memcpy(&f, &tmp, sizeof(f));
    return f;
}

double PayloadReader_ReadF64(PayloadReader* reader) {
    if (!PayloadReader_CanRead(reader, 8)) return 0.0;
    uint64_t tmp = ((uint64_t)reader->data[reader->offset] << 56) |
                   ((uint64_t)reader->data[reader->offset + 1] << 48) |
                   ((uint64_t)reader->data[reader->offset + 2] << 40) |
                   ((uint64_t)reader->data[reader->offset + 3] << 32) |
                   ((uint64_t)reader->data[reader->offset + 4] << 24) |
                   ((uint64_t)reader->data[reader->offset + 5] << 16) |
                   ((uint64_t)reader->data[reader->offset + 6] << 8)  |
                    (uint64_t)reader->data[reader->offset + 7];
    reader->offset += 8;
    double f;
    memcpy(&f, &tmp, sizeof(f));
    return f;
}
