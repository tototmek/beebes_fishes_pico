
function pillar_spawn(gap_y, gap_size)
    local lo_y = gap_y + 0.5 * gap_size
    local hi_y = gap_y - 0.5 * gap_size

    local pillar = {
        --placement--
        high_y = hi_y, low_y = lo_y,
        x = 132,
    }
    add(pillars, pillar)
end

function pillar_draw(pillar)
    spr(32, pillar.x-4, pillar.low_y)
    for i=1,(level_height-pillar.low_y)/8 do
        spr(48, pillar.x-4, pillar.low_y+i*8)
    end
    spr(32, pillar.x-4, pillar.high_y - 8, 1, 1, false, true)
    for i=1,pillar.high_y/8 do
        spr(48, pillar.x-4, pillar.high_y - (i+1)*8)
    end
end

function pillar_collide(x, y, w_half, h_half)
    for pillar in all(pillars) do
        if x > pillar.x - 8 - w_half and x < pillar.x + 8 + w_half then
            if y > pillar.low_y - h_half or y < pillar.high_y + h_half then
                return true
            end
        end
    end
    return false
end

function pillars_update() 
    local remove_indices = {}
    for i, pillar in pairs(pillars) do
        pillar.x -= level_speed
        if pillar.x < -4 then
            add(remove_indices, i)
        end
    end
    for i in all(remove_indices) do
        deli(pillars, i)
    end
end