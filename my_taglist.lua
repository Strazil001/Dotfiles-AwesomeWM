local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
------------------------------------

local get_taglist = function(s)
	-- Taglist buttons
	local taglist_buttons = gears.table.join(
		awful.button({}, 1,
			function(t) t:view_only() end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then client.focus:move_to_tag(t) end
		end), awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then client.focus:toggle_tag(t) end
		end), awful.button({}, 4, function(t)
			awful.tag.viewnext(t.screen)
		end), awful.button({}, 5, function(t)
			awful.tag.viewprev(t.screen)
		end))

	----------------------------------------------------------------------

	local unfocus_icon = " "
	local unfocus_color = "#585b70"

	local empty_icon = " "
	local empty_color = "#585b70"

	local focus_icon = " "
	local focus_color = "#b4befe"

	----------------------------------------------------------------------

	-- Function to update the tags
	local update_tags = function(self, c3)
		local tagicon = self:get_children_by_id('icon_role')[1]
		if c3.selected then
			tagicon.text = focus_icon
			self.fg = focus_color
		elseif #c3:clients() == 0 then
			tagicon.text = empty_icon
			self.fg = empty_color
		else
			tagicon.text = unfocus_icon
			self.fg = unfocus_color
		end
	end

	----------------------------------------------------------------------

	local icon_taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = { spacing = 0, layout = wibox.layout.fixed.horizontal },
		widget_template = {
			{
				{ id = 'icon_role', font = "JetBrainsMono Nerd Font 12", widget = wibox.widget.textbox },
				id = 'margin_role',
				top = dpi(0),
				bottom = dpi(0),
				left = dpi(2),
				right = dpi(2),
				widget = wibox.container.margin
			},
			id = 'background_role',
			widget = wibox.container.background,
			create_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end,

			update_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end
		},
		buttons = taglist_buttons
	}
	return icon_taglist
end

return get_taglist
