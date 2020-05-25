% Harrison Pratt 2020

class gameStoreDB : gameStoreDB
    open core

predicates
    %
    rclistFromDbFile : (string FileName, boolean CenterCells, integer GridDimenion) -> gameSpace::rcList_DOM determ.
    rclistFromDbFile : (boolean CenterCells, integer GridDimenion) -> gameSpace::rcList_DOM determ.
    saveCellsDB : (gameSpace::rcList_DOM).
    saveCellsDB : (string FileName, gameSpace::rcList_DOM).
    browseForFile_PDB : () -> string QFN determ.
    %
    patCategoriesU : () -> string_list. % unique categories
    patCategoryNames : (string Category) -> string_list NameList.
    patCategoryNameCells : (string Category, string Name) -> integer_list_list LiveCellList determ.

constructors
    new : ().

end class gameStoreDB
