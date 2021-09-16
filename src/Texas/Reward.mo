import AID "./Utils/AccountId";
import Card "./Card";
import CardsType "./CardsType";

module {
    public type RewardDetail = {
                account: AID.Address;
                cards: [Text];
                holeCards: [Text];
                boardCards: [Text];
                actions:[[Text]];
                cardsType: CardsType.CardsType;
                score: Nat;
                fold: Bool;
                reward: Nat;
            };
};