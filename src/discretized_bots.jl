import StatsBase as SB
import Distributions as D

"""
    DiscretizedBot

A discretized bot-- where `option` is
a single integer that denotes the chosen
(sane) action.

 - 1: fold
 - 2: check
 - 3: call
 - 4: raise to small blind (+ n*Δraise, n = 1)
 - 5: raise to small blind + n*Δraise, n = 2
 - 6: raise to small blind + n*Δraise, n = 3
 ....
 - n-1: raise to small blind + (n-1)*Δraise, n = n
 - n: raise all-in
N = n + 4
n = bank_roll/n_disc
 - n_disc number of bins for discretized raises
"""
mutable struct DiscretizedBot{NDISC,APW} <: AbstractAI
    action_num::Int
    act_prob_wv::APW
end

non_valid_actions(player::Player, ::CheckRaiseFold) = (1, 3,) # 1 is not sane
non_valid_actions(player::Player, ::CallRaiseFold) = (2,)
function non_valid_actions(player::Player, ::CallAllInFold)
    @assert n_actions(player) > 4
    (2,collect(4:(n_actions(player)-1))...)
end
non_valid_actions(player::Player, ::CallFold) = (2,collect(4:(n_actions(player)))...)

is_fold_action(player::Player) = player.life_form.action_num == 1
is_check_action(player::Player) = player.life_form.action_num == 2
is_call_action(player::Player) = player.life_form.action_num == 3
is_raise_action(player::Player) = player.life_form.action_num > 3
is_raise_all_in_action(player) = action_num(player)==all_in_action_num(player)
n_disc(::Type{DB}) where {NDISC,DB<:DiscretizedBot{NDISC}} = NDISC
n_disc(life_form::DiscretizedBot{NDISC}) where {NDISC} = NDISC
n_disc(player::Player{DB}) where {DB <: DiscretizedBot} = n_disc(player.life_form)
n_actions(player::Player{DB}) where {DB <: DiscretizedBot} = n_disc(player)+3
all_in_action_num(player::Player{DB}) where {DB <: DiscretizedBot} = n_disc(player)+3
action_num(player::Player{DB}) where {DB <: DiscretizedBot} = player.life_form.action_num
action_probability_weights(player::Player{DB}) where {DB <: DiscretizedBot} = player.life_form.act_prob_wv

function DiscretizedBot(NDISC::Int)
    action_num = 0
    n_actions = NDISC+3
    act_prob_wv = SB.ProbabilityWeights(collect(ones(n_actions)))
    APW = typeof(act_prob_wv)
    return DiscretizedBot{NDISC,APW}(action_num, act_prob_wv)
end

function discretized_raise_to!(game::Game, player::Player{DB}, act_num::Int) where {DB <: DiscretizedBot}
    NDISC = n_disc(player)
    @assert act_num isa Int
    offset_act_num = act_num - 3
    @assert 1 ≤ offset_act_num ≤ NDISC
    br_frac = offset_act_num/NDISC
    @assert 0 < br_frac ≤ 1
    amt = br_frac*bank_roll(player)
    amt = round(amt, base=2) # TODO: round to nearest n-number of smallest chip size
    bounded_amt = TH.bound_raise(game.table, player, amt)
    raise_to!(game, player, bounded_amt)
end

function TH.player_option!(game::Game, player::Player{DB}, options::CheckRaiseFold) where {DB<:DiscretizedBot}
    set_action_num!(player, options)
    if is_check_action(player)
        check!(game, player)
    elseif is_raise_action(player)
        discretized_raise_to!(game, player, action_num(player))
    else
        error("Bad option")
    end
end
function TH.player_option!(game::Game, player::Player{DB}, options::CallRaiseFold) where {DB<:DiscretizedBot}
    set_action_num!(player, options)
    if is_call_action(player)
        call!(game, player)
    elseif is_raise_action(player)
        discretized_raise_to!(game, player, action_num(player))
    elseif is_fold_action(player)
        fold!(game, player)
    else
        error("Bad option")
    end
end
function TH.player_option!(game::Game, player::Player{DB}, options::CallAllInFold) where {DB<:DiscretizedBot}
    set_action_num!(player, options)
    if is_call_action(player)
        call!(game, player)
    elseif is_raise_all_in_action(player)
        raise_all_in!(game, player)
    elseif is_fold_action(player)
        fold!(game, player)
    else
        error("Bad option")
    end
end
function TH.player_option!(game::Game, player::Player{DB}, options::CallFold) where {DB<:DiscretizedBot}
    set_action_num!(player, options)
    if is_call_action(player)
        call!(game, player)
    elseif is_fold_action(player)
        fold!(game, player)
    else
        error("Bad option")
    end
end

Base.deleteat!(wv::SB.ProbabilityWeights, inds) =
    SB.ProbabilityWeights(deleteat!(wv.values, inds))

function set_action_num!(player::Player, options::PlayerOptions)
    nva = non_valid_actions(player, options)

    actions = collect(1:n_actions(player))
    deleteat!(actions, nva)

    apw = deepcopy(action_probability_weights(player))
    deleteat!(apw, nva)

    player.life_form.action_num = D.sample(actions, apw)
    an = player.life_form.action_num
end
