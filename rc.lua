--# vim:fileencoding=utf-8:foldmethod=marker
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local theme = require("theme")

-- Error handling {{{
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err) })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init("/home/sv/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = "nvim" or os.getenv("EDITOR")
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile.left,
	--awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	--    awful.layout.suit.tile.bottom,
	--    awful.layout.suit.tile.top,
	--    awful.layout.suit.fair,
	--    awful.layout.suit.fair.horizontal,
	--    awful.layout.suit.spiral,
	--    awful.layout.suit.spiral.dwindle,
	--    awful.layout.suit.magnifier,
	--    awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
	{ "open terminal", terminal }
}
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
	menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal(
				"request::activate",
				"tasklist",
				{ raise = true }
			)
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end))

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local widget_fg = "#a6adc8"
local widget_bg = "#313244"

---------------------------------
-- Cutom Widgets
---------------------------------

-- Storage widget
local container_storage_widget = wibox.container

local storage_widget_root = wibox.widget {
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_storage_root = function(st_root)
	storage_widget_root.text = " " .. st_root
end

local storage_widget_home = wibox.widget {
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_storage_home = function(st_home)
	storage_widget_home.text = " " .. st_home
end


local storage_root = awful.widget.watch('bash -c "df -h | awk \'NR==4 {print $4}\'"', 60, function(self, stdout)
	local st_root = stdout
	update_storage_root(st_root)
end)

local storage_home = awful.widget.watch('/home/sv/scripts/disk-usage.sh', 60, function(self, stdout)
	st_home = stdout
	update_storage_home(st_home)
end)

container_storage_widget = {
	{
		{
			{
				{

					{
						widget = storage_widget_root,
					},
					{
						widget = storage_widget_home,
					},
					layout = wibox.layout.flex.horizontal
				},
				left   = 5,
				right  = 5,
				top    = 2,
				bottom = 2,
				widget = wibox.container.margin
			},
			shape        = gears.shape.rounded_bar,
			fg           = "#b4befe",
			bg           = widget_bg,
			forced_width = 140,
			widget       = wibox.container.background
		},

		left   = 10,
		right  = 5,
		top    = 7,
		bottom = 7,
		widget = wibox.container.margin
	},
	spacing = 5,
	layout  = wibox.layout.fixed.horizontal,
}

-- Memory progressbar widget
--local container_mem_widget = wibox.container
--local memory_progressbar = wibox.widget {
--	max_value        = 16000,
--	value            = 0.5, -- very hugly -- minimum value to handle to make it look good
--	margins          = 2,
--	forced_width     = 80,
--	shape            = gears.shape.rounded_bar,
--	border_width     = 0.5,
--	border_color     = "#b4befe",
--	color            = "#b4befe",
--	background_color = widget_bg,
--	widget           = wibox.widget.progressbar,
--}
--
--local update_memory_widget = function(mem)
--	memory_progressbar.value = mem
--end
--
--awful.widget.watch('bash -c "free -m | awk \'/Mem/{print $3}\'"', 2, function(self, stdout)
--	local mem = tonumber(stdout)
--	update_memory_widget(mem)
--end)
--
--container_mem_widget = {
--	{
--		{
--			{
--				{
--					{
--						text   = "  ",
--						font   = "JetBrainsMono Nerd Font 9",
--						widget = wibox.widget.textbox,
--					},
--					{
--						widget = memory_progressbar,
--					},
--					layout = wibox.layout.fixed.horizontal
--				},
--				left   = 12,
--				right  = 12,
--				top    = 2,
--				bottom = 2,
--				widget = wibox.container.margin
--			},
--			shape  = gears.shape.rounded_bar,
--			fg     = "#b4befe",
--			bg     = widget_bg,
--			widget = wibox.container.background
--		},
--		left   = 5,
--		right  = 5,
--		top    = 7,
--		bottom = 7,
--		widget = wibox.container.margin
--	},
--	spacing = 0,
--	layout  = wibox.layout.fixed.horizontal,
--}

-- Cpu progressbar widget
--local container_cpu_widget = wibox.container
--
--local cpu_progressbar = wibox.widget {
--	max_value        = 100,
--	value            = 0.5, -- very hugly -- minimum value to handle to make it look good
--	margins          = 2,
--	forced_width     = 80,
--	shape            = gears.shape.rounded_bar,
--	border_width     = 0.5,
--	border_color     = "#fab387",
--	color            = "#fab387",
--	background_color = widget_bg,
--	widget           = wibox.widget.progressbar,
--}
--
--local update_cpu_widget = function(cpu)
--	cpu_progressbar.value = cpu
--end
--
--awful.widget.watch('/home/sv/scripts/get-cpu.sh', 2, function(self, stdout)
--	local cpu = tonumber(stdout)
--	update_cpu_widget(cpu)
--end)
--
--container_cpu_widget = {
--	{
--		{
--			{
--				{
--					{
--						text   = "  ",
--						font   = "JetBrainsMono Nerd Font 9",
--						widget = wibox.widget.textbox,
--					},
--					{
--						widget = cpu_progressbar,
--					},
--					layout = wibox.layout.fixed.horizontal
--				},
--				left   = 12,
--				right  = 12,
--				top    = 2,
--				bottom = 2,
--				widget = wibox.container.margin
--			},
--			shape  = gears.shape.rounded_bar,
--			fg     = "#fab387",
--			bg     = widget_bg,
--			widget = wibox.container.background
--		},
--		left   = 5,
--		right  = 5,
--		top    = 7,
--		bottom = 7,
--		widget = wibox.container.margin
--	},
--	spacing = 0,
--	layout  = wibox.layout.fixed.horizontal,
--}

-- Brightness widget
local container_brightness_widget = wibox.container

local brightness_widget = wibox.widget {
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_brightness_widget = function(brightness)
	brightness_widget.text = "  " .. brightness
end

local br, br_signal = awful.widget.watch('/home/sv/scripts/brightness-bar.sh', 60, function(self, stdout)
	local brightness = stdout
	update_brightness_widget(brightness)
end)


container_brightness_widget = {
	{
		{
			{
				{
					widget = brightness_widget,
				},
				left   = 12,
				right  = 12,
				top    = 0,
				bottom = 0,
				widget = wibox.container.margin
			},
			shape  = gears.shape.rounded_bar,
			fg     = "#f9e2af",
			bg     = widget_bg,
			widget = wibox.container.background
		},

		left   = 5,
		right  = 5,
		top    = 7,
		bottom = 7,
		widget = wibox.container.margin
	},
	spacing = 5,
	layout  = wibox.layout.fixed.horizontal,
}

-- Volume widget
local container_vol_widget = wibox.container

local vol_widget = wibox.widget {
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_vol_widget = function(vol)
	vol_widget.text = "  " .. vol
end

local vo, vo_signal = awful.widget.watch('/home/sv/scripts/volume-bar.sh', 60, function(self, stdout)
	local vol = stdout
	update_vol_widget(vol)
end)

container_vol_widget = {
	{
		{
			{
				{
					widget = vol_widget,
				},
				left   = 12,
				right  = 12,
				top    = 0,
				bottom = 0,
				widget = wibox.container.margin
			},
			shape  = gears.shape.rounded_bar,
			fg     = "#f38ba8",
			bg     = widget_bg,
			widget = wibox.container.background
		},

		left   = 5,
		right  = 5,
		top    = 7,
		bottom = 7,
		widget = wibox.container.margin
	},
	spacing = 5,
	layout  = wibox.layout.fixed.horizontal,
}

-- Temp widget
--local container_temp_widget = wibox.container
--
--local temp_widget = wibox.widget {
--	align  = 'center',
--	valign = 'center',
--	widget = wibox.widget.textbox
--}
--
--local update_temp_widget = function(temp)
--	temp_widget.text = "  " .. temp
--end
--
--awful.widget.watch('bash -c "sensors | grep edge | awk \'{print $2}\'"', 2, function(self, stdout)
--	local temp = stdout
--	update_temp_widget(temp)
--end)
--
--container_temp_widget = {
--	{
--		{
--			{
--				{
--					widget = temp_widget,
--				},
--				left   = 12,
--				right  = 12,
--				top    = 2,
--				bottom = 2,
--				widget = wibox.container.margin
--			},
--			shape  = gears.shape.rounded_bar,
--			fg     = "#a6e3a1",
--			bg     = widget_bg,
--			widget = wibox.container.background
--		},
--
--		left   = 20,
--		right  = 5,
--		top    = 7,
--		bottom = 7,
--		widget = wibox.container.margin
--	},
--	spacing = 5,
--	layout  = wibox.layout.fixed.horizontal,
--}

-- Batery widget
local container_battery_widget = wibox.container

local battery_widget = wibox.widget {
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_battery_widget = function(bat)
	battery_widget.text = "  " .. bat .. "%"
end

awful.widget.watch('bash -c "cat /sys/class/power_supply/BAT1/capacity"', 60, function(self, stdout)
	local bat = tonumber(stdout)
	update_battery_widget(bat)
end)

container_battery_widget = {
	{
		{
			{
				{
					widget = battery_widget,
				},
				left   = 12,
				right  = 12,
				top    = 0,
				bottom = 0,
				widget = wibox.container.margin
			},
			shape  = gears.shape.rounded_bar,
			fg     = "#a6e3a1",
			bg     = widget_bg,
			widget = wibox.container.background
		},

		left   = 5,
		right  = 5,
		top    = 7,
		bottom = 7,
		widget = wibox.container.margin
	},
	spacing = 5,
	layout  = wibox.layout.fixed.horizontal,
}

-- Clock widget
container_arch_widget = {
	{
		{
			text = "  ",
			font = "JetBrainsMono Nerd Font 15",
			widget = wibox.widget.textbox,
		},
		left   = 0,
		right  = 5,
		top    = 2,
		bottom = 2,
		widget = wibox.container.margin
	},
	fg     = "#fab387",
	widget = wibox.container.background
}

-- Clock widget
container_clock_widget = {
	{
		{
			{
				{
					widget = mytextclock,
				},
				left   = 6,
				right  = 6,
				top    = 0,
				bottom = 0,
				widget = wibox.container.margin
			},
			shape  = gears.shape.rounded_bar,
			fg     = "#b4befe",
			bg     = widget_bg,
			widget = wibox.container.background
		},

		left   = 5,
		right  = 5,
		top    = 7,
		bottom = 7,
		widget = wibox.container.margin
	},
	spacing = 5,
	layout  = wibox.layout.fixed.horizontal,
}

local archimage = wibox.widget {
	image  = theme.layout_archlogo,
	resize = false,
	widget = wibox.widget.imagebox
}

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ " ", " ", " ", " ", " ", " ", " ", " ", " " }, s,
		awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function() awful.layout.inc(1) end),
		awful.button({}, 3, function() awful.layout.inc(-1) end),
		awful.button({}, 4, function() awful.layout.inc(1) end),
		awful.button({}, 5, function() awful.layout.inc(-1) end)))

	local layoutbox = wibox.widget({
		s.mylayoutbox,
		top    = 5,
		bottom = 6,
		left   = 5,
		right  = 10,
		widget = wibox.container.margin,
	})
	-- Create a taglist widget
	--s.mytaglist = awful.widget.taglist {
	--	screen  = s,
	--	filter  = awful.widget.taglist.filter.all,
	--	buttons = taglist_buttons
	--}
	s.mytaglist = require("my_taglist")(s)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen          = s,
		filter          = awful.widget.tasklist.filter.currenttags,
		style           = {
			shape = gears.shape.rounded_bar,
		},
		layout          = {
			spacing = 10,
			layout  = wibox.layout.fixed.horizontal
		},
		-- Notice that there is *NO* wibox.wibox prefix, it is a template,
		-- not a widget instance.
		widget_template = {
			{

				{
					{
						{
							id     = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					left   = 10,
					right  = 10,
					top    = 0,
					bottom = 0,
					widget = wibox.container.margin
				},
				fg     = widget_fg,
				bg     = widget_bg,
				shape  = gears.shape.rounded_bar,
				widget = wibox.container.background,
			},
			left   = 0,
			right  = 0,
			top    = 7,
			bottom = 7,
			widget = wibox.container.margin
		},
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", border_width = 0, border_color = "#00000000", height = 30, input_passthrough = true, screen = s })


	-- Add widgets to the wibox
	s.mywibox:setup {
		{
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				container_arch_widget,
				layout = wibox.layout.fixed.horizontal,
				--mylauncher,
				s.mytaglist,
				s.mypromptbox,
			},
			{ -- Middle widgets
				layout = wibox.layout.fixed.horizontal,
				s.mytasklist,
			},
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				--container_temp_widget,
				container_storage_widget,
				--container_cpu_widget,
				--container_mem_widget,
				container_brightness_widget,
				container_vol_widget,
				container_battery_widget,
				container_clock_widget,
				layoutbox,
			}
		},
		top = 0, -- don't forget to increase wibar height
		color = "#80aa80",
		widget = wibox.container.margin,
	}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function() mymainmenu:toggle() end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
--	awful.key({ modkey, }, "s", hotkeys_popup.show_help,
--		{ description = "show help", group = "awesome" }),
	awful.key({ modkey, }, "Left", awful.tag.viewprev,
		{ description = "view previous", group = "tag" }),
	awful.key({ modkey, }, "Right", awful.tag.viewnext,
		{ description = "view next", group = "tag" }),
	awful.key({ modkey, }, "Escape", awful.tag.history.restore,
		{ description = "go back", group = "tag" }),

	awful.key({ modkey, }, "j",
		function()
			awful.client.focus.byidx(1)
		end,
		{ description = "focus next by index", group = "client" }
	),
	awful.key({ modkey, }, "k",
		function()
			awful.client.focus.byidx(-1)
		end,
		{ description = "focus previous by index", group = "client" }
	),
	awful.key({ modkey, }, "w", function() mymainmenu:show() end,
		{ description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
		{ description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
		{ description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
		{ description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
		{ description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
		{ description = "jump to urgent client", group = "client" }),
	awful.key({ modkey, }, "Tab",
		function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{ description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
		{ description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, }, "b", function() awful.spawn("qutebrowser") end,
		{ description = "open qutebrowser", group = "launcher" }),
	awful.key({ modkey }, "s",
		function()
			awful.spawn("scrot -q 100 -d 1 /home/sv/pictures/screenshots/%Y-%m-%d_$wx$h.png")
			naughty.notify {
				title = " ",
				fg = "#8293ce",
				text = "      Screenshot taken",
				font = "Roboto Mono Nerd Font 12",
				margin = 15,
				opacity = 0.7,
				--border_width = 3,
				--border_color = "#9888c6",
				--replaces_id = 1,
				--border_width = 3,
				--border_color = "#89b4fa",
				width = 300,
				height = 100,
				shape = function(cr, width, heigt)
					gears.shape.rounded_rect(cr, width, heigt, 15)
				end
			}
		end,
		{ description = "Take screenshot fullscreen", group = "screen" }),
	awful.key({ modkey, "Shift" }, "s",
		function() awful.spawn("scrot -s -q 100 /home/sv/pictures/screenshots/%Y-%m-%d_$wx$h.png") end,
		{ description = "Take screenshot selection", group = "screen" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart,
		{ description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit,
		{ description = "quit awesome", group = "awesome" }),

	awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
		{ description = "increase master width factor", group = "layout" }),
	awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
		{ description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
		{ description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
		{ description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
		{ description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
		{ description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey, }, "m", function() awful.layout.inc(1) end,
		{ description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "m", function() awful.layout.inc(-1) end,
		{ description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n",
		function()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:emit_signal(
					"request::activate", "key.unminimize", { raise = true }
				)
			end
		end,
		{ description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey, "Shift" }, "r", function() awful.screen.focused().mypromptbox:run() end,
		{ description = "run prompt", group = "launcher" }),

	awful.key({ modkey }, "x",
		function()
			awful.prompt.run {
				prompt       = "Run Lua code: ",
				textbox      = awful.screen.focused().mypromptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			}
		end,
		{ description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	--awful.key({ modkey }, "p", function() menubar.show() end,
	--{ description = "show the menubar", group = "launcher" })

	-- Dmenu
	--awful.key({ modkey }, "p", function() awful.spawn("dmenu_run -i -c -l 20") end,
	--{ description = "show Dmenu", group = "launcher" }))

	-- Rofi
	awful.key({ modkey }, "space", function() awful.spawn("rofi -show run") end,
		{ description = "show rofi", group = "launcher" }),

	-- Rofi Calc
	awful.key({ modkey, "Shift" }, "c", function() awful.spawn("rofi -show calc -modi calc -no-show-match -no-sort") end,
		{ description = "show rofi", group = "launcher" }),



	-- Brightness up
	awful.key({}, "XF86MonBrightnessUp",
		function()
			--local brightness = [[/home/sv/scripts/brightness-bar.sh]]
			awful.spawn("/home/sv/scripts/brightness-up.sh")
			br_signal:emit_signal("timeout")
			--awful.spawn.easy_async(brightness, function(stdout)
			--	naughty.notify {
			--		--title = "Brightness",
			--		text = "  " .. stdout,
			--		font = "Roboto Mono Nerd Font 12",
			--		replaces_id = 1,
			--		--border_width = 3,
			--		--border_color = "#89b4fa",
			--		width = 170,
			--		height = 25,
			--		shape = function(cr, width, heigt)
			--			gears.shape.rounded_rect(cr, width, heigt, 5)
			--		end
			--	}
			--end)
		end,
		{ description = "Brightness up", group = "system" }),

	-- Brightness down
	awful.key({}, "XF86MonBrightnessDown",
		function()
			--local brightness = [[/home/sv/scripts/brightness-bar.sh]]
			awful.spawn("/home/sv/scripts/brightness-down.sh")
			br_signal:emit_signal("timeout")
			--awful.spawn.easy_async(brightness, function(stdout)
			--	naughty.notify {
			--		--title = "Brightness",
			--		text = "  " .. stdout,
			--		font = "Roboto Mono Nerd Font 12",
			--		replaces_id = 1,
			--		--border_width = 3,
			--		--border_color = "#89b4fa",
			--		width = 170,
			--		height = 25,
			--		shape = function(cr, width, heigt)
			--			gears.shape.rounded_rect(cr, width, heigt, 5)
			--		end
			--	}
			--end)
		end,
		{ description = "Brightness down", group = "system" }),

	-- Volume up
	awful.key({}, "XF86AudioRaiseVolume",
		function()
			--local volume = [[/home/sv/scripts/volume-bar.sh]]
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
			vo_signal:emit_signal("timeout")
			--awful.spawn.easy_async(volume, function(stdout)
			--	naughty.notify {
			--		--title = "Brightness",
			--		text = "   " .. stdout,
			--		font = "Roboto Mono Nerd Font 12",
			--		replaces_id = 1,
			--		--border_width = 3,
			--		--border_color = "#89b4fa",
			--		width = 170,
			--		height = 25,
			--		shape = function(cr, width, heigt)
			--			gears.shape.rounded_rect(cr, width, heigt, 5)
			--		end
			--	}
			--end)
		end,
		{ description = "Brightness up", group = "system" }),

	-- Volume down
	awful.key({}, "XF86AudioLowerVolume",
		function()
			--local volume = [[/home/sv/scripts/volume-bar.sh]]
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
			vo_signal:emit_signal("timeout")
			--awful.spawn.easy_async(volume, function(stdout)
			--	naughty.notify {
			--		--title = "Brightness",
			--		text = "   " .. stdout,
			--		font = "Roboto Mono Nerd Font 12",
			--		replaces_id = 1,
			--		--border_width = 3,
			--		--border_color = "#89b4fa",
			--		width = 170,
			--		height = 25,
			--		shape = function(cr, width, heigt)
			--			gears.shape.rounded_rect(cr, width, heigt, 5)
			--		end
			--	}
			--end)
		end,
		{ description = "Brightness down", group = "system" })

)

clientkeys = gears.table.join(
	awful.key({ modkey, }, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey }, "c", function(c) c:kill() end,
		{ description = "close", group = "client" }),
	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }),
	awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
		{ description = "move to master", group = "client" }),
	awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
		{ description = "move to screen", group = "client" }),
	awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
		{ description = "toggle keep on top", group = "client" }),
	awful.key({ modkey, }, "n",
		function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end,
		{ description = "minimize", group = "client" })
--awful.key({ modkey, }, "m",
--	function(c)
--		c.maximized = not c.maximized
--		c:raise()
--	end,
--	{ description = "(un)maximize", group = "client" }),
--awful.key({ modkey, }, "m",
--	{ description = "Toggle modes", group = "client" }),
--awful.key({ modkey, "Control" }, "m",
--	function(c)
--		c.maximized_vertical = not c.maximized_vertical
--		c:raise()
--	end,
--	{ description = "(un)maximize vertically", group = "client" }),
--awful.key({ modkey, "Shift" }, "m",
--	function(c)
--		c.maximized_horizontal = not c.maximized_horizontal
--		c:raise()
--	end,
--	{ description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{ description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{ description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{ description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			{ description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = {},
		properties = { border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen
		}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
			"DTA", -- Firefox addon DownThemAll.
			"copyq", -- Includes session name in class.
			"pinentry",
		},
		class = {
			"Arandr",
			"Blueman-manager",
			"Gpick",
			"Kruler",
			"MessageWin", -- kalarm.
			"Sxiv",
			"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
			"Wpa_gui",
			"veromix",
			"xtightvncviewer"
		},

		-- Note that the name property shown in xprop might be set slightly after creation of the client
		-- and the name shown there might not match defined rules here.
		name = {
			"Event Tester", -- xev.
		},
		role = {
			"AlarmWindow", -- Thunderbird's calendar.
			"ConfigManager", -- Thunderbird's about:config.
			"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
		}
	}, properties = { floating = true } },

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" }
	}, properties = { titlebars_enabled = false }
	},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
		and not c.size_hints.user_position
		and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal()
		},
		layout = wibox.layout.align.horizontal
	}
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
--client.connect_signal("manage", function(c) c.shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end end)
--autorun programs
autorun = true
autorunApps =
{
	"picom",
}
if autorun then
	for app = 1, #autorunApps do
		awful.util.spawn(autorunApps[app])
	end
end


-- }}}
