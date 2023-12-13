import os
import logging

logger = logging.getLogger(__name__)

from pywm import (
    PYWM_TRANSFORM_90,
    PYWM_TRANSFORM_180,
    PYWM_TRANSFORM_270,
    PYWM_TRANSFORM_FLIPPED,
    PYWM_TRANSFORM_FLIPPED_90,
    PYWM_TRANSFORM_FLIPPED_180,
    PYWM_TRANSFORM_FLIPPED_270,
)

from newm.helper import BacklightManager, WobRunner, PaCtl, execute

def on_startup():
    #os.system("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots QT_QPA_PLATFORM=wayland-egl")
    os.system("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots QT_QPA_PLATFORM=wayland-egl")
    os.system("hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd DISPLAY \
        WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots QT_QPA_PLATFORM=wayland-egl")
    os.system("systemctl --user restart xdg-desktop-portal-wlr.service")
    os.system("wl-paste --watch cliphist store &")

def on_reconfigure():
    os.system("notify-send newm \"Reloaded config\" &")
            
corner_radius = 0.0
#corner_radius = 20.5

outputs = [
    { 'name': 'eDP-1', 'width': 2256, 'height': 1504, 'pos_x': 0, 'pos_y': 0, 'scale': 1. }, # },
    { 'name': 'virt-1', 'pos_x': 1280, 'pos_y': 0, 'width': 1280, 'height': 720, 'scale': 1., 
        'mHz': 30000, 'anim': False},
    { 'name': 'DP-5', 'pos_x': 0, 'pos_y': -1050 },
    { 'name': 'DP-6', 'pos_x': -3000, 'pos_y': -1920, 'transform': PYWM_TRANSFORM_90 },
    { 'name': 'DP-7', 'pos_x': -1920, 'pos_y': -1200 },
    # Büro
    # { 'name': 'DP-2', 'pos_x': 0, 'pos_y': -1920, 'transform': PYWM_TRANSFORM_90 },
    # { 'name': 'DP-1', 'pos_x': 1128, 'pos_y': -1440 }
]

pywm = {
    # 'xkb_model': "macintosh",
    'xkb_model': "pc105",
    'xkb_layout': "de",
    'xkb_variant': "neo",
    #'xkb_options': "caps:escape",

    'xcursor_theme': 'Adwaita',
    'xcursor_size': 24,

    'encourage_csd': False,
    'enable_xwayland': True,

    'natural_scroll': True,

    'texture_shaders': 'basic',
    'renderer_mode': 'pywm'
}

def rules(view):
    if view.app_id == "catapult":
        return { 'float': True, 'float_pos': (0.5, 0.25) }
    if view.app_id == "pavucontrol":
        return { 'float': True, 'float_size': (340, 600), 'float_pos': (0.15, 0.4) }
    if view.title is not None and view.title.strip() == "Firefox — Sharing Indicator":
        return { 'float': True, 'float_size': (100, 40), 'float_pos': (0.5, 0.1) }
    if view.title is not None and "Firefox — Sharing Indicator" in view.title:
        return { 'float': True, 'float_size': (100, 40), 'float_pos': (0.5, 0.1) }
    if view.app_id == "Alacritty":
        return { 'blur': { 'radius': 5, 'passes': 3}}
    if view.app_id == "waybar":
        return { 'blur': { 'radius': 5, 'passes': 3}}
    if view.app_id == "syncthingtray":
        return { 'float': True }
    return None

view = {
    'padding': 8,
    'fullscreen_padding': 0,
    'send_fullscreen': False,
    'accept_fullscreen': False,

    'rules': rules,
    'floating_min_size': False,

    'debug_scaling': True,
    'border_ws_switch': 100,
}

swipe_zoom = {
    'grid_m': 1,
    'grid_ovr': 0.02,
}


mod = "L"
background = {
    'path': os.environ['HOME'] + '/wallpaper.jpg',
    'time_scale': 0.125,
    'anim': True,
}

anim_time = .25
blend_time = .5

wob_runner = WobRunner("wob -a bottom -M 100")
#backlight_manager = BacklightManager(anim_time=1., bar_display=wob_runner)
backlight_manager = BacklightManager(args="--device=intel_backlight", anim_time=1.)
#kbdlight_manager = BacklightManager(args="--device='*::kbd_backlight'", anim_time=1., bar_display=wob_runner)
def synchronous_update() -> None:
    backlight_manager.update()
    return
    #kbdlight_manager.update()

pactl = PaCtl(0, wob_runner)

def adjust_current_volume(delta):
    current_sink = execute("pactl list short sinks | grep RUNNING | awk '{print $1}'")
    current_sink = current_sink.strip()
    if current_sink.isdigit():
        current_pactl = PaCtl(int(current_sink))
        current_pactl.volume_adj(delta)
    else:
        pactl.volume_adj(delta)

key_bindings = lambda layout: [
    (mod+"-n", lambda: layout.move(-1, 0)),
    (mod+"-r", lambda: layout.move(0, 1)),
    (mod+"-g", lambda: layout.move(0, -1)),
    (mod+"-t", lambda: layout.move(1, 0)),
    (mod+"-s", lambda: layout.move_in_stack(1)),

    (mod+"-N", lambda: layout.move_focused_view(-1, 0)),
    (mod+"-R", lambda: layout.move_focused_view(0, 1)),
    (mod+"-G", lambda: layout.move_focused_view(0, -1)),
    (mod+"-T", lambda: layout.move_focused_view(1, 0)),

    (mod+"-C-n", lambda: layout.resize_focused_view(-1, 0)),
    (mod+"-C-r", lambda: layout.resize_focused_view(0, 1)),
    (mod+"-C-g", lambda: layout.resize_focused_view(0, -1)),
    (mod+"-C-t", lambda: layout.resize_focused_view(1, 0)),

    (mod+"-v", lambda: layout.toggle_focused_view_floating()),
    (mod+"-w", lambda: layout.change_focused_view_workspace()),
    (mod+"-W", lambda: layout.move_workspace()),
    (mod+"-S", lambda: os.system("grim -g \"$(slurp)\" &")),

    (mod+"-Return", lambda: os.system("alacritty &")),
    #(mod+"-e", lambda: os.system("emacsclient -c -F \'((font . \"Iosevka-12:spacing=90\"))\' -a \'emacs\' &")),
    (mod+"-e", lambda: os.system("emacsclient -c -a \'emacs\' &")),
    (mod+"-b", lambda: os.system("env MOZ_ENABLE_WAYLAND=1 firefox &")),
    (mod+"-A-n", lambda: os.system("swaync-client -t &")),
    (mod+"-c", lambda: os.system("cliphist list | rofi -dmenu | cliphist decode | wl-copy &")),
    (mod+"-A-c", lambda: os.system("cliphist list | rofi -dmenu | cliphist decode | wl-copy &")),
    #(mod+"-m", lambda: os.system("bash /$HOME/.shell/macho-gui.sh &")),
    (mod+"-q", lambda: layout.close_view()),

    (mod+"-p", lambda: layout.ensure_locked(dim=True)),
    (mod+"-P", lambda: layout.terminate()),
    (mod+"-C", lambda: layout.update_config()),

    (mod+"-a", lambda: os.system("rofi -show run &")),
    (mod+"-f", lambda: layout.toggle_fullscreen()),

    (mod+"-", lambda: layout.toggle_overview(only_active_workspace=False)),
    (mod+"-j", lambda: layout.toggle_overview()),

    ("XF86MonBrightnessUp", lambda: backlight_manager.set(backlight_manager.get() + 0.05)),
    ("XF86MonBrightnessDown", lambda: backlight_manager.set(backlight_manager.get() - 0.05)),
    #("XF86KbdBrightnessUp", lambda: kbdlight_manager.set(kbdlight_manager.get() + 0.1)),
    #("XF86KbdBrightnessDown", lambda: kbdlight_manager.set(kbdlight_manager.get() - 0.1)),
    #("XF86AudioRaiseVolume", lambda: pactl.volume_adj(5)),
    ("XF86AudioRaiseVolume", lambda: adjust_current_volume(5)),
    #("XF86AudioLowerVolume", lambda: pactl.volume_adj(-5)),
    ("XF86AudioLowerVolume", lambda: adjust_current_volume(-5)),
    ("XF86AudioMute", lambda: pactl.mute()),

    ("XF86LaunchA", lambda: None),
    ("XF86LaunchB", lambda: None),
    ("XF86AudioPrev", lambda: None),
    ("XF86AudioPlay", lambda: None),
    ("XF86AudioNext", lambda: None),

    (mod+"-z", lambda: layout.swallow_focused_view()),
]

gestures = {
    'lp_freq': 120.,
    'lp_inertia': 0.4,

    'c': {'enabled': True, 'scale_px': 800},
    'pyevdev': {'enabled': False},
}

swipe = {
    'gesture_factor': 3
}

panels = {
    'lock': {
        'cmd': 'alacritty -e newm-panel-basic lock',
        'w': 0.7,
        'h': 0.6,
        'corner_radius': 50,
    },
    #'launcher': {
    #    'cmd': 'alacritty -e newm-panel-basic launcher',
    #    'w': 0.7,
    #    'h': 0.6,
    #    'corner_radius': 50,
    #},
    'bar': {
        'cmd': 'waybar'
    },
}

grid = {
    'throw_ps': [2, 10]
}

energy = {
    'idle_times': [60, 180],
    'idle_callback': backlight_manager.callback
}

focus = {
    'color': '#92f0f5d1',
    'enabled': True
}




