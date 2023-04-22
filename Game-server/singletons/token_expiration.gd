extends Timer

var availableTokens: Array

func _init():
	self.set_wait_time(10)
	self.set_autostart(true)

func _ready():
	timeout.connect(self._on_timeout)

func _on_timeout():
	if availableTokens.is_empty():
		pass
	else:
		for i in range(availableTokens.size() - 1, -1, -1):
			var current_Time: int = int(Time.get_unix_time_from_system())
			var tokenTime = int(availableTokens[i].right(10))
			if current_Time - tokenTime >= 30:
				prints(availableTokens[i], 'token expired, removed...')
				availableTokens.remove_at(i)
