class_name Animations

const data = {
	# new format
	player = {
		name = "player",
		path = "res://assets/sprites/frames/player_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			}
		}
	},
	punk = {
		name = "punk",
		path = "res://assets/sprites/frames/punk_frames.tres",
		offset = 32,
		anims = {
			walk = {
				frames = [
					[ 0, 8, 16, 24 ],
					[ 1, 9, 17, 25 ],
					[ 2, 10, 18, 26 ],
					[ 3, 11, 19, 27 ],
					[ 4, 12, 20, 28 ],
					[ 5, 13, 21, 29 ],
					[ 6, 14, 22, 30 ],
					[ 7, 15, 23, 31 ]
				]
			},
			aim = {
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			shoot = {
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			pain = {
				frames = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			dying = {
				loopIndex = 4,
				frames = [[56,57,58,59,60]]
			},
			dead = {
				frames = [[60]]
			},
			dying_gib = {
				frames = [[61],[62],[63],[64],[65],[66],[67],[68],[69]]
			},
			dead_gib = {
				frames = [[69]]
			}
		}
	},
	
	items = {
		name = "items",
		framesPath = "res://assets/sprites/frames/item_frames.tres",
		anims = {
			shotgun = { frames = [[0]] },
			super_shotgun = { frames = [[1]] },
			chaingun = { frame = [[2]] },
			rocket_launcher = { frame = [[3]] },
			plasmagun = { frame = [[4]] },
			bfg = { frame = [[5]] },
			chainsaw = { frame = [[6]] },
			flame_launcher = { frame = [[7]] },
		}
	}
}
