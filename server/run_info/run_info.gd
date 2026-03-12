extends VBoxContainer
class_name RunInfo

@onready var player_count_label: Label = $RunInfoItem/PlayerCountLabel
@onready var server_tps_label: Label = $RunInfoItem2/ServerTPSLabel
@onready var uptime_label: Label = $RunInfoItem3/UptimeLabel
@onready var port_label: Label = $RunInfoItem4/PortLabel

var max_players: int

func init_run_info(port: int, _max_players: int) -> void:
	port_label.text = "Port: " + str(port) 
	max_players = _max_players

func update_run_info(player_count: int, uptime: int) -> void:
	player_count_label.text = "Players: " + str(player_count) + "/" + str(max_players)
	uptime_label.text = "Uptime: " + format_elapsed_time(uptime)

func format_elapsed_time(total_seconds: int) -> String:
	if total_seconds <= 0:
		return "0s"

	var d: int = int(total_seconds / 86400.0)
	var h: int = int((total_seconds % 86400) / 3600.0)
	var m: int = int((total_seconds % 3600) / 60.0)
	var s: int = total_seconds % 60

	var parts: Array[String] = []
	
	if d > 0: parts.append(str(d) + "d")
	if h > 0: parts.append(str(h) + "h")
	if m > 0: parts.append(str(m) + "m")
	if s > 0: parts.append(str(s) + "s")

	return " ".join(parts)
