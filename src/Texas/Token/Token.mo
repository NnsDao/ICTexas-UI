import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Float "mo:base/Float";
import Int64 "mo:base/Int64";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import AID "../Utils/AccountId";
import TokenOperation "./TokenOperation";
import TokenEvent "./TokenEvent";

shared(msg) actor class Token() {

    public type TokenMetaData = {
        name : Text;
        symbol : Text;
        decimal : Nat8;
        features : [Text];
    };
    public type UserBalance = (account: AID.Address, balance: Nat64);
    public type Allowance = (spender: AID.Address, amount: Nat64);
    public type UserAllowances = (account: AID.Address, allowances: [Allowance]);

    private stable var _tokenEventHandlers : [TokenEvent.TokenEventHandler] = [];
    private stable let _createTime : Time.Time = Time.now();
    private stable var _owner : Principal = msg.caller;
    private stable var _name : Text = "GameFi Token Test";
    private stable var _symbol : Text = "GFTT";
    private stable var _decimals : Nat64 = 8;
    private stable var _totalSupply : Nat64 = 30_000_000_000 * Nat64.pow(10, _decimals);
    private stable var _feePercent : Float = 0;
    private stable var _totalMint : Nat64 = 0;
    private stable var _mintCount : Nat64 = 1000 * Nat64.pow(10, _decimals);
    private stable var _mintMaxNum : Nat = 10;
    private stable var _lastMintTime : Time.Time = Time.now();
    private stable var _minMintIntervalGlobal : Time.Time = 3 * 1_000_000_000;
    private stable var _minMintIntervalAccount : Time.Time = 24 * 60 * 60 * 1_000_000_000;
    private stable var _mintCheckInterval : Int = 4 * 60 * 60 * 1_000_000_000;
    private stable var _lastMintCheckTime : Time.Time = Time.now();
    private stable var _mintEntries : [(AID.Address, (Time.Time, Nat))] = [];
    private stable var _balanceEntries : [(AID.Address, Nat64)] = [];
    private stable var _allowanceEntries : [(AID.Address, [(AID.Address, Nat64)])] = [];
    private stable var _chargeFeeFromWhiteListEntries : [(AID.Address, ())] = [];
    private stable var _chargeFeeToWhiteListEntries : [(AID.Address, ())] = [];
    private var _mints = HashMap.HashMap<AID.Address, (Time.Time, Nat)>(1, AID.equal, AID.hash);
    private var _balances = HashMap.HashMap<AID.Address, Nat64>(1, AID.equal, AID.hash);
    private var _allowances = HashMap.HashMap<AID.Address, HashMap.HashMap<AID.Address, Nat64>>(1, AID.equal, AID.hash);
    private var _chargeFeeFromWhiteList = HashMap.HashMap<AID.Address, ()>(1, AID.equal, AID.hash);
    private var _chargeFeeToWhiteList = HashMap.HashMap<AID.Address, ()>(1, AID.equal, AID.hash);

    private func _balanceOf(who: AID.Address) : Nat64 {
        let b = _balances.get(who);
        if (Option.isNull(b)) { return 0; };
        return Option.unwrap(b);
    };

    private func _allowanceOf(owner: AID.Address, spender: AID.Address) : Nat64 {
        let allowed = _allowances.get(owner);
        if (Option.isNull(allowed)) { return 0; };
        let allowance = Option.unwrap(allowed).get(spender);
        if (Option.isNull(allowance)) { return 0; };
        return Option.unwrap(allowance);
    };

    private func _transfer(from: AID.Address, to: AID.Address, value: Nat64) {
        if (from == to) { return; };
        let fromBalance = _balanceOf(from);
        if (value == 0 or fromBalance < value) { return; };
        let fromBalanceNew : Nat64 = fromBalance - value;
        let toBalance = _balanceOf(to);
        let toBalanceNew : Nat64 = toBalance + value;
        if (fromBalanceNew == 0) { _balances.delete(from); } 
        else { _balances.put(from, fromBalanceNew); };
        _balances.put(to, toBalanceNew);
    };

    private func _calChargeFee(from: AID.Address, to: AID.Address, value: Nat64) : Nat64 {
        if (Option.isSome(_chargeFeeFromWhiteList.get(from)) or Option.isSome(_chargeFeeToWhiteList.get(to))) { return 0; };
        let ownerAddrees = AID.fromPrincipal(_owner, null);
        if (from == ownerAddrees or to == ownerAddrees) { return 0; };
        return Int64.toNat64(Float.toInt64(Float.fromInt64(Int64.fromNat64(value))*_feePercent))
    };

    private func _chargeFee(from: AID.Address, fee: Nat64) {
        _transfer(from, AID.fromPrincipal(_owner, null), fee);
    };

    private func _checkMints() {
        if (Time.now() - _lastMintCheckTime < _mintCheckInterval ) { return; };
        var deleteMints : [AID.Address] = [];
        for ((k, v) in _mints.entries()) {
            if (Time.now() - v.0 > _minMintIntervalAccount) {deleteMints := Array.append(deleteMints, [k]);};
        };
        for (k in deleteMints.vals()) { _mints.delete(k); };
        _lastMintCheckTime := Time.now();
    };

    private func _event(caller: AID.Address, op: TokenOperation.TokenOperation, from: AID.Address, to: AID.Address, amount: Nat64, fee: Nat64) : async () {
        for (handler in _tokenEventHandlers.vals()) {
            ignore handler.handleTokenEvent(caller, op, from, to, amount, fee, Time.now());
        };
    };

    public shared(msg) func setOwner(_owner_ : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (_owner_ == "") { return false; };
        _owner := Principal.fromText(_owner_);
        return true;
    };

    public shared(msg) func setFeePercent(_feePercent_ : Float) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (_feePercent_ < 0 or _feePercent_ > 1) { return false; }; 
        _feePercent := _feePercent_;
        return true;
    };

    public shared(msg) func subscribeTokenEventHandler(canister : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (canister == "") { return false; };
        _tokenEventHandlers := Array.append<TokenEvent.TokenEventHandler>(_tokenEventHandlers, [actor(canister)]);
        return true;
    };

    public shared(msg) func unsubscribeTokenEventHandler(canister : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (canister == "") { return false; };
        func tokenEventHandlerFilter(a : actor{}) : Bool {
          if (Principal.toText(Principal.fromActor(a)) == canister) {return false;};
          return true;
        };
        _tokenEventHandlers := Array.filter(_tokenEventHandlers, tokenEventHandlerFilter);
        return true;
    };

    public shared(msg) func setChargeFeeFromWhiteList(address : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (address == "") { return false; };
        _chargeFeeFromWhiteList.put(address, ());
        return true;
    };

    public shared(msg) func setChargeFeeToWhiteList(address : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (address == "") { return false; };
        _chargeFeeToWhiteList.put(address, ());
        return true;
    };

    public shared(msg) func transfer(to: AID.Address, value: Nat64) : async Bool {
        if (not AID.valid(to)) { return false; };
        let from = AID.fromPrincipal(msg.caller, null);
        let fee = _calChargeFee(from, to, value);
        if (_balanceOf(from) < value) { return false; };
        if (value < fee) { return false; };
        _chargeFee(from, fee);
        _transfer(from, to, value - fee);
        ignore _event(from, #transfer, from, to, value, fee);
        return true;
    };

    public shared(msg) func send(to: AID.Address, value: Nat64) : async Bool {
        if (not AID.valid(to)) { return false; };
        let from = AID.fromPrincipal(msg.caller, null);
        let fee = _calChargeFee(from, to, value);
        if (_balanceOf(from) < value) { return false; };
        if (value < fee) { return false; };
        _chargeFee(from, fee);
        _transfer(from, to, value - fee);
        ignore _event(from, #transfer, from, to, value, fee);
        return true;
    };

    public shared(msg) func transferFrom(from: AID.Address, to: AID.Address, value: Nat64) : async Bool {
        if (not AID.valid(from) or not AID.valid(to)) { return false; };
        let spender = AID.fromPrincipal(msg.caller, null);
        let allowed : Nat64 = _allowanceOf(from, spender);
        if (allowed == 0) { return false; };
        if (allowed < value) { return false; };
        let fee = _calChargeFee(from, to, value);
        if (_balanceOf(from) < value) { return false; };
        if (value < fee) { return false; };
        _chargeFee(from, fee);
        _transfer(from, to, value - fee);
        let allowedNew : Nat64 = allowed - value;
        let allowanceFrom = Option.unwrap(_allowances.get(from));
        if (allowedNew != 0) {
            allowanceFrom.put(spender, allowedNew);
            _allowances.put(from, allowanceFrom);
        } else {
            allowanceFrom.delete(spender);
            if (allowanceFrom.size() == 0) { _allowances.delete(from); }
            else { _allowances.put(from, allowanceFrom); };
        };
        ignore _event(spender, #transfer, from, to, value, fee);
        return true;
    };

    public shared(msg) func approve(spender: AID.Address, value: Nat64) : async Bool {
        if (not AID.valid(spender)) { return false; };
        let from = AID.fromPrincipal(msg.caller, null);
        let allowed = _allowances.get(from);
        if (value == 0 and Option.isNull(allowed)) { return true; };
        if (value == 0 and Option.isSome(allowed)) {
            let allowanceFrom = Option.unwrap(allowed);
            allowanceFrom.delete(spender);
            if (allowanceFrom.size() == 0) { _allowances.delete(from); }
            else { _allowances.put(from, allowanceFrom); };
        } else if (value != 0 and Option.isSome(allowed)) {
            let allowanceFrom = Option.unwrap(allowed);
            allowanceFrom.put(spender, value);
            _allowances.put(from, allowanceFrom);
        } else if (value != 0 and Option.isNull(allowed)) {
            var temp = HashMap.HashMap<AID.Address, Nat64>(1, AID.equal, AID.hash);
            temp.put(spender, value);
            _allowances.put(from, temp);
        };
        ignore _event(from, #approve, from, spender, value, 0);
        return true; 
    };

    public shared(msg) func burn(from: AID.Address, value: Nat64): async Bool {
        if (not AID.valid(from)) { return false; };
        if (msg.caller != _owner and AID.fromPrincipal(msg.caller, null) != from) { return false };
        if (value == 0) { return false; };
        let balance = _balanceOf(from);
        if (balance == 0) { return false; };
        var needBurn = value;
        if (balance < value) { needBurn := balance; };
        _totalSupply -= needBurn;
        _totalMint -= needBurn;
        let newBalance = balance - needBurn;
        if (newBalance != 0 ) { _balances.put(from, newBalance); }
        else { _balances.delete(from); };
        ignore _event(AID.fromPrincipal(msg.caller, null), #burn, from, "", needBurn, 0);
        return true;
    };

    public shared(msg) func mint(): async Bool {
        _checkMints();
        if (_totalSupply <= _totalMint) { return false; };
        if (Time.now() - _lastMintTime <= _minMintIntervalGlobal) { return false; };
        let from = AID.fromPrincipal(msg.caller, null);
        if (_balanceOf(from) >= _mintCount) { return false; };
        let lastMintOp = _mints.get(from);
        if (Option.isSome(lastMintOp)) {
            let lastMint= Option.unwrap(lastMintOp);
            if (Time.now() - lastMint.0 > _minMintIntervalAccount) {_mints.put(from, (Time.now(), 1));}
            else {
                if (lastMint.1 >= _mintMaxNum) {return false;}
                else { _mints.put(from, (lastMint.0, lastMint.1+1));};
            };
        } else {_mints.put(from, (Time.now(), 1));};
        var mintCount = _mintCount;
        if (_totalSupply - _totalMint < mintCount) { mintCount := _totalSupply - _totalMint; };
        _lastMintTime := Time.now(); 
        _totalMint += mintCount;
        _balances.put(from, _balanceOf(from) + mintCount);
        ignore _event(from, #mint, "", from, mintCount, 0);
        return true;
    };

    public shared(msg) func endMint(): async Bool {
        if (msg.caller != _owner) { return false };
        _totalSupply := _totalMint;
        return true;
    };

    public func acceptCycles() : async Nat {
        return ExperimentalCycles.accept(ExperimentalCycles.available());
    };

    public query(msg) func addressOf(principal : Text) : async AID.Address {
        if (principal == "") { return AID.fromPrincipal(msg.caller, null) };
        return AID.fromPrincipal(Principal.fromText(principal), null);
    };

    public query func tokenEventHandlers() : async [Text] {
        func tokenEventHandlerMap(a : actor{}) : Text {
          return Principal.toText(Principal.fromActor(a));
        };
        Array.map<TokenEvent.TokenEventHandler, Text>(_tokenEventHandlers, tokenEventHandlerMap);
    };

    public query func createTime() : async Time.Time {
        return _createTime;
    };

    public query func owner() : async Principal {
        return _owner;
    };

    public query func name() : async Text {
        return _name;
    };

    public query func decimals() : async Nat8 {
        return Nat8.fromNat(Nat64.toNat(_decimals));
    };

    public query func symbol() : async Text {
        return _symbol;
    };

    public query func totalSupply() : async Nat64 {
        return _totalSupply;
    };

    public query func getFeePercent() : async Float {
        return _feePercent;
    };

    public query func totalMint() : async Nat64 {
        return _totalMint;
    };

    public query func mintCount() : async Nat {
        return _mints.size();
    };

    public query func lastMintTime() : async Time.Time {
        return _lastMintTime;
    };

    public query(msg) func lastMintDetailOf(who: AID.Address) : async (Time.Time, Nat) {
        var vwho = who;
        if (vwho == "") { vwho := AID.fromPrincipal(msg.caller, null) };
        if (not AID.valid(vwho)) { return (0, 0); };
        let lastMint = _mints.get(vwho);
        if (Option.isNull(lastMint)) { return (0, 0);};
        return Option.unwrap(lastMint);
    };

    public query func addressCount() : async Nat {
        return _balances.size();
    };

    public query func totalUsers() : async Nat {
        return _balances.size();
    };

    public query(msg) func balanceOf(who: AID.Address) : async Nat64 {
        var vwho = who;
        if (vwho == "") { vwho := AID.fromPrincipal(msg.caller, null) };
        if (not AID.valid(vwho)) { return 0; };
        return _balanceOf(vwho);
    };

    public query func balancesOf(whos: [AID.Address]) : async [Nat64] {
        var balances : [Nat64] = [];
        for (who in whos.vals()) {
            var balance : Nat64 = 0;
            if (AID.valid(who)) { balance := _balanceOf(who); };
            balances := Array.append(balances, [balance]);
        };
        return balances;
    };

    public query(msg) func balances() : async [UserBalance] {
        if (msg.caller != _owner) { return [] };
        return Iter.toArray<UserBalance>(_balances.entries());
    };

    public query func allowance(owner: AID.Address, spender: AID.Address) : async Nat64 {
        if (not AID.valid(owner) or not AID.valid(spender)) { return 0; };
        return _allowanceOf(owner, spender);
    };

    public query func allowanceOf(owner: AID.Address, spender: AID.Address) : async Nat64 {
        if (not AID.valid(owner) or not AID.valid(spender)) { return 0; };
        return _allowanceOf(owner, spender);
    };

    public query(msg) func allowancesOf(who : AID.Address) : async [Allowance] {
        var vwho = who;
        if (vwho == "") { vwho := AID.fromPrincipal(msg.caller, null) };
        if (not AID.valid(vwho)) { return []; };
        var size : Nat = 0;
        if (Option.isSome(_allowances.get(vwho))) { Iter.toArray<Allowance>(Option.unwrap(_allowances.get(vwho)).entries()); }
        else { []; };
    };

    public query(msg) func allowances() : async [UserAllowances] {
        if (msg.caller != _owner) { return [] };
        var size : Nat = _allowances.size();
        var res : [var UserAllowances] = Array.init<UserAllowances>(size, (AID.fromPrincipal(_owner, null), []));
        size := 0;
        for ((k, v) in _allowances.entries()) {
            res[size] := (k, Iter.toArray<Allowance>(v.entries()));
            size += 1;
        };
        return Array.freeze(res);
    };

    private func _chargeFeeWhiteListMap(a : (AID.Address, ())) : Text {
        return a.0;
    };

    public query func getChargeFeeFromWhiteList() : async [Text] {
        return Array.map<(AID.Address, ()), Text>(Iter.toArray(_chargeFeeFromWhiteList.entries()), _chargeFeeWhiteListMap);
    };

    public query func getChargeFeeToWhiteList() : async [Text] {
        return Array.map<(AID.Address, ()), Text>(Iter.toArray(_chargeFeeToWhiteList.entries()), _chargeFeeWhiteListMap);
    };

    public query func tokenEventLoggerCanisterIDS() : async [Principal] {
        return Array.map<actor{}, Principal>(_tokenEventHandlers, func(a:actor{}):Principal{Principal.fromActor(a);});
    };

    public query func meta() : async TokenMetaData {
        return {
            name = _name;
            symbol = _symbol;
            decimal = Nat8.fromNat(Nat64.toNat(_decimals));
            features: [Text] = [];
        };
    };

    public query func metadata() : async TokenMetaData {
        return {
            name = _name;
            symbol = _symbol;
            decimal = Nat8.fromNat(Nat64.toNat(_decimals));
            features: [Text] = [];
        };
    };

    public query func getCycles() : async Nat {
        return ExperimentalCycles.balance();
    };

    system func preupgrade() {
        _chargeFeeFromWhiteListEntries := Iter.toArray(_chargeFeeFromWhiteList.entries());
        _chargeFeeToWhiteListEntries := Iter.toArray(_chargeFeeToWhiteList.entries());
        _mintEntries := Iter.toArray(_mints.entries());
        _balanceEntries := Iter.toArray(_balances.entries());
        var size : Nat = _allowances.size();
        var temp : [var (AID.Address, [(AID.Address, Nat64)])] = Array.init<(AID.Address, [(AID.Address, Nat64)])>(size, (AID.fromPrincipal(_owner, null), []));
        size := 0;
        for ((k, v) in _allowances.entries()) {
            temp[size] := (k, Iter.toArray(v.entries()));
            size += 1;
        };
        _allowanceEntries := Array.freeze(temp);
    };

    system func postupgrade() {
        _chargeFeeFromWhiteList := HashMap.fromIter<AID.Address, ()>(_chargeFeeFromWhiteListEntries.vals(), 1, AID.equal, AID.hash);
        _chargeFeeFromWhiteListEntries := [];
        _chargeFeeToWhiteList := HashMap.fromIter<AID.Address, ()>(_chargeFeeToWhiteListEntries.vals(), 1, AID.equal, AID.hash);
        _chargeFeeToWhiteListEntries := [];
        _mints := HashMap.fromIter<AID.Address, (Time.Time, Nat)>(_mintEntries.vals(), 1, AID.equal, AID.hash);
        _mintEntries := [];
        _balances := HashMap.fromIter<AID.Address, Nat64>(_balanceEntries.vals(), 1, AID.equal, AID.hash);
        _balanceEntries := [];
        for ((k, v) in _allowanceEntries.vals()) {
            _allowances.put(k, HashMap.fromIter<AID.Address, Nat64>(v.vals(), 1, AID.equal, AID.hash));
        };
        _allowanceEntries := [];
    };
};