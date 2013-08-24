all: install

sprites:
	cd WizardWar && bash images/packTextures.sh
    
install: sprites
    