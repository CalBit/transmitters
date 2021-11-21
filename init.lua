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
  mesecons = {effector = {
    rules = mesecon.rules.default,
    action_on = function ()
    end,
    action_off = function ()
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
