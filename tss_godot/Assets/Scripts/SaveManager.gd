extends Node
#####Data Structure used to store leaderboard entries
class ScoreEntry:

	var name_: String
	var score: int

	func _init(_name: String = "", _score: int = 0):
		name_ = _name
		score = _score


######
var score_list: Array
var file_path: String = "user://scores.txt"

func _ready():
	score_list = read_save()
	score_list.sort_custom(func(a, b): return a.score > b.score)

#Reads the save file and then returns the scores
func read_save() -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var temp_list: Array = []
	if file:
		while not file.eof_reached():
			var line = file.get_csv_line()
			if line.size() >= 2:
				temp_list.append(ScoreEntry.new(line[0], int(line[1])))
			else:
				push_warning("FileFormatIssue: Line content not full")
	return temp_list

func save(score:int, name_:String):
	if add_score(score, name_):
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		for entry in score_list:
			file.store_line(entry.name_ + "," + str(entry.score))
		file.close()

func add_score(score:int, name_:String)-> bool:
	if score_list.size() > 0 and score_list[score_list.size() -1].score >= score:
		return false
	else:
		var idx = find_insertion_index(score)
		score_list.insert(idx, ScoreEntry.new(name_, score))
		while score_list.size() > 100:
			score_list.pop_back()
		return true

func find_insertion_index(score:int) -> int:
	for i in range(score_list.size()):
		if score_list[i] < score:
			return i
	return score_list.size()
