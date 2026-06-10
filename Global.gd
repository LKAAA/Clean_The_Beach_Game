extends Node

var coconut_count: int = 0
var cur_trash_count: int = 0
var holding_trash_bag: bool = false


var interact_level: int = 0
var max_trash_count: int = 40

var total_region_count: int = 3
var completed_regions: int = 0
var all_regions_complete: bool = false
var game_complete: bool = false
signal region_complete

var current_tutorial_part: int = 1
var thrown_trash: int = 0
var tutorial_trash_collected: int = 0
