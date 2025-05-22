use aztec::macros::aztec;

#[aztec]
pub contract Crowdfunding {
    use dep::aztec::{
        event::event_interface::EventInterface,
        macros::{
            events::event,
            functions::{initializer, utility, private, public},
            storage::storage,
        },
        messages::logs::note::encode_and_encrypt_note,
        prelude::{Map, AztecAddress, PublicMutable, PublicImmutable},
        protocol_types::traits::Packable,
        unencrypted_logs::unencrypted_event_emission::encode_event,
        utils::comparison::Comparator,
    };
    use router::utils::privately_check_timestamp;
    use std::meta::derive;
    use token::Token; 

    #[derive(Packable, Eq)]
    pub struct Config {
        token: AztecAddress,
        beneficiary: AztecAddress,
        goal: u64,
        deadline: u64,
    }

    #[storage]
    struct Storage<Ctx> {
        config: PublicImmutable<Config, Ctx>,
        total_contributions: PublicMutable<u64, Ctx>,
        contributions: Map<AztecAddress, PublicMutable<u64, Ctx>, Ctx>,
    }

    #[initializer]
    #[public]
    pub fn constructor(token: AztecAddress, beneficiary: AztecAddress, goal: u64, deadline: u64) {
        let config =
            Config { token: token, beneficiary: beneficiary, goal: goal, deadline: deadline };
        storage.config.initialize(config);
    }

    #[utility]
    pub unconstrained fn is_funded() -> bool {
        let config = storage.config.read();
        config.goal <= storage.total_contributions.read()
    }

    #[private]
    fn donate(amount: u128) {
        let config = storage.config.read();
        privately_check_timestamp(Comparator.LT, config.deadline, &mut context);

        let kind_man = context.msg_sender();
        Token::at(config.token);
    }
}
