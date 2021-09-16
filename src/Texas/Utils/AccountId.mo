/**
Generates AccountIdentifier's for the IC (32 bytes). Use with 
hex library to generate corresponding hex address.
Uses custom SHA224 and CRC32 motoko libraries
 */

import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Array "mo:base/Array";
import SHA224 "./SHA224";
import CRC32 "./CRC32";
import Hex "./Hex";

module {

  private let ads : [Nat8] = [10, 97, 99, 99, 111, 117, 110, 116, 45, 105, 100]; //b"\x0Aaccount-id"
  private let sa_zero : [Nat8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

  public type Address = Text;
  public let equal = Text.equal;
  public let hash = Text.hash;

  public func fromText(t : Text, sa : ?[Nat8]) : Address {
    return fromPrincipal(Principal.fromText(t), sa);
  };

  public func fromPrincipal(p : Principal, sa : ?[Nat8]) : Address {
    return fromBlob(Principal.toBlob(p), sa);
  };

  public func fromBlob(b : Blob, sa : ?[Nat8]) : Address {
    return generate(Blob.toArray(b), sa);
  };

  public func generate(data : [Nat8], sa : ?[Nat8]) : Address {
    var _sa : [Nat8] = sa_zero;
    if (Option.isSome(sa)) {
      _sa := Option.unwrap(sa);
    };
    var hash : [Nat8] = SHA224.sha224(Array.append(Array.append(ads, data), _sa));
    var crc : [Nat8] = CRC32.crc32(hash);
    return Hex.encode(Array.append(crc, hash));
  };

  public func valid(address : Address) : Bool {
    if (address.size() != 64) { return false; };
    if (Hex.decode(address).size() != 32) { return false; };
    return true;
  }

};