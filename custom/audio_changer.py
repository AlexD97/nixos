#!/usr/bin/env python 
import subprocess
import argparse

def parse_pactl_status():
    # Execute the pactl list sinks command and store the running sink ids in a list.
    output = str(subprocess.check_output("pactl list short sinks | grep RUNNING | awk '{print $1}'", shell=True, encoding='utf-8'))
    running_sinks = output.splitlines()
    return running_sinks

# function to parse output of command "wpctl status" and return a dictionary of sinks with their id and name.
def parse_wpctl_status():
    # Execute the wpctl status command and store the output in a variable.
    output = str(subprocess.check_output("wpctl status", shell=True, encoding='utf-8'))

    # remove the ascii tree characters and return a list of lines
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    # get the index of the Sinks line as a starting point
    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break

    # start by getting the lines after "Sinks:" and before the next blank line and store them in a list
    sinks = []
    for line in lines[sinks_index +1:]:
        if not line.strip():
            break
        sinks.append(line.strip())

    # remove the "[vol:" from the end of the sink name
    for index, sink in enumerate(sinks):
        sinks[index] = sink.split("[vol:")[0].strip()
    
    # strip the * from the default sink and instead append "- Default" to the end. Looks neater in the rofi list this way.
    for index, sink in enumerate(sinks):
        if sink.startswith("*"):
            sinks[index] = sink.strip().replace("*", "").strip() + " - Default"

    # make the dictionary in this format {'sink_id': <int>, 'sink_name': <str>}
    sinks_dict = [{"sink_id": int(sink.split(".")[0]), "sink_name": sink.split(".")[1].strip()} for sink in sinks]

    return sinks_dict

def select_default_sink():
    # get the list of sinks ready to put into rofi - highlight the current default sink
    output = ''
    sinks = parse_wpctl_status()
    for items in sinks:
        if items['sink_name'].endswith(" - Default"):
            output += f"<b>-> {items['sink_name']}</b>\n"
        else:
            output += f"{items['sink_name']}\n"

    # Call rofi and show the list. take the selected sink name and set it as the default sink
    rofi_command = f"echo '{output}' | rofi -dmenu -markup-rows -theme-str '#window {{ width: 40%; height: 20%; anchor: northeast; location: northeast; }}'"
    rofi_process = subprocess.run(rofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if rofi_process.returncode != 0:
        print("User cancelled the operation.")
        exit(0)

    selected_sink_name = rofi_process.stdout.strip()
    sinks = parse_wpctl_status()
    selected_sink = next(sink for sink in sinks if sink['sink_name'] == selected_sink_name)
    subprocess.run(f"wpctl set-default {selected_sink['sink_id']}", shell=True)

def main():
    arg_parser = argparse.ArgumentParser(description="Change the volume of the running audio sink.")
    arg_parser.add_argument("-v", "--volume", type=int, help="The absolute volume to set the sink to.")
    arg_parser.add_argument("-s", "--select", action="store_true", help="Select the default sink.")
    arg_parser.add_argument("-m", "--mute", action="store_true", help="Toggle mute the current running sinks.")
    arg_parser.add_argument("-l", "--lower", action="store_true", help="Lower the volume of the current running sinks.")
    arg_parser.add_argument("-r", "--raise", action="store_true", help="Raise the volume of the current running sinks.")
    args = arg_parser.parse_args()

    if args.select:
        select_default_sink()
    else:
        running_sinks = parse_pactl_status()
        running_sinks = [str(int(sink)-1) for sink in running_sinks]
        if len(running_sinks) == 0:
            running_sinks = ["@DEFAULT_AUDIO_SINK@"]
        for sink in running_sinks:
            if args.volume:
                change_volume(sink, args.volume)
            elif args.mute:
                subprocess.run(f"wpctl set-mute {sink} toggle", shell=True)
            elif args.lower:
                subprocess.run(f"wpctl set-volume {sink} 5%-", shell=True)
            elif args.upper:
                subprocess.run(f"wpctl set-volume {sink} 5%+", shell=True)
                

if __name__ == "__main__":
    main()
        
    
