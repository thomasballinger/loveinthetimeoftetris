
index.html: Main.elm
	elm make Main.elm --output=index.html
	sed -i '' 's_http://localhost:8080/_/_g' index.html

style.css: index.html

deploy: index.html style.css
	rsync -r index.html style.css tom:/home/tomb/elmgame

#deploy should be updated to make changes to the html

clean:
	rm index.html
