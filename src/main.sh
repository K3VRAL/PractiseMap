#/bin/sh

# RIP: found out that executing C library functions is difficult/hacky. I'll use something else now

main() {
	arguments $*
	practise
}

arguments() {
	local args=""
	for i in $*; do
		if  [[ $args == "" ]]; then
			case $i in
				"-b" | "--beatmap" )
					args="b"
					;;
				
				"-o" | "--output" )
					args="o"
					;;
				
				"-s" | "--start" )
					args="s"
					;;
				
				"-e" | "--end" )
					args="e"
					;;
				
				"-r" | "--rng" )
					rng=True
					;;
				
				"-h" | "--hardrock" )
					hardrock=True
					;;
			esac
		else
			case $args in
				"b" )
					beatmap=$i
					;;

				"o" )
					output=$i
					;;
					
				"s" )
					start=$i
					;;
					
				"e" )
					end=$i
					;;
			esac
			args=""
		fi
	done
}

practise() {

}

main $*