extends Control

var devmode: bool:
	get:
		return GatewayClient.devmodeINI

func _ready():
	$MainTheme.stream.set_loop(true)
	if devmode:
		print('ciao')
		$LoginForm.reportWarning('DEVMODE ENABLED')

@rpc("call_remote")
func printIPData(data):
	pass

func _on_login_form_submit(username, password):
	if devmode:
		print('Skipping login because devmode=true')
		var token = str(int(Time.get_unix_time_from_system()))
		GatewayClient.ResultLoginRequest(true, 'DEVMODE enabled', token, '127.0.0.1')
		return
	
	if username == "" or password == "":
		$LoginForm.reportError("Fields can't be empty")
		return
	
	var result = await GatewayClient.attempt_login(username, password)
	if result == null:
		$LoginForm.reportError('Login failed')
	else:
		$LoginForm.reportInfo('Login succeded!')
		var token = result['token']
		var   url = result['url']
		GameserverClient.set('token', token)
		GameserverClient.ConnectToServer(url)
