.PHONY: run clean 

run:
	./antivirusd.sh dir malicious_dir 5
clean:
	rm -f directory-info.last directory-info.new
