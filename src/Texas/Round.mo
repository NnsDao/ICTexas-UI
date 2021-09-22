import Time "mo:base/Time";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import AID "./Utils/AccountId";
import Action "./Action";
import AccountStatus "./AccountStatus";
import RoundType "./RoundType";

module {

    // just give (status query, can action do, status change) interface
    public class Round(_roundType_ : RoundType.RoundType, _accounts_: [AID.Address], _accountsStatus_ : HashMap.HashMap<AID.Address, AccountStatus.AccountStatus>, _smallBlind_ : Nat, _smallBlindAccount_ : Nat, _actionSeqStart_ : Nat16) {
        private let _accounts = _accounts_;
        private let _accountsStatus = _accountsStatus_;
        private let _smallBlind = _smallBlind_;
        private let _smallBlindAccount = _smallBlindAccount_;
        private let _roundType = _roundType_;
        private var _actionAccount = _smallBlindAccount; // current action account
        private var _actionSeq = _actionSeqStart_; // current action seq
        private var _actionTime = Time.now(); // current action start time
        private let _actionInterval : Int = 45 * 1_000_000_000; // action interval then timeout
        private var _betAccount : ?Nat = null; // the first bet account
        private var _bet : Nat = 0; // current bet of round
        private var _raise : Nat = 2*_smallBlind; // next raise must more than last raise
        private let _accountsBet = HashMap.HashMap<AID.Address, Nat>(1, AID.equal, AID.hash); // accounts actions in a round
        private let _accountsActions = HashMap.HashMap<AID.Address, [Action.Action]>(1, AID.equal, AID.hash); // accounts actions in a round

        for (account in _accounts.vals()) {
            _accountsBet.put(account, 0);
            _accountsActions.put(account, []);
        };

        private func accountAddBet(address : AID.Address, bet : Nat) {
            _accountsBet.put(address, Option.unwrap(_accountsBet.get(address))+bet);
        };

        public func getCurrentActionSeq() : Nat16 {
            return _actionSeq;
        };

        public func getRoundType() : RoundType.RoundType {
            return _roundType;
        };

        public func getActionUserInfo() : (AID.Address, Time.Time, Time.Time, Nat16) {
            return (_accounts[_actionAccount], _actionTime, _actionTime+_actionInterval, _actionSeq);
        };

        public func getTotalBets() : Nat {
            var totalBets = 0;
            for ((_, bets) in _accountsBet.entries()) {totalBets+=bets;};
            return totalBets;
        };

        public func accountBet(address : AID.Address) : Nat {
            return Option.unwrap(_accountsBet.get(address));
        };

        private func accountAppendAction(address : AID.Address, action : Action.Action) {
            _accountsActions.put(address, Array.append(Option.unwrap(_accountsActions.get(address)), [action]));
        };

        public func accountActions(address : AID.Address) : [Action.Action] {
            return Option.unwrap(_accountsActions.get(address));
        };

        public func start() {
            if (_roundType == #preflop) {
                _actionAccount := (_smallBlindAccount+2)%_accounts.size();
                _actionTime := Time.now();
                _betAccount := ?((_smallBlindAccount+1)%_accounts.size());
                _bet := 2*_smallBlind;
                _raise := 2*_smallBlind;
                accountAddBet(_accounts[_smallBlindAccount], _smallBlind);
                accountAppendAction(_accounts[_smallBlindAccount], #smallblind(_smallBlind));
                accountAddBet(_accounts[(_smallBlindAccount+1)%_accounts.size()], 2*_smallBlind);
                accountAppendAction(_accounts[(_smallBlindAccount+1)%_accounts.size()], #bigblind(2*_smallBlind));
            };
            if (not isRoundEnd()) {
                label locate loop {
                    let accountStatus = Option.unwrap(_accountsStatus.get(_accounts[_actionAccount])); 
                    if (accountStatus.isAllIn() or accountStatus.isFold()) { 
                        _actionAccount := (_actionAccount+1)%_accounts.size();
                        _actionTime := Time.now();
                        _actionSeq := _actionSeq+1;
                        continue locate; 
                    };
                    if ((not accountStatus.isOnline()) and (not isOnlyOneLive())) { actionDone(_accounts[_actionAccount], #fold(0)); };
                    break locate;
                };
            }
        };

        public func checkActionTimeOut() : Bool {
            if (Time.now() - _actionTime <= _actionInterval) { return false; };
            actionDone(_accounts[_actionAccount], #fold(0));
            return true;
        };

        public func actionCan() : [Action.Action] {
            let accountStatus = Option.unwrap(_accountsStatus.get(_accounts[_actionAccount])); 
            if (accountStatus.isAllIn()) {return []};
            if (accountStatus.isFold()) {return []};
            var actions : [Action.Action] = [];
            if (Option.isNull(_betAccount)) {return [#bet(2*_smallBlind), #allin(0), #fold(0), #check(0)];};
            let historyActions = accountActions(_accounts[_actionAccount]);
            let callAmount = Nat.sub(_bet,accountBet(_accounts[_actionAccount]));
            let raiseAmount = Nat.sub(_bet+_raise,accountBet(_accounts[_actionAccount]));
            if (historyActions.size() > 0) {
                let lastAction = historyActions[Nat.sub(historyActions.size(), 1)];
                if (Action.isCall(lastAction) or Action.isRaise(lastAction)) { return [#call(callAmount), #allin(callAmount), #fold(0)]; };
            };
            return [#call(callAmount), #raise(raiseAmount), #allin(0), #fold(0)];
        };

        public func canAction(address : AID.Address, action : Action.Action, actionSeq : Nat16) : (Bool, Text) {
            if (address != _accounts[_actionAccount]) { if ((not checkActionTimeOut()) or address != _accounts[_actionAccount]) {return (false, "not you turn");}};
            if (_actionSeq != actionSeq) { return (false, "action seq is error");};
            if (checkActionTimeOut()) { return (false, "action is timeout"); };
            let accountStatus = Option.unwrap(_accountsStatus.get(address)); 
            if (accountStatus.isAllIn() or accountStatus.isFold()) { return (false, "you can not action"); };
            switch action {
                case (#check(n)) {
                    if (Option.isSome(_betAccount)) { return (false, "check action not allowed now"); };
                };
                case (#bet(n)) {
                    if (Option.isSome(_betAccount)) { return (false, "bet action not allowed now"); };
                    if (n < _raise) { return (false, "bet amount is small"); };
                };
                case (#call(n)) {
                    if (Option.isNull(_betAccount)) { return (false, "call action not allowed now"); };
                    if (n + accountBet(address) != _bet) { return (false, "call amount must bet " # Nat.toText(Nat.sub(_bet, accountBet(address)))); };
                };
                case (#raise(n)) {
                    if (Option.isNull(_betAccount)) { return (false, "raise action not allowed now"); };
                    if (n + accountBet(address) < _bet + _raise) { return (false, "raise amount must more than" # Nat.toText(Nat.sub(_bet + _raise, accountBet(address)))); };
                    let historyActions = accountActions(address);
                    if (historyActions.size() > 0) {
                        let lastAction = historyActions[Nat.sub(historyActions.size(), 1)];
                        if (Action.isCall(lastAction) or Action.isRaise(lastAction)) { return (false, "raise action not allowed now"); };
                    };
                };
                case (#allin(n)) {
                    let historyActions = accountActions(address);
                    if (historyActions.size() > 0) {
                        let lastAction = historyActions[Nat.sub(historyActions.size(), 1)];
                        if (Action.isCall(lastAction) or Action.isRaise(lastAction)) { 
                            if (n + accountBet(address) > _bet) {
                                return (false, "allin action not allowed now"); 
                            };
                        };
                    };
                };
                case (#fold(n)) {
                    ();
                };
                case _ { return (false, "unsupport action"); };
            };
            return (true, "");
        };

        // notic allin action must set to the true amount balance
        public func actionDone(address : AID.Address, action : Action.Action) {
            if (address != _accounts[_actionAccount]) { return; };
            accountAppendAction(address, Action.standardAction(action));
            accountAddBet(address, Action.amountOf(action));
            if (Action.amountOf(action) != 0) {
                if (_bet == 0) {
                    _betAccount := ?_actionAccount;
                    _bet := accountBet(address);
                    _raise := _bet;
                } else {
                    if (accountBet(address) >= _bet + _raise) {
                         _raise := accountBet(address) - _bet;
                        _bet := accountBet(address);
                    };
                };
            };
            let accountStatus = Option.unwrap(_accountsStatus.get(address));
            if (Action.isAllIn(action)) { accountStatus.setAllIn()}
            else if (Action.isFold(action)) { accountStatus.setFold()};
            if (not isRoundEnd()) {
                label locate loop {
                    _actionAccount := (_actionAccount+1)%_accounts.size();
                    _actionTime := Time.now();
                    _actionSeq := _actionSeq+1;
                    let accountStatus = Option.unwrap(_accountsStatus.get(_accounts[_actionAccount])); 
                    if (accountStatus.isAllIn() or accountStatus.isFold()) { continue locate; };
                    if ((not accountStatus.isOnline()) and (not isOnlyOneLive())) { actionDone(_accounts[_actionAccount], #fold(0)); };
                    break locate;
                };
            } else {
                _actionAccount := (_actionAccount+1)%_accounts.size();
                _actionTime := Time.now();
                _actionSeq := _actionSeq+1;
            };
        };

        public func isOnlyOneLive() : Bool {
            var liveCount = 0;
            for (account in _accounts.vals()) {
                let accountStatus = Option.unwrap(_accountsStatus.get(account));
                if (not accountStatus.isFold()) { liveCount+=1; };
            };
            return liveCount < 2;
        };

        public func isRoundEnd() : Bool {
            if (_bet != 0) {
                var roundEnd = true;
                label allbet for (account in _accounts.vals()) {
                    let accountStatus = Option.unwrap(_accountsStatus.get(account));
                    if (accountStatus.isAllIn() or accountStatus.isFold()) { continue allbet; };
                    if (accountBet(account) != _bet) {
                        roundEnd := false;
                        break allbet;
                    };
                };
                return roundEnd;
            };

            var canTalk = 0;
            for (account in _accounts.vals()) {
                let accountStatus = Option.unwrap(_accountsStatus.get(account));
                if ((not accountStatus.isFold()) and (not accountStatus.isAllIn())) { canTalk += 1; };
            };
            if (canTalk <= 1) { return true; };

            var roundEnd = true;
            label allcheck for (account in _accounts.vals()) {
                let accountStatus = Option.unwrap(_accountsStatus.get(account));
                if (accountStatus.isAllIn() or accountStatus.isFold()) { continue allcheck; };
                let accountActions = Option.unwrap(_accountsActions.get(account));
                if (accountActions.size() != 1) {
                    roundEnd := false;
                    break allcheck;
                };
                switch (accountActions[0]) {
                    case (#check(n)) {();};
                    case _ {
                        roundEnd := false;
                        break allcheck;
                    };
                };
            };
            return roundEnd;
        };
    };
};