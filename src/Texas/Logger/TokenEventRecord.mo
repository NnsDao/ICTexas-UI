import Time "mo:base/Time";
import AID "../Utils/AccountId";

module {

    public type TokenEventRecord = {
        caller: Int;
        op: Nat8;
        from: Int;
        to: Int;
        amount: Nat64;
        fee: Nat64;
        timestamp: Time.Time;
        index: Nat;
    };

    public type TokenEventRecordResp = {
        caller: AID.Address;
        op: Text;
        from: AID.Address;
        to: AID.Address;
        amount: Nat64;
        fee: Nat64;
        timestamp: Time.Time;
        index: Nat;
    };
};