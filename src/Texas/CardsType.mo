

module {

    public type CardsType = {
        #nonetype;
        #highcard;
        #pair;
        #twopair;
        #trip;
        #straight;
        #flush;
        #fullhouse;
        #quards;
        #strightflush;
    };

    public func cardsTypeToText(ct : CardsType) : Text {
        switch ct {
            case (#nonetype) {"none type"};
            case (#highcard) {"high card"};
            case (#pair) {"one pair"};
            case (#twopair) {"two pair"};
            case (#trip) {"trip"};
            case (#straight) {"straight"};
            case (#flush) {"flush"};
            case (#fullhouse) {"full house"};
            case (#quards) {"quards"};
            case (#strightflush) {"straight flush"};
        };
    };

    public func cardsTypeToNat(ct : CardsType) : Nat {
        switch ct {
            case (#nonetype) {255};
            case (#highcard) {0};
            case (#pair) {1};
            case (#twopair) {2};
            case (#trip) {3};
            case (#straight) {4};
            case (#flush) {5};
            case (#fullhouse) {6};
            case (#quards) {7};
            case (#strightflush) {8};
        };
    }
};