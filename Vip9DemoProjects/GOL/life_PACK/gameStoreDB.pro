% Harrison Pratt 2020

implement gameStoreDB
    open core, gameSpace

constants
    defaultFileName : string = "SavedLiveCells.pdb".

class facts - cellDB
    cell : (integer Row, integer Column).

clauses
    saveCellsDB(F, RCList) :-
        retractFactDb(cellDB),
        foreach rc(R, C) in RCList do
            assert(cell(R, C))
        end foreach,
        file::save(F, cellDB, false),
        vpiCommonDialogs::note(predicate_fullname(),
            string::format("Saved % live cells to %", list::length(RCList), filename::getNameWithExtension(F))).

    saveCellsDB(RCList) :-
        saveCellsDB(defaultFileName, RCList).

constants
    fsErrNoSuchFile : string = "File % does not exist.".
    fsErrBadFile : string = "File % has structure incompatible with database.".

clauses
    rclistFromDbFile(CenterCellsTF, GridDimenion) = rclistFromDbFile(browseForFile_PDB(), CenterCellsTF, GridDimenion).

    rclistFromDbFile(FileName, CenterCellsTF, GridDimension) = RCList :-
        if file::existExactFile(FileName) then
            try
                file::consult(FileName, cellDB)
            catch _Err do
                vpiCommonDialogs::error(predicate_fullname(), string::format(fsErrBadFile, FileName)),
                fail
            end try
        else
            vpiCommonDialogs::error(predicate_fullname(), string::format(fsErrNoSuchFile, FileName)),
            fail
        end if,
        %
        if CenterCellsTF = false then
            RCList = [ rc(R, C) || cell(R, C) ]
        else
            RR = [ R || cell(R, _) ],
            CC = [ C || cell(_, C) ],
            CenterR = math::round(list::sum(RR) / list::length(RR)),
            CenterC = math::round(list::sum(CC) / list::length(CC)),
            CenterGrid = math::round(GridDimension / 2),
            AdjRow = CenterGrid - CenterR,
            AdjCol = CenterGrid - CenterC,
            RCList = [ rc(R + AdjRow, C + AdjCol) || cell(R, C) ]
        end if.

constants
    browseDbMask = "*.PDB".
    browseDbFilters : string_list = ["Database files", "*.pdb", "All files", "*.*"].
    browseDbTitle = "Select game database file".
    browseDbFlags : integer_list = [].

clauses
    browseForFile_PDB() = QFN :-
        QFN = vpiCommonDialogs::getFilename(browseDbMask, browseDbFilters, browseDbTitle, browseDbFlags, ".", _Files).

%--------- stored patterns ----------------------------------------------------
%
clauses
    patCategoriesU() = list::removeDuplicates([ C || pat(C, _, _) ]).

    patCategoryNames(C) = list::sort([ N || pat(C, N, _) ]).

    patCategoryNameCells(C, N) = LiveCellList :-
        pat(C, N, LiveCellList),
        !.

class facts - patternDB
    pat : (string Category, string Name, integer_list_list LiveCells) nondeterm.

clauses
    pat("Still Life", "Box", [[0, 1], [0, 1]]).
    pat("Still Life", "Beehive", [[1, 2], [0, 3], [1, 2]]).
    pat("Still Life", "Loaf", [[1, 2], [0, 3], [1, 3], [2]]).
    pat("Still Life", "Boat", [[0, 1], [0, 2], [1]]).
    pat("Still Life", "Tub", [[1], [0, 2], [1]]).
        %
    pat("Oscillator", "Blinker (2)", [[0, 1, 2]]).
    pat("Oscillator", "Toad (2)", [[1, 2, 3], [0, 1, 2]]).
    pat("Oscillator", "Beacon (2)", [[0, 1], [0], [3], [2, 3]]).
    pat("Oscillator", "Pulsar (3)",
            [
                [4, 10],
                [4, 10],
                [4, 5, 9, 10],
                [],
                [0, 1, 2, 5, 6, 8, 9, 12, 13, 14],
                [2, 4, 6, 8, 10, 12],
                [4, 5, 9, 10],
                [],
                [4, 5, 9, 10],
                [2, 4, 6, 8, 10, 12],
                [0, 1, 2, 5, 6, 8, 9, 12, 13, 14],
                [],
                [4, 5, 9, 10],
                [4, 10],
                [4, 10]
            ]).
    pat("Oscillator", "Penta-decathlon(15)", [[0, 1, 2], [1], [1], [0, 1, 2], [], [0, 1, 2], [0, 1, 2], [], [0, 1, 2], [1], [1], [0, 1, 2]]).
        %
    pat("Spaceship", "Glider", [[1], [2], [0, 1, 2]]).
    pat("Spaceship", "Light-weight Ship", [[0, 3], [4], [0, 4], [1, 2, 3, 4]]).
    pat("Spaceship", "Medium-weight Ship", [[1, 2, 3, 4, 5], [0, 5], [5], [0, 4], [2]]).
    pat("Spaceship", "Heavy-weight Ship", [[1, 2, 3, 4, 5, 6], [0, 6], [6], [0, 5], [2, 3]]).

end implement gameStoreDB
