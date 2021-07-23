# https://github.com/jheinen/GR.jl/issues/278#issuecomment-587090846
ENV["GKSwstype"] = "nul"

using Test
import Plots
using PokerBots
using TexasHoldem
const PB = PokerBots
const TH = TexasHoldem

function plot_stats(stats, n_games)

    player_bank_rolls = stats[:player_bank_rolls]
    p = Plots.plot()
    for (player_bank_roll, pid, lf) in player_bank_rolls
        bot_name = nameof(typeof(lf))
        Plots.plot!(1:n_games, player_bank_roll;
            markershape=:auto,
            label="$bot_name"
        )
    end
    Plots.savefig("Stats.png")
end

@testset "Battle" begin
    n_tournaments = 2000
    bots = (
        PB.Bot5050(),
        PB.Bot5050(),
        PB.Bot6040(),
        PB.Bot6040(),
    )
    stats, n_games = PB.battle!(n_tournaments, bots...)
    plot_stats(stats, n_games)
end
