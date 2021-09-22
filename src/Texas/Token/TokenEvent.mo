import Time "mo:base/Time";
import AID "../Utils/AccountId";
import TokenOperation "./TokenOperation";

module {

    public type TokenEventHandler = actor {
        handleTokenEvent : (caller: AID.Address, op: TokenOperation.TokenOperation, from: AID.Address, to: AID.Address, amount: Nat64, fee: Nat64, timestamp: Time.Time) -> async Bool;
    };
};