-- Get Minetest translation
local S = minetest.get_translator("transmitters")

-- Variables
local storage = minetest.get_mod_storage()
if storage:get_string("channels") == "" then
  storage:set_string("channels", minetest.write_json({}))
end
local channels = minetest.parse_json(storage:get_string("channels")) or {}

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

function save_channels()
  storage:set_string("channels", minetest.write_json(channels))
end

function set_channel(chan, val)
  if channels[chan] == nil then channels[chan] = 0 end
  channels[chan] = channels[chan] + val
  if channels[chan] < 0 then channels[chan] = 0 end
  save_channels()
end

-- Nodes
minetest.register_node("transmitters:sender", {
  description = S("Sender"),
  tiles = {
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png^transmitters_sender.png",
    "default_steel_block.png^transmitters_sender.png",
    "default_steel_block.png^transmitters_sender.png",
    "default_steel_block.png^transmitters_sender.png"
  },
  groups = {cracky = 3},
  after_place_node = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", gen_formspec())
    meta:set_int("enabled", 0)
  end,
  on_destruct = function (pos)
    local meta = minetest.get_meta(pos)

    -- Turn off channel if necessary
    if meta:get_int("enabled") == 1 then
      set_channel(meta:get_string("channel"), -1)
    end
  end,
  on_receive_fields = function (pos, formname, fields, player)
    if fields.quit then return end

    local meta = minetest.get_meta(pos)

    -- Turn off channel if necessary
    if meta:get_int("enabled") == 1 then
      set_channel(meta:get_string("channel"), -1)
    end

    -- Save channel
    meta:set_string("channel", fields.channel)

    -- Turn on channel if necessary
    if meta:get_int("enabled") == 1 then
      set_channel(meta:get_string("channel"), 1)
    end

    -- Reset default value for formspec
    meta:set_string("formspec", gen_formspec(fields.channel))

    minetest.chat_send_player(player:get_player_name(), S("Transmitters: Channel '") .. fields.channel .. S("' has been set."))
  end,
  mesecons = {effector = {
    rules = mesecon.rules.default,
    action_on = function (pos)
      local meta = minetest.get_meta(pos)
      set_channel(meta:get_string("channel"), 1)
      meta:set_int("enabled", 1)
    end,
    action_off = function (pos)
      local meta = minetest.get_meta(pos)
      set_channel(meta:get_string("channel"), -1)
      meta:set_int("enabled", 0)
    end
  }}
})

minetest.register_node("transmitters:receiver_off", {
  description = S("Receiver"),
  tiles = {
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png^transmitters_receiver_off.png",
    "default_steel_block.png^transmitters_receiver_off.png",
    "default_steel_block.png^transmitters_receiver_off.png",
    "default_steel_block.png^transmitters_receiver_off.png"
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

    -- Make sure not to get nil error
    if channels[meta:get_string("channel")] == nil then channels[meta:get_string("channel")] = 0 end
    if channels[meta:get_string("channel")] > 0 then
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
    "default_steel_block.png",
    "default_steel_block.png",
    "default_steel_block.png^transmitters_receiver_on.png",
    "default_steel_block.png^transmitters_receiver_on.png",
    "default_steel_block.png^transmitters_receiver_on.png",
    "default_steel_block.png^transmitters_receiver_on.png"
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

    -- Make sure not to get nil error
    if channels[meta:get_string("channel")] == nil then channels[meta:get_string("channel")] = 0 end
    if channels[meta:get_string("channel")] < 1 then
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

-- Register crafts
minetest.register_craft({
  output = "transmitters:sender",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "group:mesecon_conductor_craftable"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
  }
})

minetest.register_craft({
  output = "transmitters:sender",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "mesecons_microcontroller:microcontroller0000", "group:mesecon_conductor_craftable"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
  }
})

minetest.register_craft({
  output = "transmitters:receiver_off",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"group:mesecon_conductor_craftable", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
  }
})

minetest.register_craft({
  output = "transmitters:receiver_off",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"group:mesecon_conductor_craftable", "mesecons_microcontroller:microcontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
  }
})

-- Register chat commands
minetest.register_chatcommand("resetchannels", {
  description = "Resets all channels to nil. (Use if channels seem to be acting up)",
  privs = {
    server = true
  },
  func = function ()
    channels = {}
    save_channels()
  end
})
