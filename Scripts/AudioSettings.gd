extends Control

# Audio buses (make sure these match your audio bus names in Godot)
const MASTER_BUS: String = "Master"
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"

# UI References - assign these in the inspector or create them in code
@onready var master_slider: HSlider = $VBoxContainer/MasterVolume/HSlider
@onready var music_slider: HSlider = $VBoxContainer/MusicVolume/HSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXVolume/HSlider

@onready var master_value_label: Label = $VBoxContainer/MasterVolume/ValueLabel
@onready var music_value_label: Label = $VBoxContainer/MusicVolume/ValueLabel
@onready var sfx_value_label: Label = $VBoxContainer/SFXVolume/ValueLabel

func _ready() -> void:
	# Set up sliders
	_setup_slider(master_slider, MASTER_BUS)
	_setup_slider(music_slider, MUSIC_BUS)
	_setup_slider(sfx_slider, SFX_BUS)
	
	# Connect slider signals
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Load saved settings
	_load_audio_settings()

func _setup_slider(slider: HSlider, bus_name: String) -> void:
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	
	# Get current bus volume and convert to percentage
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	var volume_db: float = AudioServer.get_bus_volume_db(bus_idx)
	var volume_percent: float = db_to_percent(volume_db)
	slider.value = volume_percent

func _on_master_volume_changed(value: float) -> void:
	_set_bus_volume(MASTER_BUS, value)
	master_value_label.text = str(int(value)) + "%"
	_save_audio_settings()

func _on_music_volume_changed(value: float) -> void:
	_set_bus_volume(MUSIC_BUS, value)
	music_value_label.text = str(int(value)) + "%"
	_save_audio_settings()

func _on_sfx_volume_changed(value: float) -> void:
	_set_bus_volume(SFX_BUS, value)
	sfx_value_label.text = str(int(value)) + "%"
	_save_audio_settings()

func _set_bus_volume(bus_name: String, percent: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	var volume_db: float = percent_to_db(percent)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

func percent_to_db(percent: float) -> float:
	if percent <= 0:
		return -80.0  # Effectively muted
	return linear_to_db(percent / 100.0)

func db_to_percent(db: float) -> float:
	if db <= -80:
		return 0.0
	return db_to_linear(db) * 100.0

func _save_audio_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://audio_settings.cfg")

func _load_audio_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("user://audio_settings.cfg")
	
	if err == OK:
		master_slider.value = config.get_value("audio", "master_volume", 100.0)
		music_slider.value = config.get_value("audio", "music_volume", 100.0)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 100.0)


func _on_seetings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UserInterface/main_menu.tscn")
