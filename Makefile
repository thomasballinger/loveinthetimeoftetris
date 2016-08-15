all: love.js tetrisSong.js

love.js: *.elm
	elm make Main.elm --output=love.js

dev: imgs

test: *.elm tests/*.elm
	cd tests; elm test Main.elm

deploy: love.js dev script.js tetrisSong.js style.css
	rsync -r index.html love.js style.css script.js tetrisSong.js imgs tom:/home/tomb/elmgame

clean:
	rm index.html

tetrisSong.js: MidiConvert.js tetris.mid
	node midi2js.js tetris.mid tetrisSong.js


#static assets

tone.js:
	curl -s https://tonejs.github.io/CDN/latest/Tone.js > Tone.js

MidiConvert.js:
	curl -s https://raw.githubusercontent.com/Tonejs/MidiConvert/d66d0571ecd9d5f2cda11e2a21b53645fd63c219/build/MidiConvert.js > MidiConvert.js

imgs: imgs/mario/jump/left.gif imgs/mario/jump/right.gif imgs/mario/stand/left.gif imgs/mario/stand/right.gif imgs/mario/walk/left.gif imgs/mario/walk/right.gif

imgs/mario/jump/left.gif:
	mkdir -p imgs/mario/jump
	curl -s http://elm-lang.org/imgs/mario/jump/left.gif > imgs/mario/jump/left.gif

imgs/mario/jump/right.gif:
	mkdir -p imgs/mario/jump
	curl -s http://elm-lang.org/imgs/mario/jump/right.gif > imgs/mario/jump/right.gif

imgs/mario/stand/left.gif:
	mkdir -p imgs/mario/stand
	curl -s http://elm-lang.org/imgs/mario/stand/left.gif > imgs/mario/stand/left.gif

imgs/mario/stand/right.gif:
	mkdir -p imgs/mario/stand
	curl -s http://elm-lang.org/imgs/mario/stand/right.gif > imgs/mario/stand/right.gif

imgs/mario/walk/left.gif:
	mkdir -p imgs/mario/walk
	curl -s http://elm-lang.org/imgs/mario/walk/left.gif > imgs/mario/walk/left.gif

imgs/mario/walk/right.gif:
	mkdir -p imgs/mario/walk
	curl -s http://elm-lang.org/imgs/mario/walk/right.gif > imgs/mario/walk/right.gif
