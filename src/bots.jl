using TexasHoldem
import TexasHoldem
TH = TexasHoldem
struct BotRandom <: AbstractAI
    prob::Float64
end
function TH.player_option!(game::Game, player::Player{BotRandom}, ::CheckRaiseFold)
    prob = TH.life_form(player).prob
    if rand() < prob; check!(game, player)
    else
        amt = Int(round(rand()*bank_roll(player), digits=0))
        amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
        raise_to!(game, player, amt)
    end
end
function TH.player_option!(game::Game, player::Player{BotRandom}, ::CallRaiseFold)
    prob = TH.life_form(player).prob
    if rand() < 1-prob
        if rand() < prob; call!(game, player)
        else # re-raise
            amt = Int(round(rand()*bank_roll(player), digits=0))
            amt = TH.bound_raise(game.table, player, amt) # to properly bound raise amount
            raise_to!(game, player, amt)
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{BotRandom}, ::CallAllInFold)
    prob = TH.life_form(player).prob
    if rand() < 1-prob
        if rand() < prob; call!(game, player)
        else; raise_all_in!(game, player) # re-raise
        end
    else
        fold!(game, player)
    end
end
function TH.player_option!(game::Game, player::Player{BotRandom}, ::CallFold)
    prob = TH.life_form(player).prob
    if rand() < 1-prob; call!(game, player)
    else; fold!(game, player)
    end
end