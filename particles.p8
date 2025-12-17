function particle_spawn_foam(x, y, dx, dy)
    local foam = {lifetime = 0, size = 2,}
    add_tf(foam, x, y, dx, dy)
    add(foam_particles, foam)
end

function particle_spawn_explosion(x, y, size, dx, color)
    local explosion = {x = x, y = y, dx=dx or -level_speed, lifetime = 0, maxsize = size, size = 0, one_minus_size = size, color = color or 6}
    add(explosion_particles, explosion)
end

function particle_spawn_torpedo(x, y, dy)
    local torpedo = {lifetime = 0}
    add_tf(torpedo, x, y, -1, dy, 0.04)
    add(torpedo_particles, torpedo)
end

function explode_big(x, y)
    particle_spawn_explosion(x, y, 17, 0, 8)
    for i=1,24 do
        particle_spawn_foam(x, y, 1-rnd(2), 1-rnd(2))
    end
end

function explode_small(x, y)
    particle_spawn_explosion(x+6, y, 12)
    for i=1,9 do
        particle_spawn_foam(x+6, y, 0.5-rnd(1)-2*level_speed, 0.5-rnd(1))
    end
    sfx(2)
end



function particles_update()
    for i, foam in ipairs(foam_particles) do
        foam.lifetime += 1
        foam.size = 2 * (1 - foam.lifetime/40)
        tf_update(foam)
        if foam.lifetime > 40 then
            deli(foam_particles, i)
        end
    end
    for i, explo in ipairs(explosion_particles) do
        explo.lifetime += 1
        explo.x += explo.dx
        explo.size = explo.maxsize * (explo.lifetime/16)
        explo.one_minus_size = 0.6 * explo.maxsize * (1-explo.lifetime/16)
        if explo.lifetime >= 16 then
            deli(explosion_particles, i)
        end
    end
    for i, particle in ipairs(back_particles) do
        if (i > 13) then 
            particle[1] -= level_speed * 0.8
        elseif (i > 5) then
            particle[1] -= level_speed * 0.6
        else
            particle[1] -= level_speed * 0.4
        end
        if particle[1] < -1 then
            particle[1] = 128
            particle[2] = rnd(127)
        end
    end
    for i, torpedo in ipairs(torpedo_particles) do
        torpedo.lifetime += 1
        tf_update(torpedo)
        if torpedo.lifetime > 25 then
            explode_small(torpedo.x, torpedo.y)
            deli(torpedo_particles, i)
        end
    end
end



function particles_draw()
    for explo in all(explosion_particles) do
        if explo.lifetime >= 12 then
            fillp(0b1011011101110101.1)
        end
        circ(explo.x, explo.y, explo.size, explo.color)
        circfill(explo.x, explo.y, explo.one_minus_size)
        fillp()
    end 
    for torpedo in all(torpedo_particles) do
        spr(4, torpedo.x-8, torpedo.y-4, 2, 1)
    end
    for foam in all(foam_particles) do
        circfill(foam.x, foam.y, foam.size, 6)
    end 
end

