
module {

    public type TokenOperation = {
        #mint;
        #burn;
        #transfer;
        #approve;
        #unknown;
    };

    public func tokenOperationToNat8(o : TokenOperation) : Nat8 {
        switch o {
            case (#mint) {0};
            case (#burn) {1};
            case (#transfer) {2};
            case (#approve) {3};
            case (#unknown) {255};
        };
    };

    public func tokenOperationToText(o : TokenOperation) : Text {
        switch o {
            case (#mint) {"mint"};
            case (#burn) {"burn"};
            case (#transfer) {"transfer"};
            case (#approve) {"approve"};
            case (#unknown) {"unknown"};
        };
    };

    public func tokenOperationFromNat8(o : Nat8) : TokenOperation {
        switch o {
            case (0) {#mint};
            case (1) {#burn};
            case (2) {#transfer};
            case (3) {#approve};
            case (_) {#unknown};
        };
    };
};