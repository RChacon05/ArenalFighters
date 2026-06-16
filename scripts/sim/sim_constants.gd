class_name SimConstants
extends RefCounted

const TICK_HZ := 60

const SUBPIXEL := 1000

const GRAVITY := 270
const MOVE_SPEED := 5000
const JUMP_VELOCITY := -8333
const FLOOR_Y := 400000

const BTN_LEFT := 1 << 0
const BTN_RIGHT := 1 << 1
const BTN_JUMP := 1 << 2
const BTN_ATTACK := 1 << 3

enum State { IDLE, WALK, JUMP, ATTACK, HIT, DEAD }

const ATTACK_TICKS := 30
const HIT_TICKS := 12
