local wezterm = require('wezterm');
local wez_mods = "SUPER|ALT";
local act = wezterm.action;
local firacode = "FiraCode Nerd Font Mono"

-- wezterm.GLOBAL is a data structure which survives the reload of the
-- configuration, but it is of kind "userdata" and not a regular lua
-- table, e.g. iteration does not work as expected
--     for k,v in wezterm.GLOBAL.tbl do; print(v[k]); end
-- results in
--     attempt to call a userdata value (for iterator 'for iterator').
-- Therefore some workarounds are needed.
if not wezterm.GLOBAL.harfbuzz_features then
   wezterm.GLOBAL.harfbuzz_features = {
      "ss01=0", -- default letter r
      "ss02=0", -- default >= and <= ligatures
      "ss03=1", -- variant of & character (which actually looks more "default")
      "ss04=0", -- default $ character
      "ss05=1", -- variant of @ character (which actually looks more "default")
      "ss06=0", -- default // ligature (I don't see a difference to the variant)
      "ss07=1", -- ligatures of =~ and !~ (instead of no ligatures)
      "ss08=0", -- default ligatures for == === != !==
      "zero=1", -- variant for digit 0 with a dot in the center
      "onum=1", -- digit characters 123456789 variant with ascenders and descenders
      -- ligatures
      "liga=1", "clig=1", "calt=1"
   }
end

wezterm.on("toggle_font_shaping", function() toggle_font_shaping({"liga", "clig", "calt"}); end)
function toggle_font_shaping(features)
   -- convert the userdata stored in wezterm.GLOBAL.harfbuzz_features into a regular lua table
   local hf = {table.unpack(wezterm.GLOBAL.harfbuzz_features)}
   for _, feature in pairs(features) do
      for hf_key, hf_feature in pairs(hf) do
         if hf_feature == feature.."=0" then
            hf[hf_key] = feature.."=1"
         elseif hf_feature == feature.."=1" then
            hf[hf_key] = feature.."=0"
         end
      end
   end
   wezterm.GLOBAL.harfbuzz_features = hf
   wezterm.reload_configuration()
end

-- do return { default_prog = {"/usr/bin/bash", "-l"}, } end
config = {
   -- general options
   --front_end = "WebGpu", -- WebGpu or OpenGL: both of them are faster than "Software", but Sixel images soon become blury, when texture buffer becomes exceeded
   front_end = "OpenGL", -- OpenGL has (https://github.com/wez/wezterm/issues/3773) larger texture space
   default_prog = {"/usr/bin/bash", "-l"},
   term = "wezterm",
   check_for_updates = false,
   debug_key_events = false,
   automatically_reload_config = false,
   tiling_desktop_environments = {
      'X11 LG3D',
      'X11 bspwm',
      'X11 i3',
      'X11 dwm',
      'X11 herbstluftwm',
   },
   
   -- font related options
   custom_block_glyphs = true,
   font = wezterm.font(firacode),
   dpi = nil, -- use X11 resource Xft.dpi, or default 96dpi (on linux)
   font_size = 10.0,
   freetype_load_target = "HorizontalLcd", -- I cant see any difference to "Normal"
   freetype_render_target = "HorizontalLcd",
   font_shaper = "Harfbuzz",
   harfbuzz_features = wezterm.GLOBAL.harfbuzz_features,
   warn_about_missing_glyphs=false,

   -- appearance
   color_scheme = "olaf",
   bold_brightens_ansi_colors = false,
   window_decorations = "RESIZE", -- "TITLE | RESIZE"
   window_padding = {left = 0, right = 0, top = 0, bottom = 0},
   enable_scroll_bar = true,
   default_cursor_style = "BlinkingBlock",
   cursor_blink_rate = 500,
   cursor_blink_ease_in = "Constant",  -- Linear, Ease, EaseIn, EaseOut, EaseInOut, Constant
   cursor_blink_ease_out = "Constant",
   hide_mouse_cursor_when_typing = false,
   visual_bell = {
      fade_in_function = "EaseIn",
      fade_in_duration_ms = 75,
      fade_out_function = "EaseOut",
      fade_out_duration_ms = 75,
   },

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = true,
   use_fancy_tab_bar = true,
   window_frame = { -- only used with fancy tab bar
      font = wezterm.font({family = firacode}),
      font_size = 10.0,
   },
   
   -- behaviour
   audible_bell = "Disabled",
   window_close_confirmation = "NeverPrompt",
   exit_behavior = "Close",
   scrollback_lines = 10000,
   alternate_buffer_wheel_scroll_speed = 1, -- seems to be ignored
   adjust_window_size_when_changing_font_size = false, -- adjust rows and columns, instead 
   enable_csi_u_key_encoding = true,
   -- enable_kitty_keyboard = true,
   pane_focus_follows_mouse = true,
   scroll_to_bottom_on_input = true,
   swap_backspace_and_delete = false,
   show_tab_index_in_tab_bar = true,

   unix_domains = {
      {
         name = "unix",
      },
   },
   
   -- key bindings
   use_dead_keys = false,
   disable_default_key_bindings = true,
   keys = {
      {key = "Insert", mods = "SHIFT", action = act{PasteFrom = "Clipboard"}},
      {key = "PageUp", mods = "SHIFT", action = act{ScrollByPage = -1}},
      {key = "PageDown", mods = "SHIFT", action = act{ScrollByPage = 1}},
      -- wezterm specific shortcuts
      {key = "d", mods = wez_mods, action = "ShowDebugOverlay"},
      {key = "n", mods = wez_mods, action = act.SpawnTab("DefaultDomain")},
      {key = "r", mods = wez_mods, action = "ReloadConfiguration"},
      {key = "Return", mods = wez_mods, action = act{SpawnTab = "CurrentPaneDomain"}},
      {key = "KeypadSubtract", mods = wez_mods, action = act{CloseCurrentTab = {confirm = false}}},
      {key = "+", mods = wez_mods, action = "IncreaseFontSize"},
      {key = "-", mods = wez_mods, action = "DecreaseFontSize"},
      {key = "LeftArrow", mods = wez_mods, action = act{ActivateTabRelative = -1}},
      {key = "RightArrow", mods = wez_mods, action = act{ActivateTabRelative = 1}},
      {key = "1", mods = wez_mods, action = act{ActivateTab = 0}},
      {key = "2", mods = wez_mods, action = act{ActivateTab = 1}},
      {key = "3", mods = wez_mods, action = act{ActivateTab = 2}},
      {key = "4", mods = wez_mods, action = act{ActivateTab = 3}},
      {key = "5", mods = wez_mods, action = act{ActivateTab = 4}},
      {key = "6", mods = wez_mods, action = act{ActivateTab = 5}},
      {key = "7", mods = wez_mods, action = act{ActivateTab = 6}},
      {key = "8", mods = wez_mods, action = act{ActivateTab = 7}},
      {key = "9", mods = wez_mods, action = act{ActivateTab = 8}},
      {key = "0", mods = wez_mods, action = act{ActivateTab = 9}},

      -- switch font shaping on/off
      {key = "f", mods = wez_mods, action = act.EmitEvent "toggle_font_shaping"},
      
      -- fix ctrl encoding of number keys
      {key = "0", mods = "CTRL", action = act.SendString "\x1b[48;5u"},
      {key = "1", mods = "CTRL", action = act.SendString "\x1b[49;5u"},
      {key = "2", mods = "CTRL", action = act.SendString "\x1b[50;5u"},
      {key = "3", mods = "CTRL", action = act.SendString "\x1b[51;5u"},
      {key = "4", mods = "CTRL", action = act.SendString "\x1b[52;5u"},
      {key = "5", mods = "CTRL", action = act.SendString "\x1b[53;5u"},
      {key = "6", mods = "CTRL", action = act.SendString "\x1b[54;5u"},
      {key = "7", mods = "CTRL", action = act.SendString "\x1b[55;5u"},
      {key = "8", mods = "CTRL", action = act.SendString "\x1b[56;5u"},
      {key = "9", mods = "CTRL", action = act.SendString "\x1b[57;5u"},

      -- fix encoding of Backspace key <--
      {key = "Backspace", mods = "SHIFT",                action = act.SendString "\x1b[127;2u"},
      {key = "Backspace", mods = "ALT",                  action = act.SendString "\x1b[127;3u"},
      {key = "Backspace", mods = "SHIFT|ALT",            action = act.SendString "\x1b[127;4u"},
      {key = "Backspace", mods = "CTRL",                 action = act.SendString "\x1b[127;5u"},
      {key = "Backspace", mods = "CTRL|SHIFT",           action = act.SendString "\x1b[127;6u"},
      {key = "Backspace", mods = "CTRL|ALT",             action = act.SendString "\x1b[127;7u"},
      {key = "Backspace", mods = "CTRL|SHIFT|ALT",       action = act.SendString "\x1b[127;8u"},
      {key = "Backspace", mods = "SUPER",                action = act.SendString "\x1b[127;9u"},
      {key = "Backspace", mods = "SUPER|SHIFT",          action = act.SendString "\x1b[127;10u"},
      {key = "Backspace", mods = "SUPER|ALT",            action = act.SendString "\x1b[127;11u"},
      {key = "Backspace", mods = "SUPER|SHIFT|ALT",      action = act.SendString "\x1b[127;12u"},
      {key = "Backspace", mods = "SUPER|CTRL",           action = act.SendString "\x1b[127;13u"},
      {key = "Backspace", mods = "SUPER|CTRL|SHIFT",     action = act.SendString "\x1b[127;14u"},
      {key = "Backspace", mods = "SUPER|CTRL|ALT",       action = act.SendString "\x1b[127;15u"},
      {key = "Backspace", mods = "SUPER|CTRL|SHIFT|ALT", action = act.SendString "\x1b[127;16u"},

      -- temporarily fix wezterm ctrl glitch
      -- {key = "raw:52", mods = "CTRL", action = act.SendString "\x19"}, -- ^Y
      -- {key = "raw:29", mods = "CTRL", action = act.SendString "\x1a"}, -- ^Z
   },

   -- mouse bindings
   selection_word_boundary = " \t\n{}[]()\"'`",
   bypass_mouse_reporting_modifiers = "SUPER", -- "CTRL|SHIFT",
   disable_default_mouse_bindings = true,
   mouse_bindings = {
      -- mouse bindings for selection of text
      {event = {Down = { streak = 1, button = "Left"}},
       mods = "NONE",
       action = act{SelectTextAtMouseCursor = "Cell"}},

      {event = {Drag = { streak = 1, button = "Left"}},
       mods = "NONE",
       action = act{ExtendSelectionToMouseCursor = "Cell"}},

      {event = {Down = { streak = 1, button = "Right"}},
       mods = "NONE",
       action = act{ExtendSelectionToMouseCursor = "Cell"}},

      {event = {Drag = { streak = 1, button = "Right"}},
       mods = "NONE",
       action = act{ExtendSelectionToMouseCursor = "Cell"}},

      {event = {Down = { streak = 2, button = "Left"}},
       mods = "NONE",
       action = act{SelectTextAtMouseCursor = "Word"}},

      {event = {Down = { streak = 3, button = "Left"}},
       mods = "NONE",
       action = act{SelectTextAtMouseCursor = "Line"}},

      {event = {Down = { streak = 4, button = "Left"}},
       mods = "NONE",
       action = act{SelectTextAtMouseCursor = "SemanticZone"}},

      -- mouse bindings for copying from and to the clipboard
      {event = {Up = { streak = 1, button = "Left"}},
       mods = "NONE",
       action = act{CompleteSelectionOrOpenLinkAtMouseCursor = "ClipboardAndPrimarySelection"}},

      {event = {Up = { streak = 1, button = "Right"}},
       mods = "NONE",
       action = act{CompleteSelectionOrOpenLinkAtMouseCursor = "ClipboardAndPrimarySelection"}},

      {event = {Up = { streak = 2, button = "Left"}},
       mods = "NONE",
       action = act{CompleteSelection = "Clipboard"}},

      {event = {Up = { streak = 3, button = "Left"}},
       mods = "NONE",
       action = act{CompleteSelection = "Clipboard"}},

      {event = {Down = { streak = 1, button = "Middle"}},
       mods = "NONE",
       action = act{PasteFrom = "Clipboard"}},
      
      {event = {Down = { streak = 1, button = { WheelUp = 1} }},
       mods = 'NONE',
       action = act.ScrollByLine(-3)},

      {event = {Down = { streak = 1, button = { WheelDown = 1} }},
       mods = 'NONE',
       action = act.ScrollByLine(3)},

      {event = {Down = { streak = 1, button = { WheelUp = 1} }},
       mods = 'CTRL',
       action = act.IncreaseFontSize},

      {event = {Down = { streak = 1, button = { WheelDown = 1} }},
       mods = 'CTRL',
       action = act.DecreaseFontSize},
   },


   -- tab bar colors: ignored in color_schemes (bug?)
   colors = {
      tab_bar = {
         background = "#2d2d2d",
         active_tab = {bg_color = "#285577", fg_color = "#ffffff"},
         inactive_tab = {bg_color = "#5f676a", fg_color = "#ffffff"},
         inactive_tab_hover = {bg_color = "#446f92", fg_color = "#ffffff"},
         new_tab = {bg_color = "#3d3d3d", fg_color = "#ffffff"},
         new_tab_hover = {bg_color = "#446f92", fg_color = "#ffffff", intensity = "Bold"}
      }
   },
   
   color_schemes = {
      ["wezterm"] = { -- wezterm default
         foreground = "#b2b2b2",
         background = "#000000",
         cursor_border = "#52ad70",
         cursor_bg = "#52ad70",
         cursor_fg = "#ffffff",
         selection_fg = "rgba(0,0,0,0)", -- "#00000000",
         selection_bg = "rgba(127,102,153,127)", -- "#7f66997f",
         visual_bell = "#808080",
         scrollbar_thumb = "#222222",
         split = "#444444",
         ansi =    {"#000000", "#cc5555", "#55cc55", "#cdcd55", "#5455cb", "#cc55cc", "#7acaca", "#cccccc"},
         brights = {"#555555", "#ff5555", "#55ff55", "#ffff55", "#5555ff", "#ff55ff", "#55ffff", "#ffffff"},
      },
      ["xterm"] = {
         foreground = "#c0c0c0",
         background = "#2d2d2d",
         cursor_border = "red",
         cursor_bg = "red",
         cursor_fg = "#000000",
         selection_fg = "#000000",
         selection_bg = "#eeee99",
         visual_bell = "#808080",
         scrollbar_thumb = "#404040",
         ansi =    {"#000000", "#800000", "#008000", "#808000", "#000080", "#800080", "#008080", "#c0c0c0"},
         brights = {"#808080", "#ff0000", "#00ff00", "#ffff00", "#0000ff", "#ff00ff", "#00ffff", "#ffffff"},
      },
      ["kitty"] = { -- kitty default
         foreground = "#bbbbbb",
         background = "#2d2d2d",
         cursor_border = "red",
         cursor_bg = "red",
         cursor_fg = "white",
         selection_fg = "#000000",
         selection_bg = "#eeee99",
         visual_bell = "#808080",
         scrollbar_thumb = "#404040",
         ansi =    {"#000000", "#cc0403", "#19cb00", "#cecb00", "#0d73cc", "#cb1ed1", "#0dcdcd", "#dddddd"},
         brights = {"#767676", "#f2201f", "#23fd00", "#fffd00", "#1a8fff", "#fd28ff", "#14ffff", "#ffffff"},
      },
      ["olaf"] = {
         foreground = "#bbbbbb",
         background = "#323232",
         cursor_border = "red",
         cursor_bg = "red",
         cursor_fg = "white",
         selection_fg = "#000000",
         selection_bg = "#eeee99",
         visual_bell = "#808080",
         scrollbar_thumb = "#808040",
         ansi =    {"#000000", "#cd0000", "#00cd00", "#cdcd00", "#0064cd", "#cd00cd", "#00cdcd", "#cdcdcd"},
         brights = {"#323232", "#ff0000", "#00ff00", "#ffff00", "#007cff", "#ff00ff", "#00ffff", "#ffffff"},
      },
   },
}

return config
