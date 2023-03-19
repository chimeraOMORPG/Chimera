extends Timer

var availableTokens: Array
var current_Time: int = Time.get_unix_time_from_system()

func _on_timeout():
	if availableTokens.is_empty():
		prints('$availableTokens is empty')
	else:
#		for i in range(get_node("/root/GameserverClient").size() - 1, -1, -1):
#			var tokenTime = int()
		print(availableTokens)
