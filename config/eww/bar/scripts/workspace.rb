# frozen_string_literal: true

require 'json'

workspaces = JSON.parse(`i3-msg -t get_workspaces`)

buttons = [1, 2, 3, 4, 5, 6].map do |i|
  w = workspaces.find { |data| data['name'] == i.to_s }

  occupied = w ? 'workspace__button--occupied' : nil
  focused = w && w['focused'] ? 'workspace__button--focused' : nil

  "(button
      :onclick \"i3-msg -- workspace name #{i}\"
      :class \"workspace__button #{occupied} #{focused}\"
      \"#{focused ? '' : ''}\")"
end

puts "(box :class \"workspace\" :orientation \"h\" :spacing 5 :space-evenly \"false\" #{buttons.join(' ')})"
