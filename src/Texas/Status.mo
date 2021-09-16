import AID "./Utils/AccountId";
import Action "./Action";
import SiteType "./SiteType";
import RoundType "./RoundType";
import Time "mo:base/Time";

module {

    public type UserSitdownInfo = {
        site: SiteType.SiteType;
        table: Nat; 
        sitdownAt: Time.Time;
        needReadyBefore: Time.Time;
    };

    public type UserStatus = {
        #inseat : UserSitdownInfo;
        #inseatready : UserSitdownInfo;
        #ingame : UserSitdownInfo;
        #notinseat;
    };

    public type UserGameStatus = {
        account : AID.Address;
        userSpeak : UserSpeak;
        holeCards : [Text];
        isFold : Bool;
        isAllIn : Bool;
        isOnline : Bool;
        roundActions : [[Action.Action]];
    };

    public type UserSpeak = {
        lastSpeak : Text;
        lastSpeakIndex : Nat;
    };

    public type GameStatus = {
        users : [?UserGameStatus];
        boardCards : [Text];
        totalBets : Nat;
        currentRound : RoundType.RoundType;
        currentActionUser : AID.Address;
        currentActionSeq : Nat16;
        currentActionStart : Time.Time;
        currentActionBefore : Time.Time;
        currentActionCan : [Action.Action];
    };

    public type UserWaitingStatus = {
        account: AID.Address;
        isReady: Bool;
        sitdownAt: Time.Time;
        needReadyBefore: Time.Time;
        userSpeak: UserSpeak;
    };

    public type TableStatus = {
        #ingame : GameStatus;
        #instartgame : [?AID.Address];
        #waitinguser : [?UserWaitingStatus];
    };
};