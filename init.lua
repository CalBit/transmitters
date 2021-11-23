-- Get mod storage
local storage = minetest.get_mod_storage()

-- Variables
local channels = minetest.parse_json(storage:get_string("channels")) or {}

-- Functions
function save_channels()
  storage:set_string("channels", minetest.write_json(channels))
end

function gen_formspec(default)
  if default == nil then default = "" end

  local formspec = {
    "formspec_version[4]",
    "size[6,4]",
    "field[1,1;4,0.5;channel;Channel;" .. default .. "]",
    "button[1,2.5;2,0.5;submit;Submit]"
  }
  return table.concat(formspec, "");
end

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
    meta:set_string("formspec", gen_formspec())
  end,
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), "Transmitters: Channel '" .. fields.channel .. "' has been set.")
  end,
  mesecons = {effector = {
    rules = mesecon.rules.default,
    action_on = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta:get_string("channel")] = true
      save_channels()
    end,
    action_off = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta:get_string("channel")] = false
      save_channels()
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
  after_place_node = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", gen_formspec())
  end,
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), "Transmitters: Channel '" .. fields.channel .. "' has been set.")
  end,
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
  after_place_node = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec",
      "formspec_version[4]" ..
      "size[6,4]" ..
      "field[1,1;4,0.5;channel;Channel;]" ..
      "button[1,2.5;2,0.5;submit;Submit]"
    )
  end,
  groups = {cracky = 3},
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), "Transmitters: Channel '" .. fields.channel .. "' has been set.")
  end,
  mesecons = {receptor = {
    state = mesecon.state.on,
    rules = mesecon.rules.default
  }}
})
