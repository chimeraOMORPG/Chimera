extends Timer

var availableTokens: Array

func _on_timeout():
	if availableTokens.is_empty():
		pass
	else:
		for i in range(availableTokens.size() - 1, -1, -1):
			var current_Time: int = Time.get_unix_time_from_system()
			var tokenTime = int(availableTokens[i].right(10))
			if current_Time - tokenTime >= 30:
				prints(availableTokens[i], 'token expired, removed...')
				availableTokens.remove_at(i)
				

