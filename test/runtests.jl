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
            label="$bot_name prob=$(lf.prob)",
            xlabel="n games",
            ylabel="\$",
            legend = :topleft,
            dpi = 300
        )
    end
    # Plots.savefig("Stats.png")
end

@testset "Battle" begin
    n_tournaments = 50
    bots = (
        PB.BotRandom(0.4),
        PB.BotRandom(0.4),
        PB.BotRandom(0.6),
        PB.BotRandom(0.6),
    )
    @time stats, n_games = PB.battle!(n_tournaments, bots...)
    plot_stats(stats, n_games)
end
