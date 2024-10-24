.PHONY: prepare clean
ROOT?=/mnt/p/PortableApps

all: available.txt installed.txt
	@./detect.sh

clean:
	rm -f available.txt installed.txt tmp

update2.7z:
	rm -f $@
	wget -nd -nH http://portableapps.com/updater/update2.7z

update.ini: update2.7z
	cp -p $< tmp
	p7zip -d $<
	cp -p tmp $<
	touch update.ini

available.txt: update.ini
	echo hello
	cat $< | sed -n -r "s/^\[(.+)\]/\\1/p" | sort >$@
	wc -l $@

installed.txt:
	(cd /mnt/p/PortableApps; find . -maxdepth 1 -type d) | sed -n -r "s/.+\/([^/]+)$$/\1/p" | sort >$@
	wc -l $@

