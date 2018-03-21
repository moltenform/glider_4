-- Glider, ported from Glider4 by Ben Fisher, https://github.com/downpoured/glider_4
-- script of cd "cdglider":

-- -- level data:
-- 1|roomname
-- 2|numberOObjects
-- 3|leftOpen
-- 4|rightOpen
-- 5|animateKind
-- 6|animateNumber
-- 7|animateDelay
-- 8|conditionCode
-- -- level objects:
-- 1|typename
-- 2|typynumber
-- 3|c1
-- 4|c2
-- 5|c3
-- 6|c4
-- 7|amount
-- 8|extra
-- 9|isOn


function intersectRoomObject curlvldata, curlvlObjects, myrect1, myrect2, myrect3, myrect4
    global curlevel, lvlObjects, propsperobj
    put item 2 of curlvldata into numobjects
    put "" into ret
    put left of cd btn "glider_spritesme" into x0
    put top of cd btn "glider_spritesme" into y0
    put right of cd btn "glider_spritesme" into x1
    put bottom of cd btn "glider_spritesme" into y1
    repeat with i = 1 to numobjects
        put (propsperobj * (i-1)) into j
        put  item (j+1) of curlvlObjects into objtypename
        if objtypename is "outlet" then
            mainloopgame_periodic i, curlvldata, curlvlObjects
        end if
        put item (j+3) of curlvlObjects into boxx0
        put item (j+4) of curlvlObjects into boxy0
        put item (j+5) of curlvlObjects into boxx1
        put item (j+6) of curlvlObjects into boxy1
        if (x0 >= boxx1 or y0 >= boxy1)  then
        -- it's way outside on the right or bottom
        else if (x1 < boxx0 or y1 < boxy0)  then
        -- it's way outside on the left or top
        else
            put "|" & i after ret
        end if
    end repeat
    return ret
end intersectRoomObject


on mainloopgame_motion curlvldata, curlvlObjects
    global lastdirpressed, curlevel, lvlData
    global dx, dy
    if dy is "" then
        put 0 into dy
    end if
    if lastdirpressed is "-1" then
        add -22 to dx
    else if lastdirpressed is "1" then
        add 22 to dx
    end if
    put "" into lastdirpressed
    set the topleft of cd btn "glider_spritesme" to (the left of cd btn "glider_spritesme" + dx), (the top of cd btn "glider_spritesme" + dy)
    set the topleft of cd btn "glider_spritesshadow" to (the left of cd btn "glider_spritesme" + dx), 320
end mainloopgame_motion

on mainloopgame_checkbounds curlvldata, curlvlObjects
    global lastdirpressed, curlevel, lvlData
    put (item 3 of curlvldata is 1) into leftopen
    put (item 4 of curlvldata is 1) into rghtopen
    if the bottom of cd btn "glider_spritesme" > 328 then
        begindeath
        set the bottom of cd btn "glider_spritesme" to 328
    else if the top of cd btn "glider_spritesme" < 30 then
        set the top of cd btn "glider_spritesme" to 30
    end if
    
    if the left of cd btn "glider_spritesme" <= 0 then
        if leftopen then
            beginloadlevel curlevel - 1
            set the left of cd btn "glider_spritesme" to 450
        else
            set the left of cd btn "glider_spritesme" to 0
        end if
    else if the right of cd btn "glider_spritesme" >= 511 then
        if rghtopen then
            beginloadlevel curlevel + 1
            set the left of cd btn "glider_spritesme" to 20
        else
            set the right of cd btn "glider_spritesme" to 511
        end if
    end if
end mainloopgame_checkbounds

on newlevelbonus
    global levelsseen, curlevel
    if line (curlevel) of levelsseen is "" then
        put "1" into line (curlevel) of levelsseen
        add 200 to cd fld "score"
    end if
end newlevelbonus

on mainloopgame_collisions curlvldata, curlvlObjects
    global dx, dy, propsperobj
    
    put intersectRoomObject(curlvldata, curlvlObjects, the left of cd btn "glider_spritesme", the top of cd btn "glider_spritesme", the right of cd btn "glider_spritesme", the bottom of cd btn "glider_spritesme") into intersects
    put the number of items in intersects into numintersects
    put false into isdead
    
    put 0 into dx 
    put 6 into dy -- by default, we fall
    repeat with numintersect = 2 to numintersects -- ignore the first
        put item (numintersect) of intersects into i
        put item (((i-1)*propsperobj)+(1)) of curlvlObjects into objtypename
        put item (((i-1)*propsperobj)+(7)) of curlvlObjects into amount
        put item (((i-1)*propsperobj)+(8)) of curlvlObjects into extra
        put item (((i-1)*propsperobj)+(9)) of curlvlObjects into isOn
        put getCollideResult(objtypename, isOn, amount, extra) into clr
        put item 1 of clr into collideType
        put item 2 of clr into collideAmt
        
        if collideType is "crashIt" then
            begindeath
        else if collideType is "moveIt" then
            -- not yet supported
        else if collideType is "liftIt" then
            put -6 into dy
        else if collideType is "dropIt" then
            put 12 into dy
        else if collideType is "burnIt" then
            begindeath
            set the icon of cd btn "glider_spritesme" to sprites_burnrght1
        else if collideType is "turnItLeft" then
            put -6 into dx
        else if collideType is "turnItRight" then
            put 6 into dx
        else if collideType is "lightIt" then
            -- not yet supported
        else if collideType is "zapIt" then
            if the icon of cd btn ("glider_sprites" & i) is sprites_outletspark1 then
                begindeath
            end if
        else if collideType is "airOnIt" then
            -- not yet supported
        else if collideType is "shredIt" then
            begindeath
        else if collideType is "upStar" then
            beginloadlevel collideAmt
        else if collideType is "dnStar" then
            beginloadlevel collideAmt
        else if collideType is "getitem_extraIt" then
            add 1 to cd fld "lives"
        else if collideType is "getitem_awardIt" then
            add 50 to cd fld "score"
        end if
        
        if "getitem_" is in collideType then
            -- hide it since it is gone
            put 0 into item (((i-1)*propsperobj)+(9)) of curlvlObjects
            hide cd btn ("glider_sprites" & i)
        end if
    end repeat
end mainloopgame_collisions


on mainloopgame_periodic i, curlvldata, curlvlObjects
    global clockcount, propsperobj, sprites_outlet, sprites_outletspark1
    add 1 to clockcount
    if clockcount mod 20 is 1 then
        put (propsperobj * (i-1)) into j
        put item (j+1) of curlvlObjects into objtypename
        if objtypename is "outlet" then
            if the icon of cd btn ("glider_sprites" & i) is sprites_outletspark1 then
                set the icon of cd btn ("glider_sprites" & i) to sprites_outlet
            else
                set the icon of cd btn ("glider_sprites" & i) to sprites_outletspark1
            end if
        end if
    end if
end mainloopgame_periodic

on mainloopdying
    global deathcount, state, curlevel, sprites_right_forward
    if deathcount < 30 then
        put deathcount+1 into deathcount
    else
        subtract 1 from cd fld "lives"
        if cd fld "lives" < 0 then
            put "nogame" into state
            put -3 into curlevel
            refreshOnLevelChange
        else
            set the topleft of cd btn "glider_spritesme" to 20,20
            set the icon of cd btn "glider_spritesme" to sprites_right_forward
            put "playing" into state
        end if
    end if
end mainloopdying

on mainlooploadinglevel
    global loadlevelcount, state, curlevel
    if loadlevelcount < 2 then
        put loadlevelcount+1 into loadlevelcount
        put "." after cd fld "roomname"
    else
        refreshOnLevelChange
        put "playing" into state
    end if
end mainlooploadinglevel

on beginloadlevel nextlevel
    global loadlevelcount, state, curlevel
    put nextlevel into curlevel
    newlevelbonus
    if curlevel < 1 then
            put 1 into curlevel --sanity check
    else if curlevel > 40 then
            put 40 into curlevel --sanity check
    end if
    -- skipped levels we don't yet support
    if curlevel is 7 then
        put curlevel+1 into curlevel
    end if
    if curlevel is 13 then
        put curlevel+1 into curlevel
    end if
    if curlevel is 28 then
        put curlevel+1 into curlevel
    end if
    if curlevel is 29 then
        put curlevel+1 into curlevel
    end if
    if curlevel is 37 then
        put curlevel+1 into curlevel
    end if
    
    put 0 into loadlevelcount
    put "Loading" into cd fld "roomname"
    put "loadinglevel" into state
end beginloadlevel

on idle
    global state
    if state is "playing" then
        global curlevel, lvlData, lvlObjects, dx, dy, gcurlvldata, gcurlvlObjects
        -- warning: be careful that we don't warp through a solid object.
        -- for example, if you are moving at 12 pixels per update, and your height is 5 pixels, it's possible to completely slip through
        -- a solid object that is only 6 pixels wide
        put 0 into dx
        put 0 into dy
        mainloopgame_collisions gcurlvldata, gcurlvlObjects
        mainloopgame_checkbounds gcurlvldata, gcurlvlObjects
        mainloopgame_motion gcurlvldata, gcurlvlObjects
    else if state is "dying" then
        mainloopdying
    else if state is "loadinglevel" then
        mainlooploadinglevel
    end if
end idle

on afterkeydown
    global lastdirpressed, cheat_invincible
    if keychar() is "ArrowLeft" then
        put "-1" into lastdirpressed
    else if keychar() is "ArrowRight" then
        put "1" into lastdirpressed
    else if keyChar() is "I" and shiftKey() and not keyrepeated() then
        answer "toggle cheatcode:invincible"
        if cheat_invincible is true then
            put false into cheat_invincible
        else
            put true into cheat_invincible
        end if
    else if keyChar() is "N" and shiftKey() and not keyrepeated() then
        global curlevel, state
        put "needreset" into curlevel
        put "nogame" into state
        refreshOnLevelChange
        show cd btn "btn_continue"
        set the label of cd btn "btn_continue" to "Start Over"
    end if
end afterkeydown

on begindeath
    global state, deathcount, sprites_alldeadrght, cheat_invincible
    if cheat_invincible is not true then
        put "dying" into state
        put 0 into deathcount
        set the icon of cd btn "glider_spritesme" to sprites_alldeadrght
    end if
end begindeath

on refreshOnLevelChange
    global curlevel, gcurlvldata, gcurlvlObjects, lvlData, lvlObjects
    if curlevel is not "needreset" and curlevel >= 1 then
        put line (curlevel) of lvlData into gcurlvldata
        put line (curlevel) of lvlObjects into gcurlvlObjects
    end if
    
    repeat with x=1 to 16
        hide cd btn ("glider_sprites" & x)
    end repeat
    hide cd btn "glider_spritesme"
    hide cd btn "glider_spritesshadow"
    
    global lastdirpressed, propsperobj
    put "" into lastdirpressed
    put 9 into propsperobj
    set the itemdelimiter to "|"
    show cd btn "glider_bg0"
    hide cd fld "roomname"
    hide cd fld "score"
    hide cd fld "lives"
    hide cd fld "behindlives"
    hide cd btn "glider_spriteslivesicon"
    hide cd fld "gameover"
    
    show cd btn "btn_continue"
    set the idlerate to "default"
    if curlevel is "needreset" then
        exit refreshOnLevelChange
    else if curlevel is "" or curlevel is -1 then
        put -1 into curlevel
        set the icon of cd btn "glider_bg0" to 1
        set the rect of cd btn "btn_continue" to (512-28)-120,28,512-28,28+74
        set the label of cd btn "btn_continue" to "New Game"
    else if curlevel is -2 then
        set the icon of cd btn "glider_bg0" to 2
        set the rect of cd btn "btn_continue" to 126,300,126+254,300+36
        set the label of cd btn "btn_continue" to "Start"
    else if curlevel is -3 then
        set the icon of cd btn "glider_bg0" to 3
        set the rect of cd btn "btn_continue" to 126,300,126+254,300+36
        set the label of cd btn "btn_continue" to "Home"
        if cd fld "lives" > 0 then
            hide cd fld "gameover"
        else
            show cd fld "gameover"
            put (newline & newline & "Game Over..." & newline & newline & "Your score was " & (cd fld "score") & ".") into cd fld "gameover"
        end if
    else
        set the idlerate to "faster"
        global sprites_shadoRght, sprites_shadoLft, sprites_right_forward, sprites_right_tipped, sprites_left_forward, sprites_left_tipped
        global sprites_turn_endpoint, sprites_right_forward2, sprites_right_tipped2, sprites_left_forward2, sprites_left_tipped2, sprites_turn_endpoint2
        global sprites_burnrght1, sprites_burnrght2, sprites_burnlft1, sprites_burnlft2, sprites_alldeadrght, sprites_alldeadlft
        global sprites_celVnt, sprites_celDct, sprites_flrVnt, sprites_paper, sprites_toastr, sprites_toast1
        global sprites_toast2, sprites_toast3, sprites_toast4, sprites_toast5, sprites_toast6, sprites_teaKtl
        global sprites_lftFan, sprites_ritFan, sprites_table, sprites_shredr, sprites_books, sprites_clock
        global sprites_candle, sprites_rbrBnd, sprites_ball, sprites_fshBwl, sprites_fish1, sprites_fish2
        global sprites_fish3, sprites_fish4, sprites_grease, sprites_greasefall1, sprites_greasefall2, sprites_litSwt
        global sprites_thermo, sprites_outlet, sprites_outletspark1, sprites_outletspark2, sprites_pwrSwt, sprites_guitar
        global sprites_drip, sprites_shelf, sprites_basket, sprites_paintg, sprites_battry, sprites_macTsh
        global sprites_upStar, sprites_dnStar, sprites_candleflame1, sprites_candleflame2, sprites_candleflame3, sprites_drop1
        global sprites_drop2, sprites_drop3, sprites_drop4, sprites_drop5
        show cd btn "glider_spritesme"
        show cd btn "glider_spritesshadow"
        show cd fld "roomname"
        show cd fld "score"
        show cd fld "lives"
        show cd fld "behindlives"
        show cd btn "glider_spriteslivesicon"
        set the icon of cd btn "glider_bg0" to 3+curlevel
        hide cd btn "btn_continue"
        global sprites_ventpatterny
        
        put 24 into kCeilingVert
		put 325 into kFloorVert
        
        put 2 into q -- need to tweak the rect of everything larger, to make the sprite show up
        
        -- actually load the room
        global curlevel, lvlData, lvlObjects, dx, dy, propsperobj
        put line (curlevel) of lvlData into curlvldata
        put item 1 of curlvldata into cd fld "roomname"
        
        -- actually load the room's objects
        put line (curlevel) of lvlObjects into curlvlObjects
        put item 2 of curlvldata into numobjects
        repeat with i = 1 to numobjects
            put (propsperobj * (i-1))  into j
            put item (j+3) of curlvlObjects into spritex0
            put item (j+4) of curlvlObjects into spritey0
            put item (j+5) of curlvlObjects into spritex1
            put item (j+6) of curlvlObjects into spritey1
            set the rect of cd btn ("glider_sprites" & i) to spritex0, spritey0, spritex1, spritey1
            set the icon of cd btn ("glider_sprites" & i) to 0 -- invisible by default
            show cd btn ("glider_sprites" & i)
            put item (j+1) of curlvlObjects into objtypename
            put item (j+7) of curlvlObjects into amount
            if objtypename is "flrVnt" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_ventpatterny
                -- the event rect is different than the sprite rect. see tempInt := (boundRect.right + boundRect.left) div 2;
                put round((spritex0 + spritex1)/2) into tempInt
                set the rect of cd btn ("glider_sprites" & i) to tempInt - 8, amount, tempInt + 8, kFloorVert
            else if objtypename is "celVnt" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_ventpatterny
                put round((spritex0 + spritex1)/2) into tempInt
                set the rect of cd btn ("glider_sprites" & i) to tempInt - 8, kCeilingVert, tempInt + 8, amount
            else if objtypename is "celDct" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_ventpatterny
                put round((spritex0 + spritex1)/2) into tempInt
                set the rect of cd btn ("glider_sprites" & i) to tempInt - 8, kCeilingVert, tempInt + 8, amount
            else if objtypename is "lftFan" then
                set the rect of cd btn ("glider_sprites" & i) to amount, spritey0 + 10, spritex0, spritey0 + 30
            else if objtypename is "ritFan" then
                set the rect of cd btn ("glider_sprites" & i) to spritex1, spritey0 + 10, amount, spritey0 + 30
            else if objtypename is "guitar" then
                set the rect of cd btn ("glider_sprites" & i) to spritex0+36, spritey0 + 24, spritex0+38, spritey1 -56
            else if objtypename is "upStar" then
                set the rect of cd btn ("glider_sprites" & i) to spritex0 + 32, spritey0, spritex1 - 32, spritey0 + 8
            else if objtypename is "dnStar" then
                set the rect of cd btn ("glider_sprites" & i) to spritex0 + 32, spritey1 - 8, spritex1 - 32, spritey1
            else if objtypename is "candle" then
                put round((spritex0 + spritex1)/2) into tempInt
				set the rect of cd btn ("glider_sprites" & i) to tempInt - 12, amount, tempInt + 4, spritey0
                
            else if objtypename is "outlet" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_outlet
            else if objtypename is "clock" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_clock
            else if objtypename is "battry" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_battry
            else if objtypename is "paper" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_paper
            
            -- bnsRct is a bonus rectangle
            else if objtypename is "litSwt" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_litSwt
            else if objtypename is "grease" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_grease
            else if objtypename is "rbrBnd" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_rbrBnd
            else if objtypename is "drip" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_drip
            else if objtypename is "shredr" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_shredr
            else if objtypename is "ball" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_ball
            else if objtypename is "fshBwl" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_fshBwl
            else if objtypename is "pwrSwt" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_pwrSwt
            else if objtypename is "thermo" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_thermo
            else if objtypename is "toastr" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_toastr
            else if objtypename is "teaKtl" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_teaKtl
            else if objtypename is "macTsh" then
                set the icon of cd btn ("glider_sprites" & i) to sprites_macTsh
            end if
            
            set the width of cd btn ("glider_sprites" & i) to q + the width of cd btn ("glider_sprites" & i)
            set the height of cd btn ("glider_sprites" & i) to q + the height of cd btn ("glider_sprites" & i)
        end repeat
    end if
end refreshOnLevelChange
