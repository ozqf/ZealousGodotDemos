class_name Animations

const player = {
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
}

const punk = {
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
}
