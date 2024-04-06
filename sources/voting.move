module votingSystem::voteUtils {

use std::simple_map::{Self, SimpleMap};
use std::vector;
use std::signer;
use std::account;

  const USER_IS_NOT_REGISTERED: u64 = 1;
  const USER_HAS_ALREADY_VOTED: u64 = 2;
  const USER_IS_ALREADY_REGISTERED: u64 = 3;
  const CANDIDATE_IS_NOT_REGISTERED: u64 = 4;
  const CANDIDATE_ALREADY_REGISTERED: u64 = 5;


struct voteTracking has store, key  {
    users: SimpleMap<address, bool> 
}

struct candidateVotesCount has store, key {
    voteCount: SimpleMap<address, u64> 
}

public entry fun registerVoters(acc: &signer) {
   let addr = signer::address_of(acc);
   let registered : bool = simple_map::contains_key(&voteTracking.users, addr);
   assert!(registered == true, 3);


   simple_map::add(&mut voteTracking.users, addr, false);

}

public entry fun registerCandidates(acc: &signer) {
   let addr = signer::address_of(acc);
   let registered : bool = simple_map::contains_key(&candidateVotesCount.voteCount, addr);
   assert!(registered == true, 5);


   simple_map::add(&mut candidateVotesCount.voteCount, addr, 0);

}


  public entry fun vote(acc: &signer, candidAdd: address) {
   let addr = signer::address_of(acc);
   let registered : bool = simple_map::contains_key(&voteTracking.users, addr);
    assert!(registered == false, 1);
   let hasVoted : bool = simple_map::borrow(&voteTracking.users, addr);
    assert!(hasVoted == true, 2);

        let candidAvailable : bool = simple_map::contains_key(&candidateVotesCount.voteCount, candidAdd);  
       assert!(candidAvailable == false, 4);
 
        let numVotes = simple_map::borrow(&candidateVotesCount.voteCount, candidAdd);
        simple_map::upsert(&mut candidateVotesCount.voteCount, candidAdd, *numVotes + 1);
        simple_map::upsert(&mut voteTracking.users, addr, true);

}

public fun getNumVoters() : u64 {
  let numVoters : u64  = simple_map::length(&voteTracking.users);
  return numVoters;
}

public fun getCandidateVoteCount(_address: address) : u64 {
 let candidAvailable : bool = simple_map::contains_key(&candidateVotesCount.voteCount, _address);  
  assert!(candidAvailable == false, 4);

let candidVoteCount : u64 = simple_map::borrow(&candidateVotesCount.voteCount, _address);
return candidVoteCount; 

}

public entry fun getWinner() : address {
   let size  = simple_map::length(&candidateVotesCount.voteCount);
   let keys : vector<u64> = simple_map::keys(&candidateVotesCount.voteCount);
    
   let i : u64 = 0;
   let maxVotesCount : u64 = 0;
   let winner : address = 0x00;
    while(i < size){
       let candidate : address = *vector::borrow(&keys, i);
       let votes : u64 = simple_map::borrow(&candidateVotesCount.voteCount, &candidate);
     if(*votes > maxVotesCount){
       maxVotesCount = *votes;
       winner = candidate;
     }
    };
    i = i + 1;
 return winner;
}






#[test(admin = @my_addrx)]
public entry fun test_flow(admin: signer)  {
    let voter = account::create_account_for_test(@0x3)
    registerVoters(&admin);
    registerCandidates(&voter);
    vote(&admin, &voter);
    getCandidateVoteCount(&voter);
    getNumVoters();
    getWinner();
}


#[test(admin = @my_addrx)]
#[expected_failure(abort_code = USER_IS_NOT_REGISTERED)]
public entry fun test_vote_without_being_registered(admin: signer) {
    let voter = account::create_account_for_test(@0x3)
    registerCandidates(&voter);
    vote(&admin, &voter);
}


#[test(admin = @my_addrx)]
#[expected_failure(abort_code = USER_HAS_ALREADY_VOTED)]
public entry fun test_vote_twice(admin: signer)  {
    let voter = account::create_account_for_test(@0x3)
    registerVoters(&admin);
    registerCandidates(&voter);
    vote(&admin, &voter);
    vote(&admin, &voter);
}

#[test(admin = @my_addrx)]
#[expected_failure(abort_code = USER_IS_ALREADY_REGISTERED:)]
public entry fun test_user_already_registered(admin: signer) {
    registerVoters(&admin);
    registerVoters(&admin);
}

#[test(admin = @my_addrx)]
#[expected_failure(abort_code = CANDIDATE_IS_NOT_REGISTERED)]
public entry fun test_vote_for_candidate_not_registered(admin: signer) {
    let voter = account::create_account_for_test(@0x3)
    registerVoters(&admin);
    vote(&admin, &voter);
}


#[test(admin = @my_addrx)]
#[expected_failure(abort_code = CANDIDATE_IS_ALREADY_REGISTERED)]
    public entry fun test_vote_for_candidate_registering_twice(admin: signer) {
    let voter = account::create_account_for_test(@0x3)
    registerCandidates(&voter);
    registerCandidates(&voter);
}

}