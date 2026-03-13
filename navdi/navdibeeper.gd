extends HTTPRequest
class_name NavdiBeeper
const BEEPER_BEEP_GROUP : String = &"BeeperGroup"
const URL_PLAY : String = "http://127.0.0.1:3000/play-synth"
const URL_PAUSE: String = "http://127.0.0.1:3000/pause-synth"
const HEADERS : PackedStringArray = ["Content-Type: application/json"]

var last_played_url:String = ''

var navdilink:JavaScriptObject

func _ready() -> void:
	print("clientside NavdiBeeper initialized!")
	if OS.has_feature("editor"):
		print("remember to launch the local beepbox puppet!")
		print("> cd ~/beepboxpuppet")
		print("> HEADFUL=1 node server2.mjs")
	else:
		navdilink = JavaScriptBridge.get_interface("navdilink")
		if navdilink == null:
			push_warning("No navdilink js bridge found.")
		# we're hitting da browser

func _physics_process(_delta: float) -> void:
	var topbeep = get_tree().get_first_node_in_group(BEEPER_BEEP_GROUP)
	if topbeep: play(topbeep.get_beepbox_url())
	elif Dreamer.dream_stack and Dreamer.dream_stack[-1]:
		play(Dreamer.dream_stack[-1].beepbox_url)
	else: play('') # stop

func _exit_tree() -> void:
	play('')

func play(url:String) -> void:
	if last_played_url != url:
		last_played_url = url
		if url:
			if navdilink:
				navdilink.play_bgm_string(url.split('#',false,1)[1])
			else:
				print(URL_PLAY)
				_send_request.call_deferred(URL_PLAY, {
					"restart": true,
					"song": url.split('#',false,1)[1]
				})
		else:
			if navdilink:
				navdilink.stop_bgm()
			else:
				_send_request.call_deferred(URL_PAUSE)

func _send_request(url : String, keys : Dictionary = {}) -> void:
	var err = request(url, HEADERS, HTTPClient.METHOD_POST, JSON.stringify(keys))
	if err != OK:
		push_error("NavdiBeeper error %s = %s" % [url, err])

func _on_request_completed(
	result: int,
	_response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray) -> void:
	print(result)
