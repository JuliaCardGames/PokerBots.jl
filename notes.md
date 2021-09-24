features:

    1) hand strength--expected value of final hand_rank

    2) hand_rank (strength of existing best 5-card hand)
    3) raw odds of winning (if all-in)
    4) (still playing) max opponents bank roll (risk)
    5) position! # may not be super important now
    6) total pot amount
    7) number of opponents who contributed to the pot (pot odds)

    would be really easy to start with 4,5,6,7!
    loss function can be:
        amount lost per hand (i.e., signed amount
        gained, where amount can be negative)

    # May be duplicates/non-orthogonal to ones above
    # 8) estimate of opponent's skill/variance?
    # 9) player cards connectedness (number of combinations of
    #                               straights that can be formed
    #                               with the player's 2 cards)
    # 10) suited/offsuit player cards
    # 11) n-suits

import PlayingCards as PC

dict[,suited/offsuit]
dict[connectedness,true/false]

"""
    n_straght_comb(cards::Tuple{PlayingCards.Card, PlayingCards.Card})

The number of possible straights obtainable with
the given two playing cards. 
 - `n_straght_comb((A♢,A♣)) == 0`
 - `connectedness((A♢,K♣)) == 1`
 - `connectedness((A♢,K♣)) == 1`
 - `(A♢,2♢),3♢,4♢,5♢` -> `n_straght_comb() == 1`
 - `[A♢,](2♢,3♢),4♢,5♢[,6♢]` -> `n_straght_comb() == 2`
 - `[A♢,2♢,](3♢,4♢),5♢[,6♢,7♢]` -> `n_straght_comb() == 3`
 - `[A♢,2♢,3♢,](4♢,5♢)[,6♢,7♢,8♢]` -> `n_straght_comb() == 4`

"""
function connectedness(cards::Tuple{PC.Card,PC.Card})
    ranks = rank.(cards)
    if all(ranks) == 14 # aces
        return 0
    elseif any(ranks) == 14 # ace could be high/low
        min()
    else
    end
end

