import Nat "mo:base/Nat";

module {

    // bound addtion amount token need to act
    public type Action = {
        #smallblind : Nat;
        #bigblind : Nat;
        #check : Nat;
        #bet : Nat;
        #call : Nat;
        #raise : Nat;
        #allin : Nat;
        #fold : Nat;
    };

    public func actionToText(action : Action) : Text {
        switch action {
            case (#smallblind(n)) { "smallblind " # Nat.toText(n)};
            case (#bigblind(n)) {"bigblind " # Nat.toText(n)};
            case (#check(n)) {"check"};
            case (#bet(n)) {"bet " # Nat.toText(n)};
            case (#call(n)) {"call " # Nat.toText(n)};
            case (#raise(n)) {"raise " # Nat.toText(n)};
            case (#allin(n)) {"allin " # Nat.toText(n)};
            case (#fold(n)) {"fold"};
        };
    };

    public func amountOf(action : Action) : Nat {
        switch action {
            case (#smallblind(n)) {n};
            case (#bigblind(n)) {n};
            case (#check(n)) {0};
            case (#bet(n)) {n};
            case (#call(n)) {n};
            case (#raise(n)) {n};
            case (#allin(n)) {n};
            case (#fold(n)) {0};
        };
    };

    public func standardAction(action : Action) : Action {
        switch action {
            case (#smallblind(n)) {#smallblind(n)};
            case (#bigblind(n)) {#bigblind(n)};
            case (#check(n)) {#check(0)};
            case (#bet(n)) {#bet(n)};
            case (#call(n)) {#call(n)};
            case (#raise(n)) {#raise(n)};
            case (#allin(n)) {#allin(n)};
            case (#fold(n)) {#fold(0)};
        };
    };

    public func isSmallBlind(action : Action) : Bool {
        switch action {
            case (#smallblind(n)) {true};
            case _ {false};
        };
    };

    public func isBigBlind(action : Action) : Bool {
        switch action {
            case (#bigblind(n)) {true};
            case _ {false};
        };
    };

    public func isCheck(action : Action) : Bool {
        switch action {
            case (#check(n)) {true};
            case _ {false};
        };
    };

    public func isBet(action : Action) : Bool {
        switch action {
            case (#bet(n)) {true};
            case _ {false};
        };
    };

    public func isCall(action : Action) : Bool {
        switch action {
            case (#call(n)) {true};
            case _ {false};
        };
    };

    public func isRaise(action : Action) : Bool {
        switch action {
            case (#raise(n)) {true};
            case _ {false};
        };
    };

    public func isAllIn(action : Action) : Bool {
        switch action {
            case (#allin(n)) {true};
            case _ {false};
        };
    };

    public func isFold(action : Action) : Bool {
        switch action {
            case (#fold(n)) {true};
            case _ {false};
        };
    };
};