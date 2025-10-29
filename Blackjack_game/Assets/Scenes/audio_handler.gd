extends Node3D

@onready var dealer_hand_audio_player: AudioStreamPlayer3D = $DealerHandAudioPlayer
@onready var player_hand_audio_player: AudioStreamPlayer3D = $PlayerHandAudioPlayer

var Sounds = []
var CardsPlaceSounds = []
var ChipSounds = []
var Shuffle: String
var InitalChipPlace: String
var FilePath: String
var AudioFile
var NumOfCardSounds: int
var NumOfChipSounds: int
func _ready() -> void:
	Sounds = DirAccess.get_files_at("res://Assets/Sounds/Audio/")
	for file in Sounds:
		FilePath = "res://Assets/Sounds/Audio/" + file
		if "import" in file:
			Sounds.erase(file)
		elif "card" in file:
			CardsPlaceSounds.append(FilePath)
			Sounds.erase(file)
		elif "chip" in file:
			ChipSounds.append(FilePath)
			Sounds.erase(file)
	Shuffle = "res://Assets/Sounds/Audio/shuffle.ogg"
	InitalChipPlace = "res://Assets/Sounds/Audio/inital_place.ogg"
	NumOfCardSounds = len(CardsPlaceSounds)-1
	NumOfChipSounds = len(ChipSounds)-1
	
	Sounds.clear()

func _card_delt():
	var SoundVariation = randi_range(0, NumOfCardSounds)
	AudioFile = load(CardsPlaceSounds[SoundVariation])
	player_hand_audio_player.stream = AudioFile
	player_hand_audio_player.play()
	AudioFile = null
	
func _shuffle_cards():
	AudioFile = load(Shuffle)
	player_hand_audio_player.stream = AudioFile
	player_hand_audio_player.play()
	AudioFile = null
	
func _chip_placement(is_first):
	if is_first:
		AudioFile = load(InitalChipPlace)
	else:
		var SoundVariation = randi_range(0, NumOfChipSounds)
		AudioFile = load(ChipSounds[SoundVariation])
	player_hand_audio_player.stream = AudioFile
	player_hand_audio_player.play()
