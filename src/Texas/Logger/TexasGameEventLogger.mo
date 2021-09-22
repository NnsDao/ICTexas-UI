import TexasGameEventRecord "./TexasGameEventRecord";
import SiteType "../SiteType";
import Reward "../Reward";
import AID "../Utils/AccountId";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Option "mo:base/Option";
import Array "mo:base/Array";

shared(msg) actor class TexasGameEvent() {

    private stable let _createTime = Time.now();
    private stable var _owner : Principal = msg.caller;
    private var _texasGameCanisterId : Principal = Principal.fromText("ey3vx-fiaaa-aaaah-aaera-cai");
    private var _gameEndEvents : [TexasGameEventRecord.TexasGameEndEventRecord] = [];
    private var _gameEndEventsMap = HashMap.HashMap<AID.Address, [Nat]>(1, AID.equal, AID.hash);

    public shared(msg) func setOwner(_owner_ : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        _owner := Principal.fromText(_owner_);
        return true;
    };

    public shared(msg) func handleGameEndEvent(site : SiteType.SiteType, table : Nat, rewards : [Reward.RewardDetail], timestamp : Time.Time) : async Bool {
        if (_texasGameCanisterId != msg.caller) { return false; };
        let gameEndEventIndex = _gameEndEvents.size();
        let gameEndEvent : TexasGameEventRecord.TexasGameEndEventRecord = {
            site = site;
            table = table;
            rewards = rewards;
            timestamp = timestamp;
            index = gameEndEventIndex;
        };
        _gameEndEvents := Array.append(_gameEndEvents, [gameEndEvent]);
        for (reward in rewards.vals()) {
            let history = _gameEndEventsMap.get(reward.account);
            if (Option.isNull(history)) {_gameEndEventsMap.put(reward.account, [gameEndEventIndex]);}
            else {_gameEndEventsMap.put(reward.account, Array.append(Option.unwrap(history), [gameEndEventIndex]));};
        };
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

    public query func gameAmount() : async Nat {
        return _gameEndEvents.size();
    };

    public query func getGameDetailByTx(index: Nat) : async ?TexasGameEventRecord.TexasGameEndEventRecordResp {
        if (index >= _gameEndEvents.size()) return null;
        return ?_gameEndEvents[index];
    };

    public query func getGameDetailsOf(a: AID.Address) : async [TexasGameEventRecord.TexasGameEndEventRecordResp] {
        let e = _gameEndEventsMap.get(a);
        if (Option.isNull(e)) { return []; };
        return Array.map(Option.unwrap(e), func(index:Nat):TexasGameEventRecord.TexasGameEndEventRecordResp{_gameEndEvents[index]});
    };

    public query(msg) func getAllTGameDetails() : async [TexasGameEventRecord.TexasGameEndEventRecordResp] {
        if (msg.caller != _owner) { return []; };
        return _gameEndEvents;
    };

    public query func getCycles() : async Nat {
        return ExperimentalCycles.balance();
    };
}