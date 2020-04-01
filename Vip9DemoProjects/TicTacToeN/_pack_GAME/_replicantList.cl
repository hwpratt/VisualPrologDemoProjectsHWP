/******************************************************************************
Author:       Harrison Pratt      Copyright(c) 2019 Quixote Software
File:         replicantList.cl
Project:
Package:
Created:      2019-11-24
Modified:
Purpose:      Retrieve and test for replicant values in a list of terms

Comments:

    Replicant values are values the repeat IN SEQUENCE,
        e.g.  3 is a replicant value in [1,2,3,3,4,5]

    A replicant list has 2+ members.

    A list shorter than 2 elements cannot contain replicants, of course,
    so some of these predicates will fail if the list has 0...1 elements.

    "first" refers to FIRST OCCURRENCE of a replicating series,
        not to the "head" of the list of terms.


******************************************************************************/

class replicantList
    open core

predicates
    getReplicants : (T* SearchInList) -> T** ListOfReplicantLists determ.
    % FAILS if no replicants found.
    /* Example:
            In:  [9,9,  1,2,  6,6,6,6,  3,  8,8,8]
            Out: [[9,9],[6,6,6,6],[8,8,8]]
        */
    firstReplicantCount : (T* TermList) -> positive NumberOfReplicants. % return 0 if no replicants
    getFirstReplicantList2 : (T* SearchInList, T* RemaingList [out]) -> T* determ.
    % Return the first replicant series FOUND, plus the remaining terms
    % Non-replicated terms before the replicant list are discarded.
    % FAILS if no replicant terms are found.
    getFirstReplicantList : (T* SearchInList) -> T* determ.
    getFirstReplicantIndex : (T* TermList) -> positive Index0 determ.
    getFirstReplicantValue : (T* TermList) -> T determ.
    getFirstReplicantValueCount : (T* TermList, T ReplicatedTerm, positive TermCount) determ.
    getReplicantCountMin : (T*, positive MinTerms) -> tuple{T, positive Len} determ.
    % return the term and length of the first series longer than MinTerms
    hasReplicantsAny : (T* TermList) determ. % Succeed if has at least two replicant values
    isReplicantList : (T*) determ. % succeed if all same value as head
    isReplicanListOf : (T*, T TestMemeber) determ. % succeed if all same value TestMember
    hasReplicantCountMin : (T*, T MatchTerm, positive Count) determ. % succeed if has at least Count of MatchTerm
    splitOnReplicants : (T* TermList, T* FrontList [out], T* Replicants [out], T* EndList [out]) determ.

end class replicantList
