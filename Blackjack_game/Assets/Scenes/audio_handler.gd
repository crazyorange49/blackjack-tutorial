extends Node3D

@onready var card_place_sounds: Node = $CardPlaceSounds
@onready var chip_place_sounds: Node = $ChipPlaceSounds
@onready var inital_place: AudioStreamPlayer = $InitalPlace
@onready var shuffle: AudioStreamPlayer = $Shuffle

var Sounds = []
var CardsPlaceSounds = []
var ChipSounds = []
var Shuffle: String
var InitalChipPlace: String
var FilePath: String
var AudioFile: AudioStreamPlayer
var NumOfCardSounds: int
var NumOfChipSounds: int
var SoundVolume: float = -10.0
func _ready() -> void:	
	NumOfCardSounds = card_place_sounds.get_child_count()-1
	NumOfChipSounds = chip_place_sounds.get_child_count()-1
	print_debug(CardsPlaceSounds)
	print_debug(Sounds)

func _card_delt():
	var SoundVariation = randi_range(0, NumOfCardSounds)
	AudioFile = card_place_sounds.get_child(SoundVariation)
	AudioFile.volume_db = SoundVolume
	AudioFile.play()
	AudioFile = null
	
func _shuffle_cards():
	shuffle.play()
	AudioFile = null
	
func _chip_placement(is_first):
	if is_first:
		AudioFile = inital_place
	else:
		var SoundVariation = randi_range(0, NumOfChipSounds)
		AudioFile = chip_place_sounds.get_child(SoundVariation)
	AudioFile.volume_db = SoundVolume
	AudioFile.play()
	AudioFile = null
