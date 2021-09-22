import AID "./Utils/AccountId";
import AccountStatus "./AccountStatus";
import Action "./Action";
import Array "mo:base/Array";
import Card "./Card";
import Cards "./Cards";
import CardsType "./CardsType";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import RBTree "mo:base/RBTree";
import Round "./Round";
import Status "./Status";
import RoundType "./RoundType";
import Time "mo:base/Time";
import Reward "./Reward";

module {

    // just give (status query, can action do, status change) interface
    public class Game(_seatAccounts_: [?AID.Address], _accounts_ : [AID.Address], _smallBlindAccount_ : Nat, _smallBlind_ : Nat, _seeds_ : [Time.Time]) {
        private let _time = Time.now();
        private let _seatAccounts = _seatAccounts_;
        private let _accounts = _accounts_;
        private let _accountsStatus = HashMap.HashMap<AID.Address, AccountStatus.AccountStatus>(1, AID.equal, AID.hash);
        private let _smallBlindAccount = _smallBlindAccount_;
        private var _smallBlind = _smallBlind_;
        private let _cards = Cards.randomCards(_seeds_);
        private let _boardCards = Cards.Cards();
        private var _currentRound : Nat = 0;
        private var _rounds : [Round.Round] = [];
        private var _rewards : [Reward.RewardDetail] = [];

        for (account in _accounts.vals()) {
            let accountStatus = AccountStatus.AccountStatus();
            for (i in Iter.range(1, 2)) {accountStatus.holeCards.appendCard(Option.unwrap(_cards.popCard()));};
            _accountsStatus.put(account, accountStatus);
        };
        let preflopRound = Round.Round(#preflop, _accounts, _accountsStatus, _smallBlind, _smallBlindAccount, 1);
        preflopRound.start();
        _rounds := [preflopRound];

        private func computeReward() {
            var scoreTree = RBTree.RBTree<Nat, [{
                    account: AID.Address;
                    cards: [Text];
                    holeCards: [Text];
                    boardCards: [Text];
                    actions: [[Text]];
                    cardsType: CardsType.CardsType;
                    score: Nat;
                    fold: Bool;
                    bets: Nat;
                }]>(Nat.compare);
            var betsTree = RBTree.RBTree<Nat, [AID.Address]>(Nat.compare);
            let boardCards = _boardCards.toArray();
            for ((account, status) in _accountsStatus.entries()) {
                let holeCards = status.holeCards.toArray();
                status.holeCards.pushCards(boardCards);
                let (cardsType, score, bestCards) = status.holeCards.getCardsTypeAndScore();
                let fold = status.isFold();
                var bets = 0;
                for (round in _rounds.vals()) {bets += round.accountBet(account);};
                var actions : [[Text]] = [];
                for (round in _rounds.vals()) {actions := Array.append(actions, [Array.map(round.accountActions(account), func(a:Action.Action):Text{Action.actionToText(a)})]);};
                let accountInfo = {
                    account = account;
                    cards = Array.map(List.toArray(bestCards), func(card:Card.Card):Text{Card.cardToText(card)});
                    holeCards = Array.map(holeCards, func(card:Card.Card):Text{Card.cardToText(card)});
                    boardCards = Array.map(boardCards, func(card:Card.Card):Text{Card.cardToText(card)});
                    cardsType = cardsType;
                    actions = actions;
                    score = score;
                    fold = fold;
                    bets = bets;
                };
                let oldScoreInfo = scoreTree.get(score);
                if (Option.isNull(oldScoreInfo)) {scoreTree.put(score, [accountInfo])}
                else {scoreTree.put(score, Array.append(Option.unwrap(oldScoreInfo), [accountInfo]));};
                let oldBetInfo = betsTree.get(bets);
                if (Option.isNull(oldBetInfo)) {betsTree.put(bets, [account])}
                else {betsTree.put(bets, Array.append(Option.unwrap(oldBetInfo), [account]));};
            };
            let betTreeSize = Iter.size(betsTree.entries());
            if (betTreeSize > 0) {
                let betsArray = Iter.toArray(betsTree.entries());
                var rewards = HashMap.HashMap<AID.Address, Nat>(1, AID.equal, AID.hash);
                var lastBets = 0;
                for (i in Iter.range(0, betTreeSize-1)) {
                    let accounts = HashMap.HashMap<AID.Address, ()>(1, AID.equal, AID.hash);
                    for (j in Iter.range(i, betTreeSize-1)) {
                        for (a in betsArray[j].1.vals()) {accounts.put(a, ());};
                    };
                    var reward = Nat.sub(betsArray[i].0, lastBets)*accounts.size();
                    lastBets := betsArray[i].0;
                    label checkReward for ((_, accountsInfo) in scoreTree.entriesRev()) {
                        var rewardAccounts : [AID.Address] = [];
                        label checkRewardIn for (aInfo in accountsInfo.vals()) {
                            if (aInfo.fold) {continue checkRewardIn;};
                            if (Option.isNull(accounts.get(aInfo.account))) {continue checkRewardIn;};
                            rewardAccounts := Array.append(rewardAccounts, [aInfo.account]);
                        };
                        if (rewardAccounts.size() == 0) {continue checkReward;};
                        for (acc in rewardAccounts.vals()) {
                            let rewardOf = rewards.get(acc);
                            if (Option.isNull(rewardOf)) {rewards.put(acc, reward/rewardAccounts.size())}
                            else {rewards.put(acc, Option.unwrap(rewardOf) + reward/rewardAccounts.size())};
                        };
                        break checkReward;
                    };
                };
                let isOnlyOne = _currentRound <= 3;
                for ((_, accountsInfo) in scoreTree.entriesRev()) {
                    for (aInfo in accountsInfo.vals()) {
                        var reward = 0;
                        let rewardOf = rewards.get(aInfo.account);
                        var cards = aInfo.cards;
                        var holeCards = aInfo.holeCards;
                        var cardsType = aInfo.cardsType;
                        var score = aInfo.score;
                        if (isOnlyOne or aInfo.fold) {cards := aInfo.boardCards;};
                        if (isOnlyOne or aInfo.fold) {holeCards := [];};
                        if (isOnlyOne or aInfo.fold) {cardsType := #nonetype;};
                        if (isOnlyOne or aInfo.fold) {score := 0;};
                        if (Option.isSome(rewardOf)) {reward := Option.unwrap(rewardOf);};
                        _rewards := Array.append(_rewards, [
                            {
                                account = aInfo.account;
                                cards = cards;
                                holeCards = holeCards;
                                boardCards = aInfo.boardCards;
                                cardsType = cardsType;
                                actions = aInfo.actions;
                                score = score;
                                fold = aInfo.fold;
                                reward = reward; 
                            }
                        ]);
                    }
                };
            };
        };

        private func roundDone() {
            if (_currentRound == 0) {
                let actionSeqStart = _rounds[_currentRound].getCurrentActionSeq();
                _currentRound := 1;
                for (i in Iter.range(1, 3)) {_boardCards.appendCard(Option.unwrap(_cards.popCard()));};
                let flopRound = Round.Round(#flop, _accounts, _accountsStatus, _smallBlind, _smallBlindAccount, actionSeqStart+1);
                flopRound.start();
                _rounds := Array.append(_rounds, [flopRound]);
                if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
                else if (_rounds[_currentRound].isRoundEnd()) { roundDone(); };
            } else if (_currentRound == 1) {
                let actionSeqStart = _rounds[_currentRound].getCurrentActionSeq();
                _currentRound := 2;
                for (i in Iter.range(4, 4)) {_boardCards.appendCard(Option.unwrap(_cards.popCard()));};
                let turnRound = Round.Round(#turn, _accounts, _accountsStatus, _smallBlind, _smallBlindAccount, actionSeqStart+1);
                turnRound.start();
                _rounds := Array.append(_rounds, [turnRound]);
                if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
                else if (_rounds[_currentRound].isRoundEnd()) { roundDone(); };
            } else if (_currentRound == 2) {
                let actionSeqStart = _rounds[_currentRound].getCurrentActionSeq();
                _currentRound := 3;
                for (i in Iter.range(5, 5)) {_boardCards.appendCard(Option.unwrap(_cards.popCard()));};
                let riverRound = Round.Round(#river, _accounts, _accountsStatus, _smallBlind, _smallBlindAccount, actionSeqStart+1);
                riverRound.start();
                _rounds := Array.append(_rounds, [riverRound]);
                if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
                else if (_rounds[_currentRound].isRoundEnd()) { roundDone(); };               
            } else if (_currentRound == 3) {
                _currentRound := 4;
                computeReward();
            };
        };

        public func startTime() : Time.Time {
            return _time;
        };

        public func gameUsers() : [AID.Address] {
            return _accounts;
        };

        public func status(address : AID.Address, userSpeaks : [?Status.UserSpeak], userActioning : Bool, gameSettlementing : Bool) : Status.GameStatus {
            var usersStatus : [?Status.UserGameStatus] = [];
            var boardCards : [Text] = [];
            var totalBets : Nat = 0;
            var currentRound : RoundType.RoundType = #preflop;
            var currentActionUser : AID.Address = "";
            var currentActionSeq : Nat16 = 0;
            var currentActionStart : Time.Time = Time.now();
            var currentActionBefore : Time.Time = Time.now();
            var currentActionCan : [Action.Action] = [];
            
            if (_currentRound < 4) {
                let userInfo = _rounds[_currentRound].getActionUserInfo();
                currentActionUser := userInfo.0;
                currentActionStart := userInfo.1;
                currentActionBefore := userInfo.2;
                currentActionSeq := userInfo.3;
                currentActionCan := _rounds[_currentRound].actionCan();
            };
            currentRound := _rounds[_currentRound].getRoundType();
            for (i in Iter.range(0, _currentRound)) {totalBets+=_rounds[i].getTotalBets();};
            boardCards := Array.map(_boardCards.toArray(), func(card : Card.Card) : Text {Card.cardToText(card);});
            var index = 0;
            for (opAccount in _seatAccounts.vals()) {
                if (Option.isNull(opAccount)) {usersStatus := Array.append(usersStatus, [null]);}
                else {
                    let account = Option.unwrap(opAccount);
                    var userSpeak = {lastSpeak="";lastSpeakIndex=0;};
                    if (Option.isSome(userSpeaks[index])) {userSpeak:=Option.unwrap(userSpeaks[index]);};
                    let accountStatus = Option.unwrap(_accountsStatus.get(account));
                    var holeCards : [Text] = [];
                    let isFold : Bool = accountStatus.isFold();
                    let isAllIn : Bool = accountStatus.isAllIn();
                    let isOnline : Bool = accountStatus.isOnline();
                    var roundActions : [[Action.Action]] = [];
                    if (address == account) {holeCards := Array.map(accountStatus.holeCards.toArray(), func(card : Card.Card) : Text {Card.cardToText(card);});};
                    for (i in Iter.range(0, _currentRound)) {roundActions:=Array.append(roundActions, [_rounds[i].accountActions(account)]);};
                    usersStatus := Array.append(usersStatus, [?{
                        account = account;
                        userSpeak = userSpeak;
                        holeCards = holeCards;
                        isFold = isFold;
                        isAllIn = isAllIn;
                        isOnline = isOnline;
                        roundActions = roundActions;
                    }]);
                };
                index:=index+1;
            };
            return {
                users = usersStatus;
                inUserActioning = userActioning;
                inGameSettlementing = gameSettlementing;
                boardCards = boardCards;
                totalBets = totalBets;
                currentRound = currentRound;
                currentActionUser = currentActionUser;
                currentActionSeq = currentActionSeq;
                currentActionStart = currentActionStart;
                currentActionBefore = currentActionBefore;
                currentActionCan = currentActionCan;
            };
        };

        public func isUserFold(address : AID.Address) : Bool {
            let accountStatus = _accountsStatus.get(address);
            if (Option.isNull(accountStatus)) { return true; };
            return Option.unwrap(accountStatus).isFold();
        };

        public func isUserAllIn(address : AID.Address) : Bool {
            let accountStatus = _accountsStatus.get(address);
            if (Option.isNull(accountStatus)) { return false; };
            return Option.unwrap(accountStatus).isAllIn();
        };

        public func userHeartBeat(address : AID.Address, checkActionTimeOut : Bool) {
            if (_currentRound <= 3 and checkActionTimeOut) {
                if (_rounds[_currentRound].checkActionTimeOut()) {
                    if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
                    else if (_rounds[_currentRound].isRoundEnd()) {roundDone();};  
                };
            };
            let accountStatus = _accountsStatus.get(address);
            if (Option.isNull(accountStatus)) { return; };
            Option.unwrap(accountStatus).updateOnlineTime();
        };

        public func canAction(address : AID.Address, action : Action.Action, actionSeq : Nat16) : (Bool, Text) {
            if (_currentRound > 3) { return (false, "game is not start"); };
            let accountStatus = _accountsStatus.get(address);
            if (Option.isNull(accountStatus)) { return (false, "address is not in this game"); };
            Option.unwrap(accountStatus).updateOnlineTime();
            
            let (can, reuslt) = _rounds[_currentRound].canAction(address, action, actionSeq);
            if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
            else if (_rounds[_currentRound].isRoundEnd()) {roundDone();};
            return (can, reuslt);
        };

        // notic allin action must set to the true amount balance
        public func actionDone(address : AID.Address, action : Action.Action) {
            if (_currentRound > 3) { return; };
            let accountStatus = _accountsStatus.get(address);
            if (Option.isNull(accountStatus)) { return; };
            Option.unwrap(accountStatus).updateOnlineTime();
    
            _rounds[_currentRound].actionDone(address, action);
            if (_rounds[_currentRound].isOnlyOneLive()) {computeReward();}
            else if (_rounds[_currentRound].isRoundEnd()) {roundDone();};
        };

        public func isGameEnd() : Bool {
            if (_currentRound > 3) { return true; };
            if (_rounds[_currentRound].isOnlyOneLive()) { return true;};
            if (_currentRound < 3) { return false; };
            return _rounds[_currentRound].isRoundEnd();
        };

        public func getRewards() : [Reward.RewardDetail] {
            return _rewards;
        };
        
    };

};
