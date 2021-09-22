import Array "mo:base/Array";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import AID "./Utils/AccountId";
import Game "./Game";
import Action "./Action";
import SiteType "./SiteType";
import Status "./Status";
import Reward "./Reward";
import GameEvent "./GameEvent";

module {

    private class UserStatus() {
        private var _isReady : Bool = false;
        private var _sitdownTime : Time.Time = Time.now();
        private var _lastSpeak : Text = "";
        private var _lastSpeakIndex : Nat = 0;

        public func setReady() {_isReady := true};
        public func isReady() : Bool {return _isReady;};
        public func sitdownTime() : Time.Time {return _sitdownTime;};
        public func lastSpeak() : Text {return _lastSpeak;};
        public func lastSpeakIndex() : Nat {return _lastSpeakIndex;};
        public func setSpeak(speak: Text) {
            _lastSpeak := speak;
            _lastSpeakIndex := _lastSpeakIndex+1;
        };
        public func reset() {
            _isReady := false;
            _sitdownTime := Time.now();
        };
    };

    public class Table(_siteType_ : SiteType.SiteType, _tableNumber_ : Nat) {

        private let _tableMinUser = 2;
        private let _tableMaxUser = 10;
        private let _userReadyMinTime = 60 * 1_000_000_000;
        private let _tableNumber = _tableNumber_;
        private let _siteType = _siteType_;
        private let _seatAccounts: [var ?AID.Address] = Array.init(_tableMaxUser, null);
        private var _inSeatUserCount = 0;
        private var _seats = HashMap.HashMap<AID.Address, UserStatus>(1, AID.equal, AID.hash);
        private var _gameStarting = false;
        private var _game : ?Game.Game = null;
        private var _lastGameRewards : [Reward.RewardDetail]= [];
        private var _userActioning = false;
        private var _gameSettlementing = false;

        public func tableNumber() : Nat {
            return _tableNumber;
        };

        public func tableSiteType() : SiteType.SiteType {
            return _siteType;
        };

        public func setUserSpeak(address: AID.Address, speak: Text) {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return;};
            Option.unwrap(userStatus).setSpeak(speak);
        };

        public func userLastSpeak(address: AID.Address) : Text {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return "";};
            return Option.unwrap(userStatus).lastSpeak();
        };

        public func userLastSpeakIndex(address: AID.Address) : Nat {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return 0;};
            return Option.unwrap(userStatus).lastSpeakIndex();
        };

        public func canUserSitdown() : Bool {
            return  not isGameStartingOrStarted() and _inSeatUserCount < _tableMaxUser;
        };

        public func userSitdown(address: AID.Address) {
            label sitdown for (i in Iter.range(0, _tableMaxUser-1)) {
                if (Option.isNull(_seatAccounts[i])) {
                    _seatAccounts[i] := ?address;
                    _inSeatUserCount += 1;
                    _seats.put(address, UserStatus());
                    break sitdown;
                };
            };
        };

        public func isUserSitdown(address : AID.Address) : Bool {
            return Option.isSome(_seats.get(address));
        };

        public func userSitdownTime(address : AID.Address) : Time.Time {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return 0;};
            return Option.unwrap(userStatus).sitdownTime();
        };

        public func userReadyTimeBefore(address : AID.Address) : Time.Time {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return 0;};
            return Option.unwrap(userStatus).sitdownTime()+_userReadyMinTime;
        };

        public func sitdownUsers() : [AID.Address] {
            var accounts: [AID.Address] = [];
            for (i in Iter.range(0, _tableMaxUser-1)) {
                if (Option.isSome(_seatAccounts[i])) {
                    accounts := Array.append(accounts, [Option.unwrap(_seatAccounts[i])]);
                };
            };
            return accounts;
        };

        public func canUserGetUp(address : AID.Address) : Bool {
            if (_gameStarting or (Option.isSome(_game) and not Option.unwrap(_game).isUserFold(address))) {return false;};
            return true; 
        };

        public func userGetUp(address : AID.Address) {
            _seats.delete(address);
            label getup for (i in Iter.range(0, _tableMaxUser-1)) {
                if (Option.isSome(_seatAccounts[i]) and address == Option.unwrap(_seatAccounts[i])) {
                    _seatAccounts[i] := null;
                    _inSeatUserCount -= 1;
                    break getup;
                };
            };
        };

        public func canUserReadyPlay(address : AID.Address) : Bool {
            if (isGameStartingOrStarted()) {return false};
            if (not isUserSitdown(address)) {return false;};
            return true;
        };

        public func userReadyPlay(address : AID.Address) {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return;};
            Option.unwrap(userStatus).setReady();
        };

        public func isUserReadyPlay(address : AID.Address) : Bool {
            let userStatus = _seats.get(address);
            if (Option.isNull(userStatus)) {return false;};
            return Option.unwrap(userStatus).isReady();
        };

        public func canGameStart() : Bool {
            if (isGameStartingOrStarted()) {return false};
            if (_seats.size() < _tableMinUser) {return false;};
            for ((_, userStatus) in _seats.entries()) {if (not userStatus.isReady()) {return false;};};
             _gameStarting := true;
            return true;
        };

        public func gameStartFailed(invalidUser: AID.Address) {
            userGetUp(invalidUser);
            _gameStarting := false;
        };

        public func gameStartSuccess(smallblindIndex: Nat, smallBlind: Nat) {
            var seeds : [Time.Time] = [];
            for (opAccount in _seatAccounts.vals()) {if (Option.isSome(opAccount)) {seeds := Array.append<Time.Time>(seeds,[userSitdownTime(Option.unwrap(opAccount))]);};};
            _game := ?Game.Game(Array.freeze(_seatAccounts), sitdownUsers(), smallblindIndex, smallBlind, seeds);
            _gameStarting := false;
        };

        public func isGameStartingOrStarted() : Bool {
            return _gameStarting or isGameStarted();
        };

        public func isGameStarted() : Bool {
            return Option.isSome(_game);
        };

        public func gameStartTime() : Time.Time {
            return Option.unwrap(_game).startTime();
        };

        public func gameUsers() : [AID.Address] {
            return Option.unwrap(_game).gameUsers();
        };

        public func canUserAction(address : AID.Address, action : Action.Action, actionSeq : Nat16) : (Bool, Text) {
            if (not isGameStarted()) {return (false, "game is not start");};
            if (not isUserSitdown(address)) {return (false, "you are not in table");};
            if (_userActioning) {return (false, "some one in action");};
            let (canAction, result) = Option.unwrap(_game).canAction(address, action, actionSeq);
            if (not canAction) {return (false, result);};
            _userActioning := true;
            return (true, "");
        };

        public func userActionFailed(address : AID.Address, action : Action.Action) {
            _userActioning := false;
        };

        public func userActionSuccess(address : AID.Address, action : Action.Action) {
            Option.unwrap(_game).actionDone(address, action);
            _userActioning := false;
        };

        public func needGameOverSettlement() : Bool {
            if (not isGameStarted()) {return false;};
            if (_userActioning) {return false;};
            if (_gameSettlementing) {return false;};
            if (not Option.unwrap(_game).isGameEnd()) {return false;};
            _gameSettlementing := true;
            _lastGameRewards := Option.unwrap(_game).getRewards();
            return true;
        };

        public func gameOverSettlement() {
            _game := null;
            for (opAccount in _seatAccounts.vals()) {
                if (Option.isSome(opAccount)) {
                    Option.unwrap(_seats.get(Option.unwrap(opAccount))).reset();
                };
            };
            _gameSettlementing := false;
        }; 

        public func lastGameRewards() : [Reward.RewardDetail] {
            return _lastGameRewards;
        };

        public func userHeartBeat(address : AID.Address) {
            if (not isGameStarted()) {return;};
            Option.unwrap(_game).userHeartBeat(address, not _userActioning);
        };   

        public func status(user : AID.Address) : Status.TableStatus {
            if (_gameStarting) {return #instartgame(Array.freeze(_seatAccounts));};
            if (Option.isSome(_game)) {
                var userSpeaks : [?Status.UserSpeak] = [];
                for (opAccount in _seatAccounts.vals()) {
                    if (Option.isNull(opAccount)) {userSpeaks := Array.append<?Status.UserSpeak>(userSpeaks,[null]);}
                    else {
                        let account = Option.unwrap(opAccount); 
                        userSpeaks := Array.append<?Status.UserSpeak>(userSpeaks, [?{
                            lastSpeak=userLastSpeak(account);
                            lastSpeakIndex=userLastSpeakIndex(account);
                        }]);
                    };
                };
                return #ingame(Option.unwrap(_game).status(user, userSpeaks, _userActioning, _gameSettlementing));
            };
            var accountsInfo : [?Status.UserWaitingStatus] = [];
            for (opAccount in _seatAccounts.vals()) {
                if (Option.isNull(opAccount)) {accountsInfo := Array.append<?Status.UserWaitingStatus>(accountsInfo,[null]);}
                else {
                    let account = Option.unwrap(opAccount); 
                    accountsInfo := Array.append<?Status.UserWaitingStatus>(accountsInfo, [?{
                        account=account; 
                        isReady=isUserReadyPlay(account); 
                        sitdownAt=userSitdownTime(account)/1_000_000_000*1_000_000_000; 
                        needReadyBefore=userReadyTimeBefore(account)/1_000_000_000*1_000_000_000;
                        userSpeak = {
                            lastSpeak=userLastSpeak(account);
                            lastSpeakIndex=userLastSpeakIndex(account);
                        };
                    }]);
                };
            };
            return #waitinguser(accountsInfo)
        }; 

        public func removeReadyTimeoutUsers() : Bool {
            if (_inSeatUserCount == 0) {return false;};
            if (isGameStartingOrStarted()) {return false;};
            var hasRemoved = false;
            for (i in Iter.range(0, _tableMaxUser-1)) {
                if (Option.isSome(_seatAccounts[i])) {
                    let account = Option.unwrap(_seatAccounts[i]); 
                    let notReadyAndNotLive = (not Option.unwrap(_seats.get(account)).isReady()) and Time.now()-Option.unwrap(_seats.get(account)).sitdownTime() >= _userReadyMinTime;
                    if (notReadyAndNotLive) {
                        userGetUp(account);
                        hasRemoved := true;
                    };
                };
            };
            return hasRemoved;
        };

        public func removeBalanceInvalidOrReadyTimeoutUsers(accounts: [AID.Address], balances: [Nat64]) : Bool {
            if (balances.size() != accounts.size()) {return false;};
            if (balances.size() == 0) {return false;};
            if (isGameStartingOrStarted()) {return false;};
            var hasRemoved = false;
            let minBalance = SiteType.getMinimalBalance(_siteType);
            for (i in Iter.range(0, Nat.sub(balances.size(), 1))) {
                let isBalanceNotEnough = Nat64.toNat(balances[i]) < minBalance;
                let notReadyAndNotLive = (not Option.unwrap(_seats.get(accounts[i])).isReady()) and Time.now()-Option.unwrap(_seats.get(accounts[i])).sitdownTime() >= _userReadyMinTime;
                if (isBalanceNotEnough or notReadyAndNotLive) {
                    userGetUp(accounts[i]);
                    hasRemoved := true;
                };
            };
            return hasRemoved;
        };   
    }; 
};