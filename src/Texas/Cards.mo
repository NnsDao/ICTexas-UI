import Array "mo:base/Array";
import List "mo:base/List";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Char "mo:base/Char";
import Text "mo:base/Text";
import RBTree "mo:base/RBTree";
import Option "mo:base/Option";
import Card "./Card";
import CardsType "./CardsType";

module {

    private func formatCardsScore(ctype : Nat, face1 : Nat, face2 : Nat, face3 : Nat, face4 : Nat, face5 : Nat) : Nat {
        return Nat64.toNat((Nat64.fromNat(ctype) << 25) | (Nat64.fromNat(face1) << 20) | (Nat64.fromNat(face2) << 15) | (Nat64.fromNat(face3) << 10) | (Nat64.fromNat(face4) << 5) | Nat64.fromNat(face5));
    };

    private func cardsFromArray(cards : [Nat]) : Cards {
        var cardList = Cards();
        for (card in cards.vals()) {cardList.appendCard(Card.cardFromNat(card));};
        return cardList;
    };

    private func isStrightFlush(cards : List.List<Card.Card>) : (Bool, Nat, Nat, Nat, Nat, Nat, List.List<Card.Card>) {
        let clubCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let diamondCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let heartsCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let spadeCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        for (card in Iter.fromList(cards)) {
            switch card {
                case (#club(face)) { clubCards.put(face, card); };
                case (#diamond(face)) { diamondCards.put(face, card); };
                case (#hearts(face)) { heartsCards.put(face, card); };
                case (#spade(face)) { spadeCards.put(face, card); };
            };
        };
        func getFlushCards(cards : RBTree.RBTree<Nat, Card.Card>) : List.List<Card.Card> {
            var cardList = List.nil<Card.Card>();
            for ((_, card) in cards.entriesRev()) {cardList := List.push<Card.Card>(card, cardList);};
            return cardList;
        };
        if (Iter.size(clubCards.entries()) >= 5) {return isStright(getFlushCards(clubCards))};
        if (Iter.size(diamondCards.entries()) >= 5) {return isStright(getFlushCards(diamondCards));};
        if (Iter.size(heartsCards.entries()) >= 5) {return isStright(getFlushCards(heartsCards));};
        if (Iter.size(spadeCards.entries()) >= 5) {return isStright(getFlushCards(spadeCards));};
        return (false, 0, 0 ,0 ,0 ,0, List.nil<Card.Card>());
    };

    private func isFlush(cards : List.List<Card.Card>) : (Bool, Nat, Nat, Nat, Nat, Nat, List.List<Card.Card>) {
        let clubCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let diamondCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let heartsCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        let spadeCards = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        for (card in Iter.fromList(cards)) {
            switch card {
                case (#club(face)) { clubCards.put(face, card); };
                case (#diamond(face)) { diamondCards.put(face, card); };
                case (#hearts(face)) { heartsCards.put(face, card); };
                case (#spade(face)) { spadeCards.put(face, card); };
            };
        };
        func getResult(cards : RBTree.RBTree<Nat, Card.Card>) : (Bool, Nat, Nat, Nat, Nat, Nat, List.List<Card.Card>) {
            var faceCards = List.nil<Card.Card>();
            let faces = Array.init<Nat>(5, 0);
            var index = 0;
            label run for ((face, card) in cards.entriesRev()) {
                faceCards := List.push(card, faceCards);
                faces[index] := face;
                index += 1;
                if (index >= 5) {break run;};
            };
            return (true, faces[0], faces[1], faces[2], faces[3], faces[4], faceCards);
        };
        if (Iter.size(clubCards.entries()) >= 5) {return getResult(clubCards);};
        if (Iter.size(diamondCards.entries()) >= 5) {return getResult(diamondCards);};
        if (Iter.size(heartsCards.entries()) >= 5) {return getResult(heartsCards);};
        if (Iter.size(spadeCards.entries()) >= 5) {return getResult(spadeCards);};
        return (false, 0, 0 ,0 ,0 ,0, List.nil<Card.Card>());
    };

    private func isStright(cards : List.List<Card.Card>) : (Bool, Nat, Nat, Nat, Nat, Nat, List.List<Card.Card>) {
        let cardTree = RBTree.RBTree<Nat, Card.Card>(Nat.compare);
        for (card in Iter.fromList(cards)) {cardTree.put(Card.getCardFace(card), card);};
        if (Iter.size(cardTree.entries()) < 5) { return (false, 0, 0 ,0 ,0 ,0, List.nil<Card.Card>()); };
        var faceCards = List.nil<Card.Card>();
        var faces = Array.init<Nat>(5, 0);
        var index = 0;
        label run for ((face, card) in cardTree.entriesRev()) {
            if (index == 0) {
                faceCards := List.push(card, faceCards);
                faces[index] := face;
                index += 1;
            } else if (index >= 5) {
                break run;
            } else {
                if (faces[index-1] > face and Int64.fromNat64(Nat64.fromNat(faces[index-1])) - Int64.fromNat64(Nat64.fromNat(face)) == 1) {
                    faceCards := List.push(card, faceCards);
                    faces[index] := face;
                    index += 1;
                } else {
                    faceCards := List.nil<Card.Card>();
                    faces := Array.init<Nat>(5, 0);
                    index := 0;
                };
            };
        };
        if (index != 5) { return (false, 0, 0 ,0 ,0 ,0, List.nil<Card.Card>()); };
        return (true, faces[0], faces[1], faces[2], faces[3], faces[4], faceCards);
    };

    public class Cards() {
        private var _cards : List.List<Card.Card> = List.nil<Card.Card>();

        private func getFiveCardsByFace(faces : [Nat]) : List.List<Card.Card> {
            var sortFaceCards = List.nil<Card.Card>();
            for (face in faces.vals()) {
                label findface for (card in Iter.fromList(_cards)) {
                    if (face == Card.getCardFace(card)) {
                        var isCardGet = false;
                        label findMatch for (tmpCard in Iter.fromList(sortFaceCards)) {
                            if (card == tmpCard) {
                                isCardGet := true;
                                break findMatch;
                            };
                        };
                        if (not isCardGet) {
                            sortFaceCards := List.append(sortFaceCards, List.make(card));
                            break findface;
                        };
                    };
                };
            };            
            return sortFaceCards
        };

        public func pushCard(card : Card.Card) {
            _cards := List.push(card, _cards);
        };

        public func pushCards(cards : [Card.Card]) {
            if (cards.size() > 0) {
                for (index in Iter.revRange(Int64.toInt(Int64.fromNat64(Nat64.fromNat(cards.size()-1))), 0)) {
                    pushCard(cards[Nat64.toNat(Int64.toNat64(Int64.fromIntWrap(index)))]);
                };
            };
        };

        public func appendCard(card : Card.Card) {
            _cards := List.append(_cards, List.make(card));
        };

        public func appendCards(cards : [Card.Card]) {
            for (card in cards.vals()) {appendCard(card);};
        };

        public func popCard() : ?Card.Card {
            let (c, l) = List.pop(_cards);
            _cards := l;
            return c;
        };

        public func fromArray(a : [Card.Card]) {
            for (card in a.vals()) {appendCard(card);};
        };

        public func toArray() : [Card.Card] {
            return List.toArray(_cards);
        };

        public func toText() : Text {
            var result = "[";
            var firstE = true;
            for (card in toArray().vals()) {
                if (firstE) { firstE:= false; }
                else { result #= ", "; };
                result #= "\"" # Card.cardToText(card) # "\"";
            };
            result #= "]";
            return result;
        };

        public func getCardsTypeAndScore() : (CardsType.CardsType, Nat, List.List<Card.Card>) {
            if (List.size(_cards) < 5 or List.size(_cards) > 7) { return (#highcard, 0, List.nil<Card.Card>()); };
            let straightFlush = isStrightFlush(_cards);
            if (straightFlush.0) {return (#strightflush, formatCardsScore(CardsType.cardsTypeToNat(#strightflush), straightFlush.1, straightFlush.2, straightFlush.3, straightFlush.4, straightFlush.5), straightFlush.6); };
            var countTree  = RBTree.RBTree<Nat, Nat>(Nat.compare);
            for (card in Iter.fromList(_cards)) {
                let face = Card.getCardFace(card);
                let count =  countTree.get(face);
                if (Option.isNull(count)) { countTree.put(face, 1); }
                else { countTree.put(face, Option.unwrap(count) + 1); };
            };
            var quard : [Nat] = [];
            var trip : [Nat] = [];
            var pair : [Nat] = [];
            var nopair : [Nat] = [];
            for ((face, count) in countTree.entriesRev()) {
                if (count == 4) { quard := Array.append(quard, [face]); }
                else if (count == 3) { trip := Array.append(trip, [face]); }
                else if (count == 2) { pair := Array.append(pair, [face]); }
                else if (count == 1) { nopair := Array.append(nopair, [face]); };
            };
            if (quard.size() >= 1) {
                var maxNoPair = 0;
                if (trip.size() > 0 and trip[0] > maxNoPair) {maxNoPair := trip[0];};
                if (pair.size() > 0 and pair[0] > maxNoPair) {maxNoPair := pair[0];};
                if (nopair.size() > 0 and nopair[0] > maxNoPair) {maxNoPair := nopair[0];};
                return (#quards, formatCardsScore(CardsType.cardsTypeToNat(#quards), quard[0], quard[0], quard[0], quard[0], maxNoPair), getFiveCardsByFace([quard[0], quard[0], quard[0], quard[0], maxNoPair]));
            };
            if (trip.size() >= 1 and (trip.size() >= 2 or pair.size() >= 1)) {
                var maxTwoPair = 0;
                if (trip.size() >= 2 and trip[1] > maxTwoPair) {maxTwoPair := trip[1];};
                if (pair.size() > 0 and pair[0] > maxTwoPair) {maxTwoPair := pair[0];};
                return (#fullhouse, formatCardsScore(CardsType.cardsTypeToNat(#fullhouse), trip[0], trip[0], trip[0], maxTwoPair, maxTwoPair), getFiveCardsByFace([trip[0], trip[0], trip[0], maxTwoPair, maxTwoPair]));
            };
            let flush = isFlush(_cards);
            if (flush.0) {return (#flush, formatCardsScore(CardsType.cardsTypeToNat(#flush), flush.1, flush.2, flush.3, flush.4, flush.5), flush.6); };
            let straight = isStright(_cards);
            if (straight.0) {return (#straight, formatCardsScore(CardsType.cardsTypeToNat(#straight), straight.1, straight.2, straight.3, straight.4, straight.5), straight.6); };
            if (trip.size() >= 1) { return (#trip, formatCardsScore(CardsType.cardsTypeToNat(#trip), trip[0], trip[0], trip[0], nopair[0], nopair[1]), getFiveCardsByFace([trip[0], trip[0], trip[0], nopair[0], nopair[1]])); };
            if (pair.size() >= 2) {
                var maxNoPair = 0;
                if (pair.size() >= 3 and pair[2] > maxNoPair) {maxNoPair := pair[2];};
                if (nopair.size() > 0 and nopair[0] > maxNoPair) {maxNoPair := nopair[0];};
                return (#twopair, formatCardsScore(CardsType.cardsTypeToNat(#twopair), pair[0], pair[0], pair[1], pair[1], maxNoPair), getFiveCardsByFace([pair[0], pair[0], pair[1], pair[1], maxNoPair]));
            };
            if (pair.size() >= 1) { return (#pair, formatCardsScore(CardsType.cardsTypeToNat(#pair), pair[0], pair[0], nopair[0], nopair[1], nopair[2]), getFiveCardsByFace([pair[0], pair[0], nopair[0], nopair[1], nopair[2]])); };
            return (#highcard, formatCardsScore(CardsType.cardsTypeToNat(#highcard), nopair[0], nopair[1], nopair[2], nopair[3], nopair[4]), getFiveCardsByFace([nopair[0], nopair[1], nopair[2], nopair[3], nopair[4]]));
        };
    }; 

    public func randomCards(tmpSeeds : [Time.Time]) : Cards {
        func gen(a : Nat) : Nat { a };
        let cards = Array.tabulateVar<Nat>(52, gen);
        var seedsInt : Time.Time = 1;
        for (i in Iter.range(0, 10)) {
            if (i < tmpSeeds.size()) {seedsInt*=tmpSeeds[i]}
            else {seedsInt*=Time.now()};
        };
        let seeds = Iter.toArray(Text.toIter(Int.toText(seedsInt)));
        var seedIndex = 0;
        var changeIndex = 0;
        let zero = Char.toNat32('0');
        label run while (seedIndex < seeds.size() and changeIndex < 52) {
            seedIndex += 3;
            if (seedIndex < 20) { continue run; };
            var seed : Nat32 = Char.toNat32(seeds[seedIndex])*100+Char.toNat32(seeds[seedIndex+1])*10+Char.toNat32(seeds[seedIndex+2]);
            let cardIndex = Nat32.toNat(seed%52);
            let temp = cards[cardIndex];
            cards[cardIndex] := cards[changeIndex];
            cards[changeIndex] := temp;
            changeIndex += 1;
        };
        return cardsFromArray(Array.freeze(cards));
    };
};