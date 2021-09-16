import Time "mo:base/Time";
import Cards "./Cards";

module {

    public class AccountStatus() {
        public let holeCards : Cards.Cards = Cards.Cards();
        private var _lastOnlineTime : Time.Time = Time.now();
        private let _onlineInterval : Int = 90 * 1_000_000_000;
        private var _isFold = false;
        private var _isAllIn = false;

        public func updateOnlineTime() {
            _lastOnlineTime := Time.now();
        };

        public func isOnline() : Bool {
            return Time.now() - _lastOnlineTime < _onlineInterval;
        };

        public func setFold() {
            _isFold := true;
        };

        public func isFold() : Bool {
            return _isFold;
        };

        public func setAllIn() {
            _isAllIn := true;
        };

        public func isAllIn() : Bool {
            return _isAllIn;
        };
    };

};