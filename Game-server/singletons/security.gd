extends Node

var dos: Array = [] #An array containing all temporary IPes connected during $isdos time
var isdosINI: int = 60 #Time in seconds to be considered attack, must be >= 10, 0 = disabled
var connectionsINI: int = 5 #Max connection attempts during $indos time, 0 = disabled
var bannedListINI: bool = true #true/false enable/disable collecting banned IPes
var firewallINI: bool = false # true/false enable/disable this server to add firewall rules
var serverOS = OS.get_name().to_lower()
var bannedIP: PackedStringArray #An array cantaining all banned IPes, 
var IPDataCheckINI: bool = false # true/false enable/disable IP address check on ipdata.co
var keyPathINI: String #Absolute file path where stored IPData key
var IPDataFields: Array = ["is_anonymous", "is_threat", "is_bogon"]#Choose IPDATA fields that trigger an attack, more info on ipdata.co
signal ipdata

func _ready():
	await Settings.settingsLoaded
	if isdosINI >= 10:
		var dostime = Timer.new()
		dostime.wait_time = isdosINI
		dostime.autostart = true
		dostime.timeout.connect(self.timeout)
		add_child(dostime, true)
	if bannedListINI:
		if FileAccess.file_exists('res://bannedIPes.txt'):
			var file = FileAccess.open('res://bannedIPes.txt', FileAccess.READ)
			bannedIP = file.get_csv_line()

func timeout():
	dos.clear()
	#Line below is only for debug purpose, not forgot to comment to avoid to spam log
#	print('Attack timer end, flushing IPes array and start new')

func baseIPcheck(ip) -> bool:
# aggiungere skipping quando loopback o lan address
	print('Base IP checking started')
	if ip.is_valid_ip_address():
		print(str(ip) + ' seems a formally valid ip, continuing...')
		return true
	return false

func verify(ip) -> Dictionary:
	var dummy: Dictionary = {'result': false, "IPDataReponse": null}
	if (connectionsINI <= 0 or isdosINI <= 0) and firewallINI == false and not bannedListINI and IPDataCheckINI != true:
		print("WARNING, all protections are disabled, it is recommended to set at least $connectionsINI to 5 and $isdosINI to 60")
		return dummy
	elif attack(ip):
		bannedIP.append(ip)
		dummy['result'] = true
		prints("Attack detected!", ip, "banned internally") #Internal ban live and die together with this server
		if bannedListINI:
			var file = FileAccess.open('res://bannedIPes.txt', FileAccess.WRITE)
			if file != null:
				file.store_csv_line(bannedIP)
				print("banned file list updated") #Those IPes are reloaded when this server start
			else:
				print('A problem encountered writing just banned IP on file, please verify $bannedPathINI, this must include the file name...')
		if firewallINI: #this piece of code is for automatic adding firewall rule on linux OS
			print("adding firewall rule")
			if serverOS.contains("linux"):
				print("Linux OS detected")
				var output: Array = []
				#To execute this command you need to modify /etc/sudoers (Debian/Ubuntu like distributions) to allow the user
				#running this server to pass this command without a password prompt.
				var exit_code = OS.execute("sudo", ["iptabl", "-A", "INPUT", "-s", ip, "-j", "DROP"], output, true)
				print(output)	
				if exit_code == 0:
					print("OK, rule added!") #These rules live on firewall until next OS reboot...but IPes still banned internally with bennedIP file!
				else:
					print("Failed adding firewall rule with exit code: " + str(exit_code))
		return dummy
	else:
		if IPDataCheckINI:
			var z = await ipdatacheck(ip)
			if typeof(z) == TYPE_DICTIONARY:
				dummy['IPDataReponse'] = z['IPDataReponse']
				if z['result'] == true:
					prints('IPdata report', ip, 'listed, so attack detected, disconnecting...')
					dummy['result'] = true
		else:
			print('IPData check module disabled, skipping...')
		return dummy

func attack(ip) -> bool:
	dos.append(ip)
	if connectionsINI > 0 and isdosINI > 0: 
		print('Denial of Service/brute-force attack checking')
		var counter = 0
		for i in dos:
			if i == ip:
				counter +=1
				if counter >= connectionsINI:
					return true
		print('it\'s not an attack, continuing...' )
		return false
	print('Denial of Service/brute-force attack checking disabled')
	return false

func ipdatacheck(ip):
	# API request timeouts and retries
	#var timeout = 2
	#var retry = 2
	#var delay = 1
	if FileAccess.file_exists(keyPathINI + "ipdatakey.ini"): # Deleting this file disable this check
		print("ipdata key present, continuing with check")
		var key = FileAccess.open(keyPathINI + 'ipdatakey.ini', FileAccess.READ).get_line()
		if dos.count(ip)>1:#To avoid too many ipdata requests
			print('IP already checked, skipping IPData check...')
			return
		# Create an HTTP request node and connect its completion signal.
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._http_request_completed)
		print('request started')
		var error = http_request.request("https://api.ipdata.co/?api-key=" + key)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
			return
		var dummy = await ipdata
		return dummy
	else:
		print('ipdata key not present, skipping...')
		return

func _http_request_completed(result, response_code, _headers, body) -> void:
	var dummy: Dictionary = {'result': false, "IPDataReponse": null}
	if result == 0:
		print('IPData request SUCCESS')
		if response_code == 200:
			print('IPDada reponse: OK')
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			dummy['IPDataReponse'] = json.get_data()
			for item in IPDataFields:
				if dummy['IPDataReponse']['threat'].has(item) and dummy['IPDataReponse']['threat'][item] == true:
					dummy['result'] = true
					break
			ipdata.emit(dummy)
		elif response_code == 400:
			print('IData reponse: Bad request')
		elif response_code == 401:
			print('IData reponse: Invalid API Key')
		elif response_code == 402:
			print('IData reponse: Forbidden, maybe too many requests for your plan?')
		else:
			print('Error code: ' + response_code + ' Unknow problem see IPData website/wiki')
	else:
		print('Requesting IPData error, skipping...')
	ipdata.emit(dummy)
