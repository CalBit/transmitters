-- Get Minetest translation
local S = minetest.get_translator("transmitters")

-- Variables
local channels = {}

-- Functions
function gen_formspec(default)
  if default == nil then default = "" end

  local formspec = {
    "formspec_version[4]",
    "size[6,4]",
    "field[1,1;4,0.5;channel;" .. S("Channel") .. ";" .. default .. "]",
    "button[1,2.5;2,0.5;submit;" .. S("Submit") .. "]"
  }
  return table.concat(formspec, "");
end

-- Nodes
minetest.register_node("transmitters:sender", {
  description = S("Sender"),
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

    minetest.chat_send_player(player:get_player_name(), S("Transmitters: Channel '") .. fields.channel .. S("' has been set."))
  end,
  mesecons = {effector = {
    rules = mesecon.rules.default,
    action_on = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta:get_string("channel")] = true
    end,
    action_off = function (pos)
      local meta = minetest.get_meta(pos)
      channels[meta:get_string("channel")] = false
    end
  }}
})

minetest.register_node("transmitters:receiver_off", {
  description = S("Receiver"),
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
    meta:set_string("formspec", gen_formspec(meta:get_string("channel")))

    local timer = minetest.get_node_timer(pos)
    timer:start(0.1)
  end,
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), S("Transmitters: Channel '") .. fields.channel .. S("' has been set."))
  end,
  on_timer = function (pos)
    local meta = minetest.get_meta(pos)
    if meta:get_string("channel") == nil then return true end

    if channels[meta:get_string("channel")] then
      minetest.swap_node(pos, {name = "transmitters:receiver_on"})
      mesecon.receptor_on(pos, mesecon.rules.default)

      -- Initalize swapped node
      local node = minetest.registered_nodes[minetest.get_node(pos).name]
      if node.after_place_node then
        node.after_place_node(pos)
      end
      return false
    end

    -- Restart timer
    return true
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
    meta:set_string("formspec", gen_formspec(meta:get_string("channel")))

    local timer = minetest.get_node_timer(pos)
    timer:start(0.1)
  end,
  groups = {cracky = 3},
  drop = "transmitters:receiver_off",
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), S("Transmitters: Channel '") .. fields.channel .. S("' has been set."))
  end,
  on_timer = function (pos)
    local meta = minetest.get_meta(pos)
    if meta:get_string("channel") == nil then return true end

    if not channels[meta:get_string("channel")] then
      minetest.swap_node(pos, {name = "transmitters:receiver_off"})
      mesecon.receptor_off(pos, mesecon.rules.default)

      -- Initalize swapped node
      local node = minetest.registered_nodes[minetest.get_node(pos).name]
      if node.after_place_node then
        node.after_place_node(pos)
      end
      return false
    end

    -- Restart timer
    return true
  end,
  mesecons = {receptor = {
    state = mesecon.state.on,
    rules = mesecon.rules.default
  }}
})
