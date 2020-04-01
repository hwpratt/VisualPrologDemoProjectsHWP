% Copyright 2017 Harrison Pratt

implement chartCalculations
    open core, list, string, gdiplus, vpidomains, math

/******************************************************************************

******************************************************************************/
clauses

    longestStr( [] ) = "" :- !.
    longestStr( [H|SS] ) = Longest:value :-
        Longest = varM::new(H),
        foreach S = list::getMember_nd(SS) do
            L = string::length(S),
            if L > string::length(Longest:value) then Longest:value := S end if
        end foreach.

    realMinMax( RR ) = tuple( Min:value, Max:value ) :-
        [H|TT] = RR,
        Min = varM::new(H),
        Max = varM::new(H),
        foreach E = list::getMember_nd(TT) do
            if E < Min:value then Min:value := E end if,
            if E > Max:value then Max:value := E end if
        end foreach.

    realFromToStep(From, To, _Step) = From :-
        From <= To.
    realFromToStep(From, To, Step) = realFromToStep(From + Step, To, Step) :-
        From < To.

    realsFromToStep( From,To,Step ) = RR :-
        RR = [ R || R = realFromToStep(From,To,Step) ].

    reals_reals32( RR ) = [ R32 || R = getMember_nd(RR), R32 = convert( real32, R ) ].

    reals32_reals( RR32 ) = [ R || R32 = getMember_nd(RR32), R = convert( real, R32 ) ].

    isPNT_in_RectF( vpiDomains::pnt(Px,Py), gdiplus::rectF( L,T,W,H ) ):-
        % NOTE: does NOT manage negative W or H, which should not occur in normal operations but ...
        Px >= round(L),
        Px <= round(L+W),
        Py >= round(T),
        Py <= round(T+H).

end implement chartCalculations