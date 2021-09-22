import Reward "../Reward";
import SiteType "../SiteType";
import Time "mo:base/Time";

module {

    public type TexasGameEndEventRecord = {
        site: SiteType.SiteType;
        table: Nat;
        rewards : [Reward.RewardDetail];
        timestamp: Time.Time;
        index: Nat;
    };

    public type TexasGameEndEventRecordResp = TexasGameEndEventRecord;
};