# Questa wave and run script
log -r /*
run -all
coverage report -detail -file logs/coverage_detail.txt
coverage report -file logs/coverage_summary.txt
