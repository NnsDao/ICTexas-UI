import Time "mo:base/Time";
import Reward "./Reward";
import SiteType "./SiteType";

module {
    public type GameEventHandler = actor {
        handleGameEndEvent : (site : SiteType.SiteType, table : Nat, rewards : [Reward.RewardDetail], timestamp : Time.Time) -> async Bool;
    };
};