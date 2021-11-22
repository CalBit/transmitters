-- Variables
local channels = {}

-- Nodes
minetest.register_node("transmitters:sender", {
  description = "Sender",
  tiles = {
    "default_steel_block.png^transmitters_sender.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png"
  },
  groups = {cracky = 3},
  after_place_node = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec",
      "formspec_version[4]" ..
      "size[6,4]" ..
      "field[1,1;4,0.5;channel;Channel;]" ..
      "button[1,2.5;2,0.5;submit;Submit]"
    )
  end,
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec",
      "formspec_version[4]" ..
      "size[6,4]" ..
      "field[1,1;4,0.5;channel;Channel;" .. fields.channel .. "]" ..
      "button[1,2.5;2,0.5;submit;Submit]"
    )

    minetest.chat_send_player(player:get_player_name(), "Transmitters: Channel has been set.")
  end,
  mesecons = {effector = {
    rules = mesecon.rules.default,
    action_on = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta.get_string("channel")] = true
    end,
    action_off = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta.get_string("channel")] = false
    end
  }}
})

minetest.register_node("transmitters:receiver_off", {
  description = "Receiver",
  tiles = {
    "default_steel_block.png^transmitters_receiver.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png"
  },
  groups = {cracky = 3},
  mesecons = {receptor = {
    state = mesecon.state.off,
    rules = mesecon.rules.default
  }}
})

minetest.register_node("transmitters:receiver_on", {
  tiles = {
    "default_steel_block.png^transmitters_receiver.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png"
  },
  mesecons = {receptor = {
    state = mesecon.state.on,
    rules = mesecon.rules.default
  }}
})
