--[[-- info
    Provides the ability to setup a player when first joined.
]]

-- dependencies
local Event = require 'utils.event'
local Debug = require 'map_gen.Diggy.Debug'
local Game = require 'utils.game'

-- this
local SetupPlayer = {}

global.SetupPlayer = {
    first_player_spawned = false,
}

--[[--
    Registers all event handlers.
]]
function SetupPlayer.register(config)
    Event.add(defines.events.on_player_created, function (event)
        local player = Game.get_player_by_index(event.player_index)
        local player_insert = player.insert
        local position = {0, 0}
        local surface = player.surface

        for _, item in pairs(config.starting_items) do
            player_insert(item)
        end

        if (global.SetupPlayer.first_player_spawned) then
            position = surface.find_non_colliding_position('player', position, 3, 0.1)
        else
            global.SetupPlayer.first_player_spawned = true
        end

        player.force.set_spawn_position(position, surface)
        player.teleport(position)

        Debug.cheat(function()
            local cheats = config.cheats
            player.force.manual_mining_speed_modifier = cheats.manual_mining_speed_modifier
            player.force.character_inventory_slots_bonus = cheats.character_inventory_slots_bonus
            player.force.character_running_speed_modifier = cheats.character_running_speed_modifier

            for _, item in pairs(cheats.starting_items) do
                player_insert(item)
            end
        end)
    end)
end

return SetupPlayer
