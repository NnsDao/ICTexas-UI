
module {

    public type Card = {
        #club : Nat;
        #diamond : Nat;
        #hearts : Nat;
        #spade : Nat;
    };

    func cardFaceToText(face : Nat) : Text {
        switch face {
            case (0) {"2"};
            case (1) {"3"};
            case (2) {"4"};
            case (3) {"5"};
            case (4) {"6"};
            case (5) {"7"};
            case (6) {"8"};
            case (7) {"9"};
            case (8) {"T"};
            case (9) {"J"};
            case (10) {"Q"};
            case (11) {"K"};
            case (12) {"A"};
            case (_) {
                assert (false);
                "";
            };
        };
    };

    public func cardToText(card : Card) : Text {
        switch card {
            case (#club(face)) { cardFaceToText(face) # "C"; };
            case (#diamond(face)) { cardFaceToText(face) # "D"; };
            case (#hearts(face)) { cardFaceToText(face) # "H"; };
            case (#spade(face)) { cardFaceToText(face) # "S"; };
        };
    };

    public func cardFromNat(card : Nat) : Card {
        switch (card/13) {
            case (0) { #club(card%13); };
            case (1) { #diamond(card%13); };
            case (2) { #hearts(card%13); };
            case (3) { #spade(card%13); };
            case (_) { 
                assert (false);
                #club(card%13);
            };
        };
    };

    public func getCardFace(card : Card) : Nat {
        switch card {
            case (#club(face)) { face };
            case (#diamond(face)) { face };
            case (#hearts(face)) { face };
            case (#spade(face)) { face };
        };
    };

};