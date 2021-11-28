PACKER_VERSION=1.7.8
PWN_HOSTNAME=pwnagotchi
PWN_VERSION=dev

all: clean install image

langs:
	@for lang in pwnagotchi/locale/*/; do\
		echo "compiling language: $$lang ..."; \
		./scripts/language.sh compile $$(basename $$lang); \
    done

install:
	curl https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -o /tmp/packer.zip
	unzip /tmp/packer.zip -d /tmp
	sudo mv /tmp/packer /usr/bin/packer
	git clone https://github.com/solo-io/packer-builder-arm-image /tmp/packer-builder-arm-image
	cd /tmp/packer-builder-arm-image && go get -d ./... && go build
	sudo cp /tmp/packer-builder-arm-image/packer-plugin-arm-image /usr/bin

image:
	cd builder && sudo /usr/bin/packer build -var "pwn_hostname=$(PWN_HOSTNAME)" -var "pwn_version=$(PWN_VERSION)" pwnagotchi.json
	sudo mv builder/output-pwnagotchi/image pwnagotchi-raspbian-lite-$(PWN_VERSION).img
	sudo sha256sum pwnagotchi-raspbian-lite-$(PWN_VERSION).img > pwnagotchi-raspbian-lite-$(PWN_VERSION).sha256
	sudo zip pwnagotchi-raspbian-lite-$(PWN_VERSION).zip pwnagotchi-raspbian-lite-$(PWN_VERSION).sha256 pwnagotchi-raspbian-lite-$(PWN_VERSION).img

install-ng:
	curl https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -o /tmp/packer.zip
	unzip /tmp/packer.zip -d /tmp
	sudo mv /tmp/packer /usr/bin/packer
	git clone https://github.com/mkaczanowski/packer-builder-arm /tmp/packer-builder-arm
	cd /tmp/packer-builder-arm && go mod download && go build
	sudo cp /tmp/packer-builder-arm/packer-builder-arm /usr/bin

image-ng:
	cd builder-ng && sudo /usr/bin/packer build -var "pwn_hostname=$(PWN_HOSTNAME)" -var "pwn_version=$(PWN_VERSION)" pwnagotchi.json
	sudo mv builder-ng/pwnagotchi.img pwnagotchi-raspios-lite-$(PWN_VERSION).img
	sudo sha256sum pwnagotchi-raspios-lite-$(PWN_VERSION).img > pwnagotchi-raspios-lite-$(PWN_VERSION).sha256
	sudo zip pwnagotchi-raspios-lite-$(PWN_VERSION).zip pwnagotchi-raspios-lite-$(PWN_VERSION).sha256 pwnagotchi-raspios-lite-$(PWN_VERSION).img

clean:
	rm -rf /tmp/packer-builder-arm-image
	rm -rf /tmp/packer-builder-arm
	rm -f pwnagotchi-raspbian-lite-*.zip pwnagotchi-raspbian-lite-*.img pwnagotchi-raspbian-lite-*.sha256
	rm -f pwnagotchi-raspios-lite-*.zip pwnagotchi-raspios-lite-*.img pwnagotchi-raspios-lite-*.sha256
	rm -rf builder/output-pwnagotchi  builder/packer_cache
	rm -rf builder-ng/pwnagotchi.img  builder-ng/packer_cache
