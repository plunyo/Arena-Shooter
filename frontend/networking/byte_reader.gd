class_name ByteReader

var data: PackedByteArray
var pos: int = 0

func _init(bytes: PackedByteArray):
	data = bytes

func read_u8() -> int:
	var val = data.decode_u8(pos)
	pos += 1
	return val

func read_u16() -> int:
	var val = data.decode_u16(pos)
	pos += 2
	return val

func read_u32() -> int:
	var val = data.decode_u32(pos)
	pos += 4
	return val

func read_float() -> float:
	var val = data.decode_float(pos)
	pos += 4
	return val
