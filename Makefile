APP := dist/NodgeSpare.app

.PHONY: build run install clean

build:
	./build.sh

run: build
	@pkill -x NodgeSpare 2>/dev/null || true
	open $(APP)
	@echo "NodgeSpare is running — look for the notch icon in the menu bar."

install: build
	@pkill -x NodgeSpare 2>/dev/null || true
	rm -rf /Applications/NodgeSpare.app
	cp -R $(APP) /Applications/
	open /Applications/NodgeSpare.app

clean:
	rm -rf .build dist
