use dep::aztec::macros::aztec;

#[aztec]
pub contract Voting {
    use aztec::macros::{functions::{initializer, private, public, utility, internal}, storage::storage};
    use aztec::prelude::{AztecAddress, Map};
    use aztec::prelude::PublicMutable;
    use dep::aztec::keys::getters::get_public_keys;
    use value_note::balance_utils;
    use dep::aztec::protocol_types::traits::{Hash, ToField};

    #[storage]
    struct Storage<Ctx> {
        admin: PublicMutable<AztecAddress, Ctx>,
        votes: Map<Field, PublicMutable<Field, Ctx>, Ctx>,
        vote_ended: PublicMutable<bool, Ctx>,
        total_votes: PublicMutable<Field, Ctx>,
    }

    #[public]
    #[initializer]
    fn constructor() {
        storage.admin.write(context.msg_sender());
        storage.vote_ended.write(false);
        storage.total_votes.write(0);
    }

    #[private]
    fn vote(candidate: Field) {
        let voter_npk_m_hash=  get_public_keys(context.msg_sender()).npk_m.hash();
        let secret = context.request_nsk_app(voter_npk_m_hash);
        let nullifier = std::hash::pedersen_hash([
            context.msg_sender().to_field(),
            secret.to_field(),
        ]);
        context.push_nullifier(nullifier);
    }

    #[public]
    #[internal]
    fn update_tally(candidate: Field) {
        assert(storage.vote_ended.read().eq(false), "The vote has already finished");
        let new_votes = storage.votes.at(candidate).read() + 1;
        storage.votes.at(candidate).write(new_votes);
        storage.total_votes.write(storage.total_votes.read() + 1);
    }

    #[utility]
    unconstrained fn get_votes(candidate: Field) -> Field {
        storage.votes.at(candidate).read()
    }
    
    #[public]
    fn end_vote() {
        assert(context.msg_sender().eq(storage.admin.read()), "Only the admin can end the vote");
        storage.vote_ended.write(true);
    }
    #[public]
    fn get_winner() {
        assert(storage.vote_ended.read().eq(true), "The vote has not ended yet");
    }

}
fn main() {}
