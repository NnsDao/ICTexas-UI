

module {

    public type SiteType = {
        #high;
        #mid;
        #low;
    };

    public type SiteInfo = (siteType: SiteType, minBalance: Nat, smallBlind: Nat);

    public func getSmallBlind(st : SiteType) : Nat {
        switch st {
            case (#high) {100_000_00_000_000};
            case (#mid) {1_000_00_000_000};
            case (#low) {10_00_000_000};
        };
    };

    public func getMinimalBalance(st : SiteType) : Nat {
        switch st {
            case (#high) {10_000_000_00_000_000};
            case (#mid) {100_000_00_000_000};
            case (#low) {1_000_00_000_000};
        };
    };

    public func fromNat(t: Nat) : SiteType {
        switch t {
            case (0) {#high};
            case (1) {#mid};
            case (2) {#low};
            case _ {#low};
        };
    };

    public func toNat(st: SiteType) : Nat {
        switch st {
            case (#high) {0};
            case (#mid) {1};
            case (#low) {2};
        };
    };

    public func toText(st: SiteType) : Text {
        switch st {
            case (#high) {"high"};
            case (#mid) {"mid"};
            case (#low) {"low"};
        };
    };
};