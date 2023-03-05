extends Node

var bannedListINI: bool #true/false enable/disable collecting banned IPes
var firewallINI: bool = false # true/false enable/disable this server to add firewall rules
var serverOS = OS.get_name().to_lower()
var bannedIP: PackedStringArray = PackedStringArray([]) #An array cantaining all banned IPes, 
var gatewayIPINI: String

func _ready():
	await Settings.settingsLoaded
	if bannedListINI:
		if FileAccess.file_exists('res://bannedIPes.txt'):
			var file = FileAccess.open('res://bannedIPes.txt', FileAccess.READ)
			bannedIP = file.get_csv_line()

func baseIPcheck(ip) -> bool:
# aggiungere skipping quando loopback o lan address
	print('Base IP checking started')
	if ip.is_valid_ip_address():
		print(str(ip) + ' seems a formally valid ip, continuing...')
		return true
	return false
	
func verify(ip) -> Dictionary:
	var dummy: Dictionary = {'result': false}
	if firewallINI == false and not bannedListINI and (gatewayIPINI == null or gatewayIPINI == "") :
		print("WARNING, all protections are disabled, it is recommended to set at least $gatewayIPINI")
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
				#To execute this command you need to modify /etc/sudoers (Debina/Ubuntu like distributions) to allow the user
				#running this server to pass this command without a password prompt.
				var exit_code = OS.execute("sudo", ["iptabl", "-A", "INPUT", "-s", ip, "-j", "DROP"], output, true)
				print(output)	
				if exit_code == 0:
					print("OK, rule added!") #These rules live on firewall until next OS reboot...but IPes still banned internally with bennedIP file!
				else:
					print("Failed adding firewall rule with exit code: " + str(exit_code))
	return dummy

func attack(ip) -> bool:
	if gatewayIPINI:
		if ip != gatewayIPINI: 
			prints('Connection from untrusted IP:', ip)
			return true
		print('it\'s not an attack, continuing...' )
		return false
	print('Attack checking disabled')
	return false

