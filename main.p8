

function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--

    player = player_create()

    level_height = 112
    level_speed = 1/3
    cycle_counter = 0
    cycle_time = 600

    pillars = {}
    player_bullets = {}
    pillar_spawn(32 + rnd(80), 48 + rnd(16))
end



function _update60()
    --update player--
    player_update()

    --update level generator--
    cycle_counter+=1
    if cycle_counter % 273 == 0 then
        pillar_spawn(32 + rnd(80), 48 + rnd(16))
    end
    if cycle_counter > cycle_time then
        cycle_counter = 0
    end

    --update pillars--    TODO: optimize with a circular buffer
    pillars_update()
end


function _draw()
    cls(1)
    spr(1, player.x-12, player.y-7, 3, 2)
    for pillar in all(pillars) do
        pillar_draw(pillar)
    end
    for bullet in all(player_bullets) do
        spr(4, bullet.x-8, bullet.y-4, 2, 1)
    end
    rectfill(0, level_height, 128, 128, 0)
    line(0, level_height, 128, level_height, 11)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.w_half, player.y-player.h_half, player.x+player.w_half, player.y + player.h_half, 11)
    print(player)

    if game_over then
        print("GAME OVER")
    end
end
