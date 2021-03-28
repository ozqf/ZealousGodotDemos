class_name Animations

const data = {
	player = {
		name = "player",
		framesPath = "res://assets/sprites/frames/player_frames.tres",
		anims = [
			{
				name = "walk",
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
			{
				name = "aim",
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			{
				name = "shoot",
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			{
				name = "pain",
				frame = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			{
				name = "die",
				frame = [[56,57,58,59,60,61,62]]
			},
			{
				name = "gib",
				frame = [[63,64,65,66,67,68,69,70,71]]
			}
		]
	},
	punk = {
		name = "punk",
		framesPath = "res://assets/sprites/frames/punk_frames.tres",
		anims = [
			{
				name = "walk",
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
			{
				name = "aim",
				frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
			},
			{
				name = "shoot",
				frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
			},
			{
				name = "pain",
				frame = [[48],[49],[50],[51],[52],[53],[54],[55]]
			},
			{
				name = "die",
				frame = [[56,57,58,59,60]]
			},
			{
				name = "gib",
				frame = [[61,62,63,64,65,66,67,68,69]]
			}
		]
	},
	items = {
		name = "items",
		framesPath = "res://assets/sprites/frames/item_frames.tres",
		anims = [
			{ name = "shotgun", frame = [[0]] },
			{ name = "super_shotgun", frame = [[1]] },
			{ name = "chaingun", frame = [[2]] },
			{ name = "rocket_launcher", frame = [[3]] },
			{ name = "plasmagun", frame = [[4]] },
			{ name = "bfg", frame = [[5]] },
			{ name = "chainsaw", frame = [[6]] },
			{ name = "bullets_small", frame = [[7]] },
			{ name = "bullets_large", frame = [[8]] },
			{ name = "shells_small", frame = [[9]] },
			{ name = "shells_large", frame = [[10]] },
			{ name = "rockets_small", frame = [[11]] },
			{ name = "rockets_large", frame = [[12]] },
			{ name = "cells_small", frame = [[13]] },
			{ name = "cells_large", frame = [[14]] },
			{ name = "backpack", frame = [[15]] },
			{ name = "health_tiny", frame = [[16], [17], [18], [19]] },
			{ name = "armour_tiny", frame = [[20], [21], [22], [23]] },
			{ name = "health_small", frame = [[24]] },
			{ name = "health_large", frame = [[25]] },
			{ name = "armour_green", frame = [[26], [27]] },
			{ name = "armour_red", frame = [[28], [29]] },
		]
	}
}
