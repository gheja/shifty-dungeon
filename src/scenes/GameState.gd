extends Node

const CONTROL_KEYBOARD = 0
const CONTROL_MOUSE = 1
const CONTROL_CPU = 2

const STATE_MENU = 1
const STATE_RUNNING = 2
const STATE_FINISHED = 3

var is_swapped: bool = false
var state: int = 0

