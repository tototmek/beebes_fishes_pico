function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--
    music(1)
    
    environment = {
        drag = 0.95,
    }

    player = player_create()
    playing = false


    level_height, level_speed = 112, 2/3
    dead_ctr = 2137
    cam_shake = 0

    press_x_text = {target_y = 92}
    add_tf(press_x_text, 33, 128)

    back_particles = {}
    for i=1,20 do
        back_particles[i] = {rnd(127), rnd(127)}
    end

    bkgr_init()
end


function init_gameplay()
    music(6)
    score = 0
    playing, game_over = true, false
    dead_ctr, beat_counter, in_beat_ctr, beat_time = 0, 0, 0, 6
    pillars, player_bullets, enemy_bullets, enemies, foam_particles, explosion_particles, torpedo_particles = {}, {}, {}, {}, {}, {}, {}
    player = player_create()
    press_x_text.target_y = 160
    anglerfish_spawn(63)
end


function _update60()
    if playing == true then -- main game loop --
    --update player--
    player_update()

    --update level generator--
    in_beat_ctr+=1
    -- if in_beat_ctr > beat_time then
    --     in_beat_ctr = 0
    --     beat_counter += 1
    --     if beat_counter % 23 == 0 then -- every 2.3 seconds
    --         -- pillar_spawn(32 + rnd(80), 24 + rnd(16))
    --         pillar_spawn(32+rnd(64), 24)
    --     elseif beat_counter % 62 == 0 then
    --         bubblefish_spawn(16+rnd(88))
    --     elseif beat_counter % 87 == 0 then
    --         medusa_spawn(16+rnd(88))
    --     elseif beat_counter % 80 == 0 then
    --         sailfin_spawn(16+rnd(88))
    --     elseif beat_counter % 133 == 0 then
    --         constellationfish_spawn(16+rnd(88))
    --     elseif beat_counter % 316 == 0 then
    --         nautilus_spawn(16+rnd(88))
    --     elseif beat_counter % 116 == 0 then
    --         rainbowgar_spawn(63)
    --     end
    -- end


    else -- end of main game loop, menu code below
    dead_ctr += 1
    if btnp(4) or btnp(5) then -- pressed play
        if (dead_ctr > 50) then
            init_gameplay()
            sfx(1)
        end
    end
    if game_over then
        player.ddy = 0.02
        player.ddx = -0.004
        tf_update(player)
        if (player.y < level_height) and rnd(1) < 0.05 then
            explode_small(player.x - 16 + rnd(32), player.y - 8 + rnd(16))
        end
    end
    end --below runs in both game loop and main menu
    for i, enemy in ipairs(enemies) do -- update enemies and destroy if needed
        enemy_update(enemy)
        if enemy.dead then
            deli(enemies, i)
        end
    end
    enemy_bullets_update()
    pillars_update()
    particles_update() -- do in any mode
    tf_spring_to(press_x_text, nil, press_x_text.target_y, 0.003)
    tf_update(press_x_text)
    bkgr_update()
    if cam_shake > 0 then
        cam_shake -= 1
    end
end

function _draw()
    pal(4, 129, 1) -- add blues to pallette
    pal(5, 140, 1)
    cls(4)
    rectfill(0, 0, 127, 16, 1)
    for i=0,127,8 do
        spr(80, i, 16, 1, 3)
    end
    camera(rnd(cam_shake), rnd(cam_shake))

    --draw background--
    bkgr_draw()


    local sine_y = -2.5*sin(t()/4)

    -- draw background particles --
    for particle in all(back_particles) do
        pset(particle[1], particle[2], 5)
    end

    for pillar in all(pillars) do
        pillar_draw(pillar)
    end
    for enemy in all(enemies) do
        enemy.draw_func(enemy)
    end

    local blink_player = player.hit_ctr%12 < 6 and player.hit_ctr > 0
    if blink_player then
        pal(12, 7, 0)
        pal(5, 7, 0)
    end
    local player_flr_x, player_flr_y = flr(player.x), flr(player.y)
    spr(1, player_flr_x-12, player_flr_y-7, 3, 2)
    if blink_player then
        pal(12, 12, 0)
        pal(5, 5, 0)
    end
    particles_draw()

    local sine_prop = flr(2*sin(time()))
    line(player_flr_x-13, player_flr_y+1-sine_prop, player_flr_x-13, player_flr_y+2+sine_prop, 6)  --propeller
    for i=1,player.shots_left do
        -- torpedo bays
        rectfill(player_flr_x-9+i*5, player_flr_y+2, player_flr_x-8+i*5, player_flr_y+3, 12)
    end

    for bullet in all(player_bullets) do
        -- circfill(bullet.x-10, bullet.y, bullet.dx, 6)
        spr(4, bullet.x-8, bullet.y-4, 2, 1)
    end
    for bullet in all(enemy_bullets) do
        spr(23, bullet.x-4, bullet.y-4)
    end

    camera()
    -- rectfill(0, gui_y, 127, gui_y+16, 1)
    -- line(0, gui_y, 128, gui_y, 7)
    local lives = ""
    for i=1,player.hp do
        lives = lives.."♥"
    end

    if playing then --draw game ui
        print(lives.."  ", 1, 2, 7)
        score_str_length = print(score,0,-100)
        print(score, 127-score_str_length, 2)

    -- print("particles "..#foam_particles, 63, level_height+3)
    else -- draw main menu
        if game_over then
            press_x_text.target_y = 92
            print("game over", 47, 31, 2)
            print("game over", 46, 30, 7)
            print("𝘴𝘤𝘰𝘳𝘦", 53, 61, 7)
            score_str_length = print("\^w\^t"..score,0,-100)
            print("\^w\^t"..score, 64-0.5*score_str_length, 50)
            pset(63,63)
        else
            --print game title
        end
    end
    print("press ❎", 48, press_x_text.y+sine_y+1, 1)
    print("press ❎", 47, press_x_text.y+sine_y, 7)

    -- print("plr:"..#pillars.." enm:"..#enemies.." pb:"..#player_bullets.." eb:"..#enemy_bullets, 38, level_height + 3)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.x_half_size, player.y-player.y_half_size, player.x+player.x_half_size, player.y + player.y_half_size, 11)

end