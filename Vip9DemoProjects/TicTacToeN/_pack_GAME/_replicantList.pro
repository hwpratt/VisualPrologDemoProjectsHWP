/******************************************************************************
Author:       Harrison Pratt      Copyright(c) 2019 Quixote Software
File:         replicantList.pro
Project:
Package:
Created:      2019-11-24
Modified:
Purpose:      Retrieve and test for replicant values in a list of terms

Comments:

    Replicant values are values the repeat IN SEQUENCE,
        e.g.  3 is a replicant value in [1,2,3,3,4,5]

    A list shorter than 2 elements cannot contain replicants, of course,
    so some of these predicates will fail if the list has 0...1 elements.

    "first" refers to FIRST OCCURRENCE of a replicating series,
        not to the "head" of the list of terms.
******************************************************************************/

implement replicantList
    open core

clauses
    getFirstReplicantList2(SearchinList, ListRemaining) = RepList :-
        if [H, H | _] = SearchinList then
            RepList = list::takeWhile(SearchinList, { (E) :- E = H }),
            ListRemaining = list::drop(list::length(RepList), SearchinList)
        elseif list::length(SearchinList) > 2 then
            RepList = getFirstReplicantList2(list::drop(1, SearchinList), ListRemaining)
        else
            fail
        end if.
    getFirstReplicantList(SearchInList) = getFirstReplicantList2(SearchInList, _).

    getReplicants(SearchInList) = RRR :-
        RRR = getReplicants(SearchInList, []),
        RRR <> [].

    getReplicantCountMin(TT, NumTerms) = tuple(MatchTerm, Len) :-
        RRR = getReplicants(TT),
        RR = list::getMember_nd(RRR),
        Len = list::length(RR),
        NumTerms <= Len,
        MatchTerm = list::nth(0, RR),
        !.

    hasReplicantCountMin(TT, MatchTerm, NumTerms) :-
        RRR = getReplicants(TT),
        RR = list::getMember_nd(RRR),
        MatchTerm = list::nth(0, RR),
        NumTerms <= list::length(RR),
        !.

    hasReplicantsAny([H, H | _T]) :-
        !.
    hasReplicantsAny([_ | T]) :-
        hasReplicantsAny(T).

    isReplicantList([H, H]) :-
        !.
    isReplicantList([H, H | T]) :-
        isReplicantList([H | T]).

    isReplicanListOf(TT, M) :-
        [M | _] = TT,
        isReplicantList(TT).

    getFirstReplicantValue(TT) = list::nth(nextRepIndexFrom(TT, 0), TT).

    getFirstReplicantValueCount(TT, R, Count) :-
        RR = getFirstReplicantList2(TT, _RemainingTerms),
        R = list::nth(0, RR),
        Count = list::length(RR).

    firstReplicantCount(TT) = N :-
        if X0 = getFirstReplicantIndex(TT) and X1 = nextRepIndexFrom(TT, X0) then
            N = X1 - X0 + 1
        else
            N = 0
        end if.

    getFirstReplicantIndex(TT) = nextRepIndexFrom(TT, 0).

    splitOnReplicants(TT, LeftTT, Replicants, RightTT) :-
        X0 = getFirstReplicantIndex(TT),
        X1 = endRepIndexFrom(TT, X0),
        RepCount = X1 - X0 + 1,
        LeftTT = list::take(RepCount, TT),
        RemList = list::drop(RepCount, TT),
        Replicants = list::take(RepCount, RemList),
        RightTT = list::drop(RepCount, RemList).

/*------  LOCAL PREDICATES --------------------------------------------------------------------------------*/
class predicates
    getReplicants : (T* SearchInList, T** AccumList) -> T** RepListList.
    % Return a list of all the replicant termlists, discarding non-replicant terms
clauses
    getReplicants(SearchInList, AccumList) = RepListList :-
        if RR = getFirstReplicantList2(SearchInList, MoreList) then
            NewAccum = [RR | AccumList],
            RepListList = getReplicants(MoreList, NewAccum)
        else
            RepListList = list::reverse(AccumList)
        end if.

class predicates
    nextRepIndexFrom : (T*, positive Index) -> positive Index0 determ.
    % Retrun index of next Replicant series starting from Index
clauses
    nextRepIndexFrom([H, H | _], Index0) = Index0 :-
        !.
    nextRepIndexFrom([_ | T], Index) = Index0 :-
        Index0 = nextRepIndexFrom(T, 1 + Index).

class predicates
    endRepIndexFrom : (T*, positive StartIndex) -> positive Index0 determ.
    % Return index of last replicant in a series
    %   where StartIndex is the index of the first replicant in the series.
clauses
    endRepIndexFrom(TT, StartIndex) = Index0 :-
        MatchTerm = list::nth(StartIndex, TT),
        LastX0 = list::length(TT) - 1,
        X = std::fromTo(StartIndex, LastX0),
        if X <= LastX0 then
            MatchTerm <> list::nth(X, TT),
            Index0 =
                X - 1 % return previous term index if mid-list
        elseif MatchTerm = list::nth(X, TT) then
            Index0 = X, % -- matches at the end of the list, so return current index (last)
            !
        else
            stdio::write("\nFAILED: ", predicate_fullname()),
            stdio::write("\nProcessing ", TT, " from index ", StartIndex),
            fail
        end if,
        !.

end implement replicantList
