.PHONY: run clean 

prepare:
	mkdir -p malicious_dir

run:prepare
	./antivirusd.sh dir malicious_dir 5

restore:prepare
	./restore.sh dir malicious_dir

clean:
	rm -f directory-info.last directory-info.new
