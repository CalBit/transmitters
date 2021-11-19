-- Nodes
minetest.register_node("transmitters:sender", {
  description = "Sender",
  tiles = {},
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
  tiles = {},
  mesecons = {receptor = {
    state = mesecon.state.off,
    rules = mesecon.rules.default
  }}
})

minetest.register_node("transmitters:receiver_on", {
  tiles = {},
  mesecons = {receptor = {
    state = mesecon.state.on,
    rules = mesecon.rules.default
  }}
})
