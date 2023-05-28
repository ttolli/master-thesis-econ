// Child stunting (HAZ)
gen childStunting = .
replace childStunting = 1 if hw70 <= -200
replace childStunting = 0 if hw70 > -200 & hw70 < 500

// Child underweight
gen childUnderweight =.
replace childUnderweight = 1 if hw71 <= -200
replace childUnderweight = 0 if hw71 > -200 & hw71 < 500

// Child wasting
gen childWasting=.
replace childWasting = 1 if hw72 <= -200
replace childWasting = 0 if hw72 > -200 & hw72 < 500