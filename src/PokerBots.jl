module PokerBots

import Logging
import TexasHoldem
const TH = TexasHoldem

include("bots.jl")


function battle!(n_tournaments, bots...)
    n_players = length(bots)

    initial_players = ntuple(n_players) do i
        Player(bots[i], i)
    end

    FT = Float64

    stats = Dict{Symbol,Any}()

    stats[:player_bank_rolls] = map(initial_players) do player
        (Vector{FT}(), TH.seat_number(player), TH.life_form(player))
    end

    stats[:tournament_winnings] = zeros(length(initial_players))

    # Assumes all BRs start out equal
    tournament_winnings = sum(map(initial_players) do player
        TH.bank_roll(player)
    end) - TH.bank_roll(first(initial_players))

    n_games = 0
    local winners
    for i in 1:n_tournaments
        players = deepcopy(initial_players)

        # @info "******************************** Playing tournament!"
        # TODO: ensure button moves continuously through multiple tournaments
        game = TH.Game(players)
        table = game.table
        players = TH.players_at_table(table)
        while length(players) > 1

            Logging.with_logger(Logging.NullLogger()) do
                winners = TH.play!(game)
            end

            n_games+=1
            for (j, player) in enumerate(players)
                @assert TH.seat_number(player) == j
                sn = TH.seat_number(player)
                br = TH.bank_roll(player)
                ptw = stats[:tournament_winnings][sn]
                push!(stats[:player_bank_rolls][sn][1], br+ptw)
            end

            n_players_remaining = count(map(x->!(TH.bank_roll(x) ≈ 0), players))
            if n_players_remaining ≤ 1
                if !(length(winners.players) == 1) # 1 victor per tournament
                    # @show winners.players
                    # @show n_players_remaining
                    if !all(TH.seat_number.(winners.players) .== Ref(TH.seat_number(first(winners.players))))
                        @show winners.players
                        @show TH.seat_number.(winners.players)
                        error("Nooooo")
                    end
                    # TODO: fix this bug in TH.
                    winners.players = (winners.players[1],)
                end
                for winner in winners.players
                    sn = TH.seat_number(winner)
                    stats[:tournament_winnings][sn]+=tournament_winnings
                end
                # println("Victor emerges!")
                break
            end
            TH.reset_game!(game)
            TH.move_buttons!(game)
        end
        # @info "******************************** Finished tournament!"
        if n_tournaments > 1000
            if mod(i, 100) == 0
                @info "progress = $(i/n_tournaments*100)%"
            end
        else
            @info "progress = $(i/n_tournaments*100)%"
        end
    end
    return stats, n_games
end

end # module
