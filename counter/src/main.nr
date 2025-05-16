use dep::aztec::macros::aztec;

#[aztec]
pub contract Counter {
    use aztec::macros::{functions::{initializer, private,utility}, storage::storage};
    use aztec::prelude::{AztecAddress, Map};
    use aztec::protocol_types::traits::ToField;
    use easy_private_state::EasyPrivateUint;
    use value_note::balance_utils;

    #[storage]
    struct Storage<Context> {
        counters: Map<AztecAddress, EasyPrivateUint<Context>, Context>,
    }



    #[private]
    #[initializer]
    fn init(headstart: u64, _owner: AztecAddress) {
        storage.counters.at(_owner).add(headstart, _owner, context.msg_sender());
    }

    #[private]
    fn increment() {
        //Safety: This is a debug log, and we know that the format string is safe.
        unsafe {
            dep::aztec::oracle::debug_log::debug_log_format(
                "Incrementing counter for {}",
                [context.msg_sender().to_field()],
            );
        }
        storage.counters.at(context.msg_sender()).add(1, context.msg_sender(), context.msg_sender());
    }

    #[private]
    fn decrement() {
        //Safety: This is a debug log, and we know that the format string is safe.
        unsafe {
            dep::aztec::oracle::debug_log::debug_log_format(
                "Decrementing counter for {}",
                [context.msg_sender().to_field()],
            );
        }
        storage.counters.at(context.msg_sender()).sub(1, context.msg_sender(), context.msg_sender());
    }
    #[utility]
    unconstrained fn get_counter(_owner: AztecAddress) -> Field {
        balance_utils::get_balance(storage.counters.at(_owner).set)
    }


}
    
