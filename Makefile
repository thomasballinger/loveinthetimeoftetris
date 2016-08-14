
love.js: *.elm
	elm make Main.elm --output=love.js

dev: imgs

test: *.elm tests/*.elm
	cd tests; elm test Main.elm

deploy: love.js imgs script.js tetris.js style.css
	rsync -r index.html love.js style.css script.js tetris.js imgs tom:/home/tomb/elmgame

#deploy should be updated to make changes to the html

clean:
	rm index.html

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
