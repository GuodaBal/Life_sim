extends Node
class_name Personality

#All personality traits
enum PersonalityTrait {
	EXTROVERTED,
	SEDENTARY,
	SILLY,
	MEAN,
	INTROVERTED,
	ACTIVE,
	SERIOUS,
	NICE
}

var extroverted = 0
var sedentary = 0
var silly = 0
var mean = 0

func set_personality(extrovertedness, sedentariness, sillyness, meanness):
	extroverted = extrovertedness
	sedentary = sedentariness
	silly = sillyness
	mean = meanness

func get_value_by_name(name):
	match name:
		PersonalityTrait.EXTROVERTED:
			return extroverted
		PersonalityTrait.SEDENTARY:
			return sedentary
		PersonalityTrait.SILLY:
			return silly
		PersonalityTrait.MEAN:
			return mean
		PersonalityTrait.INTROVERTED:
			return 1 - extroverted
		PersonalityTrait.ACTIVE:
			return 1 - sedentary
		PersonalityTrait.SERIOUS:
			return 1 - silly
		PersonalityTrait.NICE:
			return 1 - mean
