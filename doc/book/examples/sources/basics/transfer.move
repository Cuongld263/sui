// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module 0x0::container {
    use sui::id::{Self, VersionedID};
    use sui::tx_context::{Self, TxContext};

    /// An object with `store` can be transferred in any
    /// module without a custom transfer implementation.
    struct Container<T: store> has key, store {
        id: VersionedID,
        data: T
    }

    /// View function to read contents of a `Container`.
    public fun contents<T: store>(c: &Container<T>): &T {
        &c.data
    }

    /// Anyone can create a new object
    public fun create<T: store>(
        data: T, ctx: &mut TxContext
    ): Container<T> {
        Container {
            data,
            id: tx_context::new_id(ctx),
        }
    }

    /// Destroy `Container` and get T.
    public fun destroy<T: store> (c: Container<T>): T {
        let Container { id, data } = c;
        id::delete(id);
        data
    }
}

module 0x0::profile {
    use sui::transfer;
    use sui::url::{Self, Url};
    use sui::utf8::{Self, String};
    use sui::tx_context::{Self, TxContext};

    // using Container functionality
    use 0x0::container;

    /// A profile information, not an object, can be wrapped
    /// into a transferable container
    struct ProfileInfo has store {
        name: String,
        url: Url
    }

    /// Read `name` field from `ProfileInfo`.
    public fun name(info: &ProfileInfo): &String {
        &info.name
    }

    /// Read `url` field from `ProfileInfo`.
    public fun url(info: &ProfileInfo): &Url {
        &info.url
    }

    /// Creates new `ProfileInfo` and wraps into `Container`.
    /// Then transfers to sender.
    public fun create_profile(
        name: vector<u8>, url: vector<u8>, ctx: &mut TxContext
    ) {
        // create a new container and wrap ProfileInfo into it
        let container = container::create(ProfileInfo {
            name: utf8::string_unsafe(name),
            url: url::new_unsafe_from_bytes(url)
        }, ctx);

        // `Container` type is freely transferable
        transfer::transfer(container, tx_context::sender(ctx))
    }
}
