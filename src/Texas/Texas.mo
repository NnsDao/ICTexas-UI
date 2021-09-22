import AID "./Utils/AccountId";
import Action "./Action";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Card "./Card";
import Cards "./Cards";
import Char "mo:base/Char";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import RBTree "mo:base/RBTree";
import SiteType "./SiteType";
import Status "./Status";
import Reward "./Reward";
import Table "./Table";
import Text "mo:base/Text";
import Time "mo:base/Time";
import GameEvent "./GameEvent";
import User "./User";
import ExperimentalCycles "mo:base/ExperimentalCycles";

shared(msg) actor class Texas() {

    type TokenActor = actor {
        allowance: (owner: AID.Address, spender: AID.Address) -> async Nat64;
        balanceOf: (who: AID.Address) -> async Nat64;
        balancesOf: (whos: [AID.Address]) -> async [Nat64];
        transfer : (to: AID.Address, value: Nat64) -> async Bool;
        transferFrom : (from: AID.Address, to: AID.Address, value: Nat64) -> async Bool;
    };

    private stable let _createTime : Time.Time = Time.now();
    private stable var _owner : Principal = msg.caller;
    private stable var _userInfoEntries : [(AID.Address,User.UserInfo)] = [];
    private stable var _aliasAddressEntries : [(Text, AID.Address)] = [];
    private let _addressUserMap = HashMap.fromIter<AID.Address,User.UserInfo>(_userInfoEntries.vals(), 1, Text.equal, Text.hash);
    private let _aliasAddressMap = HashMap.fromIter<Text,AID.Address>(_aliasAddressEntries.vals(), 1, Text.equal, Text.hash);
    private var _needUpgrade = false;
    private var _forceUpgrade = false;
    private let _maxAliasSize = 18;
    private let _maxAvatarUrlSize = 255;
    private let _maxSpeakSize = 300;
    private let _siteCount = 3;
    private let _tablePerSiteCount = [100, 200, 200];
    private let _longTimeGameTime = 30 * 60 * 1_000_000_000;
    private let _gameEventLoggerCanisterId = "ll4dt-naaaa-aaaah-aafuq-cai";
    private let _tokenCanisterId = "ery6l-taaaa-aaaah-aaeqq-cai";
    private var _selfTokenAddress : AID.Address = "8ca93b50b3d080e0a18d1999c21596cf30b6823d0feb840107192aca972d7fe4";
    private let _tokenActor : TokenActor = actor(_tokenCanisterId);
    private let _gameEventLoggerActor : GameEvent.GameEventHandler = actor(_gameEventLoggerCanisterId);
    private var _playground : [[var ?Table.Table]]= Array.tabulate(_siteCount, func (i:Nat) : [var ?Table.Table] {
        Array.tabulateVar(_tablePerSiteCount[i], func (j:Nat) : ?Table.Table {return null;});
    });
    private var _canSitdownTables : [RBTree.RBTree<Nat, ()>] = Array.tabulate(_siteCount, func (i:Nat) : RBTree.RBTree<Nat, ()> {
        let rbTree = RBTree.RBTree<Nat, ()>(Nat.compare);
        for (j in Iter.range(0, _tablePerSiteCount[i]-1)) {rbTree.put(j, ());};
        return rbTree;
    });
    private var _gameStartTables : [RBTree.RBTree<Time.Time, Nat>] = Array.tabulate(_siteCount, func (i:Nat) : RBTree.RBTree<Time.Time, Nat> {
        return RBTree.RBTree<Time.Time, Nat>(Int.compare);
    });
    private var _gameStartTablesMap : [HashMap.HashMap<Nat, Time.Time>] = Array.tabulate(_siteCount, func (i:Nat) : HashMap.HashMap<Nat, Time.Time> {
        return HashMap.HashMap<Nat, Time.Time>(1, Nat.equal, Hash.hash);
    });
    private var _inSeatUsers = HashMap.HashMap<AID.Address, (Nat, Nat)>(1, AID.equal, AID.hash);
    
    private func tableOf(site: Nat, table: Nat) : Table.Table {
        if (Option.isSome(_playground[site][table])) {return Option.unwrap(_playground[site][table])};
        _playground[site][table] := ?Table.Table(SiteType.fromNat(site), table);
        return Option.unwrap(_playground[site][table]);
    };

    private func timeKeyOf(table: Nat, t: Time.Time, userCount: Nat) : Time.Time {
        return t*10000+Int64.toInt(Int64.fromNat64(Nat64.fromNat(table)));
    };

    private func updateTableUsers(site: Nat, table: Nat, user: AID.Address) {
        if (tableOf(site,table).canUserSitdown()) {_canSitdownTables[site].put(table, ());}
        else {_canSitdownTables[site].delete(table);};

        for (address in tableOf(site,table).sitdownUsers().vals()) {_inSeatUsers.put(address, (site, table));};

        if ((not tableOf(site,table).isUserSitdown(user)) and Option.isSome(_inSeatUsers.get(user))) {
            let (cSite, cTable) = Option.unwrap(_inSeatUsers.get(user));
            if (cSite == site and cTable == table) {_inSeatUsers.delete(user);};
        };

        let opGameTimeKey = _gameStartTablesMap[site].get(table);
        if (tableOf(site,table).isGameStarted()) {
            let currentTimeKey = timeKeyOf(table, tableOf(site,table).gameStartTime(), tableOf(site,table).gameUsers().size()); 
            if (Option.isNull(opGameTimeKey)) {
                _gameStartTablesMap[site].put(table, currentTimeKey);
                _gameStartTables[site].put(currentTimeKey, table);
            } else if (Option.unwrap(opGameTimeKey) != currentTimeKey) {
                _gameStartTables[site].delete(Option.unwrap(opGameTimeKey));
                _gameStartTablesMap[site].put(table, currentTimeKey);
                _gameStartTables[site].put(currentTimeKey, table);
            };
        } else if (Option.isSome(opGameTimeKey)) {
            _gameStartTablesMap[site].delete(table);
            _gameStartTables[site].delete(Option.unwrap(opGameTimeKey));
        };

        if (tableOf(site,table).sitdownUsers().size() == 0) {_playground[site][table] := null;}
    };

    private func isUserSitdown(address : AID.Address) : (down : Bool, site : Nat, table : Nat) {
        let userSeat = _inSeatUsers.get(address);
        if (Option.isNull(userSeat)) {return (false, 0, 0);};
        let (site, table) = Option.unwrap(userSeat);
        if (tableOf(site,table).isUserSitdown(address)) {return (true, site, table);};
        _inSeatUsers.delete(address);
        updateTableUsers(site, table, address);
        return (false, 0, 0);
    };

    private func needSimulationHeartBeatForLongTimeGame(site : Nat) : (Bool, Nat, Nat, Text) {
        let t = _gameStartTables[site].entries().next();
        if (Option.isNull(t)) {return (false, 0, 0, "");};
        let (_,table) = Option.unwrap(t);
        if (not tableOf(site,table).isGameStarted()) {return (false, 0, 0, "");};
        let users = tableOf(site,table).gameUsers();
        if (users.size() == 0) {return (false, 0, 0, "");};
        let gameStartTime = tableOf(site,table).gameStartTime();
        if (Time.now()-gameStartTime <= _longTimeGameTime) {return (false, 0, 0, "");};
        return (true, site, table, users[0]);
    };

    private func simulationHeartBeatForLongTimeGame(site : Nat, table: Nat, address: Text) : async (){
        tableOf(site,table).userHeartBeat(address);
        updateTableUsers(site, table, address);
        if (tableOf(site,table).needGameOverSettlement()) {
            let gameRewards = tableOf(site,table).lastGameRewards();
            for (accountReward in gameRewards.vals()) {
                if (accountReward.reward != 0) {ignore _tokenActor.transfer(accountReward.account, Nat64.fromNat(accountReward.reward));};
            };
            ignore _gameEventLoggerActor.handleGameEndEvent(SiteType.fromNat(site), table, gameRewards, Time.now());
            tableOf(site,table).gameOverSettlement();
            updateTableUsers(site, table, address);
        };
    };

    public shared(msg) func setOwner(_owner_ : Text) : async Bool {
        if (msg.caller != _owner) { return false; };
        if (_owner_ == "") { return false; };
        _owner := Principal.fromText(_owner_);
        return true;
    };

    public shared(msg) func setUpgrade(needUpgrade : Bool) : async Bool {
        if (msg.caller != _owner) { return false; };
        _needUpgrade := needUpgrade;
        return true;
    };

    public shared(msg) func setForceUpgrade(force : Bool) : async Bool {
        if (msg.caller != _owner) { return false; };
        _forceUpgrade := force;
        return true;
    };

    public shared(msg) func refund(address : AID.Address, amount : Nat64) : async Bool {
        if (msg.caller != _owner) { return false; };
        return await _tokenActor.transfer(address, amount);
    };

    public shared(msg) func setAlias(alias: Text) : async (Bool, Text) {
        if (Text.size(alias) > _maxAliasSize) {return (false, "alias length is max than "#Nat.toText(_maxAliasSize));};
        let address = AID.fromPrincipal(msg.caller, null);
        let aliasAddressOp =  _aliasAddressMap.get(alias);
        if (Option.isSome(aliasAddressOp) and Option.unwrap(aliasAddressOp) != address) {return (false, "alias has exist");};
        if (Option.isSome(aliasAddressOp) and Option.unwrap(aliasAddressOp) == address) {return (true, "");};
        let addressUserOp = _addressUserMap.get(address);
        if (Option.isSome(addressUserOp)) {
            let oldUserInfo = Option.unwrap(addressUserOp);
            _aliasAddressMap.delete(oldUserInfo.alias);
            _addressUserMap.put(address, {address=oldUserInfo.address;createTime=oldUserInfo.createTime;alias=alias;avatar=oldUserInfo.avatar;});
            _aliasAddressMap.put(alias, address);
        } else {
            _addressUserMap.put(address, {address=address;createTime=Time.now();alias=alias;avatar="";});
            _aliasAddressMap.put(alias, address);
        };
        return (true, "");
    };

    public shared(msg) func setAvatar(avatar: Text) : async (Bool, Text) {
        if (Text.size(avatar) > _maxAvatarUrlSize) {return (false, "avatar length is max than "#Nat.toText(_maxAvatarUrlSize));};
        let address = AID.fromPrincipal(msg.caller, null);
        let addressUserOp = _addressUserMap.get(address);
        if (Option.isSome(addressUserOp)) {
            let oldUserInfo = Option.unwrap(addressUserOp);
            _addressUserMap.put(address, {address=oldUserInfo.address;createTime=oldUserInfo.createTime;alias=oldUserInfo.alias;avatar=avatar;});
        } else {
            _addressUserMap.put(address, {address=address;createTime=Time.now();alias="";avatar=avatar;});
        };
        return (true, "");
    };

    public shared(msg) func userSitdown(siteType : SiteType.SiteType) : async (Bool, Text) {
        let address = AID.fromPrincipal(msg.caller, null);
        let site = SiteType.toNat(siteType);
        var table = 0;
        let (needSim, simSit, simTable, simAddress) = needSimulationHeartBeatForLongTimeGame(site);
        if (needSim) {ignore simulationHeartBeatForLongTimeGame(simSit, simTable, simAddress)};
        let balance = await _tokenActor.balanceOf(address);
        let allowed = await _tokenActor.allowance(address, _selfTokenAddress); 
        let (tmpDown, tmpSite, tmpTable) = isUserSitdown(address);
        var tmpHasRemovedUser = false;
        if (tmpDown) {tmpHasRemovedUser := tableOf(tmpSite,tmpTable).removeReadyTimeoutUsers();};
        if (tmpHasRemovedUser) {updateTableUsers(tmpSite, tmpTable, address);};
        let (down, cSite, _) = isUserSitdown(address);
        if (down and site != cSite) {return (false, "has already in other site");};
        if (down and site == cSite) {return (true, "");};
        if (Nat64.toNat(balance) < SiteType.getMinimalBalance(siteType)) {return (false, "you balance is not enough");};
        if (allowed == 0) { return (false, "you must allow canister to transfer you token");};
        if (_needUpgrade) {return (false, "will upgrade, can not join")};
        label sitdown loop {
            let t = _canSitdownTables[site].entries().next();
            if (Option.isNull(t)) {return (false, "no table to join");};
            table := Option.unwrap(t).0;
            if (tableOf(site,table).removeReadyTimeoutUsers()) {updateTableUsers(site, table, address);};
            if (not tableOf(site,table).canUserSitdown()) {
                updateTableUsers(site, table, address);
                continue sitdown;
            };
            break sitdown;
        };
        tableOf(site,table).userSitdown(address);
        updateTableUsers(site, table, address);
        return (true, "");
    };

    public shared(msg) func userGetUp() : async Bool {
        let address = AID.fromPrincipal(msg.caller, null);
        let (tmpDown, tmpSite, tmpTable) = isUserSitdown(address);
        if (not tmpDown) {return true;};
        if (tableOf(tmpSite,tmpTable).removeReadyTimeoutUsers()) {updateTableUsers(tmpSite, tmpTable, address);};
        let (down, site, table) = isUserSitdown(address);
        if (not down) {return true;};
        if (not tableOf(site,table).canUserGetUp(address)) {return false;};
        tableOf(site,table).userGetUp(address);
        updateTableUsers(site, table, address);
        label tryStart loop {
            if (not tableOf(site,table).canGameStart()) {break tryStart;};
            let siteType = tableOf(site,table).tableSiteType();
            let accounts = tableOf(site,table).sitdownUsers();
            let smallBlind = SiteType.getSmallBlind(siteType);
            let smallblindIndex = Nat64.toNat(Nat64.fromIntWrap(Time.now()%accounts.size()));
            let smallBlindAccount = accounts[smallblindIndex];
            let bigBlindAccount = accounts[(smallblindIndex+1)%accounts.size()];
            let isSmallBlindTransSuccess = await _tokenActor.transferFrom(smallBlindAccount, _selfTokenAddress, Nat64.fromNat(smallBlind));
            if (not isSmallBlindTransSuccess) {
                tableOf(site,table).gameStartFailed(smallBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            let isBigBlindTransSuccess = await _tokenActor.transferFrom(bigBlindAccount, _selfTokenAddress, Nat64.fromNat(2*smallBlind));
            if (not isBigBlindTransSuccess) {
                ignore _tokenActor.transfer(smallBlindAccount, Nat64.fromNat(smallBlind));
                tableOf(site,table).gameStartFailed(bigBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            tableOf(site,table).gameStartSuccess(smallblindIndex, smallBlind);
            break tryStart;
        };
        return true;
    };

    public shared(msg) func userReadyPlay() : async Bool {
        let address = AID.fromPrincipal(msg.caller, null);
        let (down, site, table) = isUserSitdown(address);
        if (not down) {return false;};
        if (tableOf(site,table).isGameStartingOrStarted()) {return isUserSitdown(address).0 and tableOf(site,table).isUserReadyPlay(address);};
        if (_needUpgrade) {return isUserSitdown(address).0 and tableOf(site,table).isUserReadyPlay(address);};
        let accounts = tableOf(site,table).sitdownUsers();
        let balances = await _tokenActor.balancesOf(accounts);
        if (tableOf(site,table).removeBalanceInvalidOrReadyTimeoutUsers(accounts, balances)) {updateTableUsers(site, table, address);};
        if (tableOf(site,table).canUserReadyPlay(address)) {
            tableOf(site,table).userReadyPlay(address);
            updateTableUsers(site, table, address);
        };
        label tryStart loop {
            if (not tableOf(site,table).canGameStart()) {break tryStart;};
            let siteType = tableOf(site,table).tableSiteType();
            let accounts = tableOf(site,table).sitdownUsers();
            let smallBlind = SiteType.getSmallBlind(siteType);
            let smallblindIndex = Nat64.toNat(Nat64.fromIntWrap(Time.now()%accounts.size()));
            let smallBlindAccount = accounts[smallblindIndex];
            let bigBlindAccount = accounts[(smallblindIndex+1)%accounts.size()];
            let isSmallBlindTransSuccess = await _tokenActor.transferFrom(smallBlindAccount, _selfTokenAddress, Nat64.fromNat(smallBlind));
            if (not isSmallBlindTransSuccess) {
                tableOf(site,table).gameStartFailed(smallBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            let isBigBlindTransSuccess = await _tokenActor.transferFrom(bigBlindAccount, _selfTokenAddress, Nat64.fromNat(2*smallBlind));
            if (not isBigBlindTransSuccess) {
                ignore _tokenActor.transfer(smallBlindAccount, Nat64.fromNat(smallBlind));
                tableOf(site,table).gameStartFailed(bigBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            tableOf(site,table).gameStartSuccess(smallblindIndex, smallBlind);
            break tryStart;
        };
        return isUserSitdown(address).0 and tableOf(site,table).isUserReadyPlay(address);
    };

    public shared(msg) func userAction(_action : Action.Action, actionSeq : Nat16) : async (Bool, Text) {
        let address = AID.fromPrincipal(msg.caller, null);
        let (down, site, table) = isUserSitdown(address);
        if (not down) {return (false, "you are not in any table");};
        var action = _action;
        if (Action.isAllIn(action)) {action := #allin(Nat64.toNat(await _tokenActor.balanceOf(address)));};
        let (canAction, result) = tableOf(site,table).canUserAction(address, action, actionSeq);
        if (not canAction) {
            if (tableOf(site,table).needGameOverSettlement()) {
                let gameRewards = tableOf(site,table).lastGameRewards();
                for (accountReward in gameRewards.vals()) {
                    if (accountReward.reward != 0) {ignore _tokenActor.transfer(accountReward.account, Nat64.fromNat(accountReward.reward));};
                };
                ignore _gameEventLoggerActor.handleGameEndEvent(SiteType.fromNat(site), table, gameRewards, Time.now());
                tableOf(site,table).gameOverSettlement();
                updateTableUsers(site, table, address);
            };
            return (false, result);
        };
        var transferSuccess = true;
        if (Action.isCall(action) or Action.isRaise(action) or Action.isBet(action) or (Action.isAllIn(action) and Action.amountOf(action) > 0)) {
            transferSuccess := await _tokenActor.transferFrom(address, _selfTokenAddress, Nat64.fromNat(Action.amountOf(action)));
        };
        if (not transferSuccess) {
            tableOf(site,table).userActionFailed(address, action);
            return (false, "do token transfer from failed");
        };
        tableOf(site,table).userActionSuccess(address, action);
        if (tableOf(site,table).needGameOverSettlement()) {
            let gameRewards = tableOf(site,table).lastGameRewards();
            for (accountReward in gameRewards.vals()) {
                if (accountReward.reward != 0) {ignore _tokenActor.transfer(accountReward.account, Nat64.fromNat(accountReward.reward));};
            };
            ignore _gameEventLoggerActor.handleGameEndEvent(SiteType.fromNat(site), table, gameRewards, Time.now());
            tableOf(site,table).gameOverSettlement();
            updateTableUsers(site, table, address);
        };
        return (true, ""); 
    };  

    public shared(msg) func userHeartBeat() {
        let address = AID.fromPrincipal(msg.caller, null);
        let (down, site, table) = isUserSitdown(address);
        if (not down) {return;};
        if (tableOf(site,table).removeReadyTimeoutUsers()) {updateTableUsers(site, table, address);};
        tableOf(site,table).userHeartBeat(address);
        updateTableUsers(site, table, address);
        if (tableOf(site,table).needGameOverSettlement()) {
            let gameRewards = tableOf(site,table).lastGameRewards();
            for (accountReward in gameRewards.vals()) {
                if (accountReward.reward != 0) {ignore _tokenActor.transfer(accountReward.account, Nat64.fromNat(accountReward.reward));};
            };
            ignore _gameEventLoggerActor.handleGameEndEvent(SiteType.fromNat(site), table, gameRewards, Time.now());
            tableOf(site,table).gameOverSettlement();
            updateTableUsers(site, table, address);
        };
        let (needSim, simSit, simTable, simAddress) = needSimulationHeartBeatForLongTimeGame(site);
        if (needSim) {ignore simulationHeartBeatForLongTimeGame(simSit, simTable, simAddress)};
        label tryStart loop {
            if (not tableOf(site,table).canGameStart()) {break tryStart;};
            let siteType = tableOf(site,table).tableSiteType();
            let accounts = tableOf(site,table).sitdownUsers();
            let smallBlind = SiteType.getSmallBlind(siteType);
            let smallblindIndex = Nat64.toNat(Nat64.fromIntWrap(Time.now()%accounts.size()));
            let smallBlindAccount = accounts[smallblindIndex];
            let bigBlindAccount = accounts[(smallblindIndex+1)%accounts.size()];
            let isSmallBlindTransSuccess = await _tokenActor.transferFrom(smallBlindAccount, _selfTokenAddress, Nat64.fromNat(smallBlind));
            if (not isSmallBlindTransSuccess) {
                tableOf(site,table).gameStartFailed(smallBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            let isBigBlindTransSuccess = await _tokenActor.transferFrom(bigBlindAccount, _selfTokenAddress, Nat64.fromNat(2*smallBlind));
            if (not isBigBlindTransSuccess) {
                ignore _tokenActor.transfer(smallBlindAccount, Nat64.fromNat(smallBlind));
                tableOf(site,table).gameStartFailed(bigBlindAccount);
                updateTableUsers(site, table, address);
                continue tryStart;
            };
            tableOf(site,table).gameStartSuccess(smallblindIndex, smallBlind);
            break tryStart;
        };
    };

   public shared(msg) func userSpeak(speak: Text) : async Bool {
        let address = AID.fromPrincipal(msg.caller, null);
        let (tmpDown, tmpSite, tmpTable) = isUserSitdown(address);
        if (not tmpDown) {return false;};
        if (tableOf(tmpSite,tmpTable).removeReadyTimeoutUsers()) {updateTableUsers(tmpSite, tmpTable, address);};
        let (down, site, table) = isUserSitdown(address);
        if (not down) {return false;};
        if (Text.size(speak) > _maxSpeakSize or Text.size(speak) == 0) {return false;};
        tableOf(site,table).setUserSpeak(address, speak);
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

    public query func isNeedUpgrade() : async Bool {
        return _needUpgrade;
    };

    public query func isForceUpgrade() : async Bool {
        return _forceUpgrade;
    };

    public query(msg) func userInfo(who: AID.Address) : async ?User.UserInfo {
        var vwho = who;
        if (vwho == "") { vwho := AID.fromPrincipal(msg.caller, null) };
        if (not AID.valid(vwho)) { return null; };
        return _addressUserMap.get(vwho);
    };

    public query func userInfos(whos: [AID.Address]) : async [?User.UserInfo] {
        var userInfos : [?User.UserInfo] = [];
        for (who in whos.vals()) {
            var userInfo : ?User.UserInfo = null;
            if (AID.valid(who) and Option.isSome(_addressUserMap.get(who))) { userInfo := ?Option.unwrap(_addressUserMap.get(who)); };
            userInfos := Array.append(userInfos, [userInfo]);
        };
        return userInfos;
    };

    public query(msg) func userStatus() : async Status.UserStatus {
        let address = AID.fromPrincipal(msg.caller, null);
        let userSeat = _inSeatUsers.get(address);
        if (Option.isNull(userSeat)) {return #notinseat};
        let (site,table) = Option.unwrap(userSeat);
        if (not tableOf(site,table).isUserSitdown(address)) {return #notinseat};
        let userSitdownInfo: Status.UserSitdownInfo = {
            site = SiteType.fromNat(site);
            table = table;
            sitdownAt = tableOf(site,table).userSitdownTime(address)/1_000_000_000*1_000_000_000;
            needReadyBefore = tableOf(site,table).userReadyTimeBefore(address)/1_000_000_000*1_000_000_000;
        };
        if (not tableOf(site,table).isUserReadyPlay(address)) {return #inseat(userSitdownInfo);};
        if (not tableOf(site,table).isGameStarted()) {return #inseatready(userSitdownInfo);};
        return #ingame(userSitdownInfo);
    }; 

    public query(msg) func tableStatus(siteType : SiteType.SiteType, table : Nat) : async ?Status.TableStatus {
        let address = AID.fromPrincipal(msg.caller, null);
        let site = SiteType.toNat(siteType);
        if (table >= _tablePerSiteCount[site]) {return null};
        return ?tableOf(site,table).status(address);
    }; 

    public query func totalTables(siteType : SiteType.SiteType) : async Nat {
        let site = SiteType.toNat(siteType);
        return _tablePerSiteCount[site];
    };

    public query func freeTables(siteType : SiteType.SiteType) : async Nat {
        let site = SiteType.toNat(siteType);
        return Iter.size(_canSitdownTables[site].entries());
    };

    public query func gamingTables(siteType : SiteType.SiteType) : async Nat {
        let site = SiteType.toNat(siteType);
        return Iter.size(_gameStartTables[site].entries());
    };

    public query func gamingSites() : async [SiteType.SiteInfo] {
        let sites : [SiteType.SiteType] = [#high, #mid, #low];
        return Array.map<SiteType.SiteType, SiteType.SiteInfo>(sites, func(st:SiteType.SiteType): SiteType.SiteInfo{return (st, SiteType.getMinimalBalance(st), SiteType.getSmallBlind(st));});
    };

    public query func lastGameRewardsOfTable(siteType : SiteType.SiteType, table : Nat) : async ?[Reward.RewardDetail] {
        let site = SiteType.toNat(siteType);
        if (table >= _tablePerSiteCount[site]) {return null};
        return ?tableOf(site,table).lastGameRewards();
    };

    public query func getCycles() : async Nat {
        return ExperimentalCycles.balance();
    };

    public query func tokenCanisterID() : async Principal {
        return Principal.fromText(_tokenCanisterId);
    };

    public query func gameEventLoggerCanisterID() : async Principal {
        return Principal.fromText(_gameEventLoggerCanisterId);
    };

    system func preupgrade() {
        _userInfoEntries := Iter.toArray(_addressUserMap.entries());
        _aliasAddressEntries := Iter.toArray(_aliasAddressMap.entries());
        if (_forceUpgrade) {return;};
        for (i in Iter.range(0, _siteCount-1)) {assert (Iter.size(_gameStartTables[i].entries()) == 0);};
    };

    system func postupgrade() {
        _aliasAddressEntries := [];
        _userInfoEntries := [];
    };
};
