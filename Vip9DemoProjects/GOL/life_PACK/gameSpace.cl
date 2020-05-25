% Harrison Pratt 2020

class gameSpace : gameSpace
    open core

domains
    rc_DOM = rc(integer Row, integer Col).
    rcList_DOM = rc_DOM*.

predicates
    display : (window Parent) -> gameSpace Form.

constructors
    new : (window Parent).

end class gameSpace
