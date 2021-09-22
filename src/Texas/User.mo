import AID "./Utils/AccountId";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";

module {
    public type UserInfo = {
        address: AID.Address;
        createTime: Time.Time;
        alias: Text;
        avatar: Text;
    };
};
