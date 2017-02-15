build:
	hugo --theme=raven

serve:
	hugo --theme=raven --watch server

beta: build
	rsync -rav public/ raven-02:/var/www/beta.elcuervo.net

release: build
	rsync -rav public/ raven-01:/var/www/elcuervo.net
