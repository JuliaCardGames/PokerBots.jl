using TexasHoldem
import TexasHoldem
TH = TexasHoldem

struct Bot5050 <: AbstractAI end
function TH.player_option!(game::Game, player::Player{Bot5050}, ::CheckRaiseFold)
    if rand() < 0.5; check!(game, player)
    else
        amt = Int(round(rand()*bank_roll(player), digits=0))
        amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
        raise_to!(game, player, amt)
    end
end
function TH.player_option!(game::Game, player::Player{Bot5050}, ::CallRaiseFold)
    if rand() < 0.5
        if rand() < 0.5; call!(game, player)
        else # re-raise
            amt = Int(round(rand()*bank_roll(player), digits=0))
            amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
            raise_to!(game, player, amt)
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{Bot5050}, ::CallAllInFold)
    if rand() < 0.5
        if rand() < 0.5; call!(game, player)
        else; raise_all_in!(game, player) # re-raise
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{Bot5050}, ::CallFold)
    if rand() < 0.5; call!(game, player)
    else; fold!(game, player)
    end
end

struct Bot6040 <: AbstractAI end
function TH.player_option!(game::Game, player::Player{Bot6040}, ::CheckRaiseFold)
    if rand() < 0.6; check!(game, player)
    else
        amt = Int(round(rand()*bank_roll(player), digits=0))
        amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
        raise_to!(game, player, amt)
    end
end
function TH.player_option!(game::Game, player::Player{Bot6040}, ::CallRaiseFold)
    if rand() < 0.4
        if rand() < 0.6; call!(game, player)
        else # re-raise
            amt = Int(round(rand()*bank_roll(player), digits=0))
            amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
            raise_to!(game, player, amt)
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{Bot6040}, ::CallAllInFold)
    if rand() < 0.4
        if rand() < 0.6; call!(game, player)
        else; raise_all_in!(game, player) # re-raise
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{Bot6040}, ::CallFold)
    if rand() < 0.4; call!(game, player)
    else; fold!(game, player)
    end
end
