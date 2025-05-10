desktop_file=$(grep -ril "${APP}" ~/.local/share/applications/ /usr/share/applications/ | head -n 1)
exec_cmd=$(grep -m 1 '^Exec=' "$desktop_file" | cut -d= -f2-)
eval "$exec_cmd"
