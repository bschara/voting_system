module votingSystem::voteUtils {

use std::simple_map::{Self, SimpleMap};
use std::vector;
use std::signer;

  const USER_IS_NOT_REGISTERED: u64 = 1;
  const USER_HAS_ALREADY_VOTED: u64 = 2;
  const USER_IS_ALREADY_REGISTERED: u64 = 3;


struct voteTracking has store, key  {
    users: SimpleMap<address, bool> 
}

struct candidateVotesCount has store, key {
    voteCount: SimpleMap<address, u64> 
}

public fun registerVoters(acc: &signer) {
   let registered : bool = simple_map::contains_key(&voteTracking, addr);
   assert!(registered == true, 3);


   let addr = signer::address_of(acc);
   simple_map::add(&mut voteTracking, addr, false);
   simple_map::add(&mut candidateVotesCount, addr, 0);

}

  public fun vote(acc: &signer, candidAdd: address) {
   let addr = signer::address_of(acc);
   let registered : bool = simple_map::contains_key(&voteTracking, addr);
   let hasVoted : bool = simple_map::find(&voteTracking, addr);
        
        assert!(registered == false, 1);
        assert!(hasVoted == true, 2);
            
        let numVotes = simple_map::find(&mut candidateVotesCount, candidAdd);
        simple_map::upsert(&mut candidateVotesCount, candidAdd, numVotes + 1);
        simple_map::upsert(&mut voteTracking, addr, true);

}

public fun getNumVoters() : u64 {
  let numVoters : u64  = simple_map::length(&voteTracking);
  return numVoters;
}

public fun getCandidateVoteCount(_address: address) : u64 {
let candidVoteCount : u64 = simple_map::find(&candidateVotesCount, _address);
return candidVoteCount; 

}

public fun getWinner() : address {
   let size  = simple_map::length(&candidateVotesCount);
   let keys : vector<u64> = simple_map::keys(&candidateVotesCount);
    
   let i : u64 = 0;
   let maxVotesCount : u64 = 0;
   let winner : address = 0x00;
    while(i < size){
       let candidate : address = *vector::borrow(&keys, i);
       let votes : u64 = simple_map::borrow(&candidateVotesCount, &candidate);
     if(*votes > maxVotesCount){
       maxVotesCount = *votes;
       winner = candidate;
     }
    };
    i = i + 1;
 return winner;
}

}