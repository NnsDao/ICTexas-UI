import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat64 "mo:base/Nat64";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import AID "../Utils/AccountId";
import TokenOperation "../Token/TokenOperation";
import TokenEventRecord "./TokenEventRecord";

shared(msg) actor class TokenEvent() {

    private stable let _createTime = Time.now();
    private stable var _owner : Principal = msg.caller;
    private stable var _tokenCanisterId : ?Principal = ?Principal.fromText("yioai-dqaaa-aaaal-aaaiq-cai");
    private stable var _addresses : [AID.Address] = [];
    private stable var _tokenEvents : [TokenEventRecord.TokenEventRecord] = [];
    private stable var _tokenEventsMapEntries : [(AID.Address, (Int, [Nat]))] = [];
    private var _tokenEventsMap = HashMap.HashMap<AID.Address, (Int, [Nat])>(1, AID.equal, AID.hash);

    private func _transformTokenEventRecordToResp(e : TokenEventRecord.TokenEventRecord) : TokenEventRecord.TokenEventRecordResp {
        func transformAddressIndexToAddress(index : Int) : Text {
            if (index < 0 or index >= _addresses.size()) { return ""; };
            return _addresses[Nat64.toNat(Nat64.fromIntWrap(index))];
        };

        return {
            caller = transformAddressIndexToAddress(e.caller);
            op = TokenOperation.tokenOperationToText(TokenOperation.tokenOperationFromNat8(e.op));
            from = transformAddressIndexToAddress(e.from);
            to = transformAddressIndexToAddress(e.to);
            amount = e.amount;
            fee = e.fee;
            timestamp = e.timestamp;
            index = e.index;
        };
    };

    private func _getIndexAndTransactionsOfAccountOrRegister(address : AID.Address) : (Int, [Nat]) {
        if (address == "") { return (-1, []); };
        let e = _tokenEventsMap.get(address);
        if (Option.isSome(e)) { return Option.unwrap(e); };
        let index : Int = _addresses.size();
        _addresses := Array.append(_addresses, [address]);
        return (index, []);
    };

    public shared(msg) func setOwner(_owner_ : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        _owner := Principal.fromText(_owner_);
        return true;
    };

    public shared(msg) func setTokenCanister(canister : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        _tokenCanisterId := ?Principal.fromText(canister);
        return true;
    };

    public shared(msg) func handleTokenEvent(caller: AID.Address, op: TokenOperation.TokenOperation, from: AID.Address, to: AID.Address, amount: Nat64, fee: Nat64, timestamp: Time.Time) : async Bool {
        if (Option.isNull(_tokenCanisterId)) { return false; };
        if (Option.unwrap(_tokenCanisterId) != msg.caller) { return false; };
        if (caller == "") { return false; };

        let (callerIndex, callerHistory) = _getIndexAndTransactionsOfAccountOrRegister(caller);
        let (fromIndex, fromHistory) = _getIndexAndTransactionsOfAccountOrRegister(from);
        let (toIndex, toHistory) = _getIndexAndTransactionsOfAccountOrRegister(to);
        let tokenOpIndex = TokenOperation.tokenOperationToNat8(op);
        let tokenEventIndex = _tokenEvents.size();
        let tokenEvent : TokenEventRecord.TokenEventRecord = {
            caller = callerIndex;
            op = tokenOpIndex;
            from = fromIndex;
            to = toIndex;
            amount = amount;
            fee = fee;
            timestamp = timestamp;
            index = tokenEventIndex;
        };
        _tokenEvents := Array.append(_tokenEvents, [tokenEvent]);
        _tokenEventsMap.put(caller, (callerIndex, Array.append(callerHistory, [tokenEventIndex])));
        if (from != "") {_tokenEventsMap.put(from, (fromIndex, Array.append(fromHistory, [tokenEventIndex]))); };
        if (to != "") {_tokenEventsMap.put(to, (toIndex, Array.append(toHistory, [tokenEventIndex]))); };
        return true;
    };

    public func acceptCycles() : async Nat {
        return ExperimentalCycles.accept(ExperimentalCycles.available());
    };
    
    public query func createTime() : async Time.Time {
        return _createTime;
    };

    public query func owner() : async Principal {
        return _owner;
    };

    public query func tokenCanisterId() : async ?Principal {
        return _tokenCanisterId;
    };

    public query func txAmount() : async Nat {
        return _tokenEvents.size();
    };

    public query func getTransactionByTx(index: Nat) : async ?TokenEventRecord.TokenEventRecordResp {
        if (index >= _tokenEvents.size()) return null;
        return ?_transformTokenEventRecordToResp(_tokenEvents[index]);
    };

    public query func getTransactionsOf(a: AID.Address) : async [TokenEventRecord.TokenEventRecordResp] {
        let e = _tokenEventsMap.get(a);
        if (Option.isNull(e)) { return []; };
        let (_, txs) = Option.unwrap(e);
        var result : [TokenEventRecord.TokenEventRecordResp] = [];
        for (tx in txs.vals()) {
            result := Array.append(result, [_transformTokenEventRecordToResp(_tokenEvents[tx])]);
        };
        result;
    };

    public query(msg) func getAllTransactions() : async [TokenEventRecord.TokenEventRecordResp] {
        if (msg.caller != _owner) { return []; };
        var result : [TokenEventRecord.TokenEventRecordResp] = [];
        for (e in _tokenEvents.vals()) {
            result := Array.append(result, [_transformTokenEventRecordToResp(e)]);
        };
        return result;
    };

    public query func getCycles() : async Nat {
        return ExperimentalCycles.balance();
    };

    system func preupgrade() {
        _tokenEventsMapEntries := Iter.toArray(_tokenEventsMap.entries());
    };

    system func postupgrade() {
        _tokenEventsMap := HashMap.fromIter<AID.Address, (Int, [Nat])>(_tokenEventsMapEntries.vals(), 1, AID.equal, AID.hash);
    };

}