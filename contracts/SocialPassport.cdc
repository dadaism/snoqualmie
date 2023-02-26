import NonFungibleToken from "NonFungibleToken.cdc"
import MetadataViews from "MetadataViews.cdc"

pub contract SocialPassport: NonFungibleToken {
    //------------------------------------------------------------
    // Events
    //------------------------------------------------------------
    // Contract Events
    //
    pub event ContractInitialized()

    // NFT Collection (not Genies Collection!) Events
    //
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // NFT Events
    //
    pub event PassportMinted(id: UInt64, name: String)
    pub event PassportBurned(id: UInt64, name: String)

    // Named Paths
    //
    pub let CollectionStoragePath:  StoragePath
    pub let CollectionPublicPath:   PublicPath
    pub let AdminStoragePath: StoragePath
    pub let MinterPrivatePath:  PrivatePath

    // Entity Counts
    //
    pub var totalSupply:  UInt64
    pub var nextPassportID: UInt64

    //------------------------------------------------------------
    // Metadata Dictionaries
    //------------------------------------------------------------
    access(self) let passportIDByName: {String: UInt64}

    //------------------------------------------------------------
    // NFT
    //------------------------------------------------------------
    //
    // A Paspport is an NFT, which would allow the owner to access the social network
    //
    // pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub let name: String
        pub let createdAt: UFix64

        // Destructor
        //
        destroy() {
            emit PassportBurned(id: self.id, name: self.name)
        }

        // Initializer
        init(
            id: UInt64,
            name: String
        ) {
            self.id = id
            self.name = name
            self.createdAt = getCurrentBlock().timestamp

            emit PassportMinted(id: self.id, name: self.name)
        }

        pub fun getViews(): [Type] {
            return []
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            return nil
        }
    }

    // A public collection interface that allows Genies NFTs to be borrowed
    //
    pub resource interface SocialPassportCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        // pub fun borrowGeniesNFT(id: UInt64): &SocialPassport.NFT? {
        //     // If the result isn't nil, the id of the returned reference
        //     // should be the same as the argument to the function
        //     post {
        //         (result == nil) || (result?.id == id):
        //             "Cannot borrow Genies NFT reference: The ID of the returned reference is incorrect"
        //     }
        // }
    }

    // An NFT Collection
    pub resource Collection:
        NonFungibleToken.Provider,
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        // MetadataViews.ResolverCollection
        SocialPassportCollectionPublic
    {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        
        // Collection destructor
        //
        destroy() {
            destroy self.ownedNFTs
        }

        // Collection initializer
         //
        init() {
            self.ownedNFTs <- {}
         }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing Passport")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <- token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @SocialPassport.NFT
            let id: UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // Returns a borrowed reference to an NFT in the collection
        // so that the caller can read data and call methods from it
        pub fun borrowNFT(id: UInt64): &SocialPassport.NFT {
            pre {
                self.ownedNFTs[id] != nil: "NFT does not exist in the collection!"
            }

            return (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! as! &SocialPassport.NFT
        }
        
        // borrowViewResolver
        // Gets a reference to the MetadataViews resolver in the collection,
        // giving access to all metadata information made available.
        //
        // pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
        //     let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        //     let Passport = nft as! &SocialPassport.NFT
        //     return Passport as &AnyResource{MetadataViews.Resolver}
        // }
    }

    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    //------------------------------------------------------------
    // Admin
    //------------------------------------------------------------
    // An interface containing the Admin function that allows minting NFTs
    //
    pub resource interface PassportMinter {
        // Mint a single NFT
        // The Edition for the given ID must already exist
        //
        pub fun mintPassport(name: String): @SocialPassport.NFT
    }

    // A resource that allows managing metadata and minting Passports
    //
    pub resource Minter: PassportMinter {
        // Mint a single Passport NFT
        //
        pub fun mintPassport(name: String): @SocialPassport.NFT {
            pre {
                // Make sure the name we are creating this Passport doesn't exist
                SocialPassport.validateNewName(name: name): "Passport with the name already exists"
            }

            let passport <- create NFT(
                id: SocialPassport.nextPassportID,
                name: name       
            )

            SocialPassport.passportIDByName[name] = passport.id
            SocialPassport.nextPassportID = SocialPassport.nextPassportID + 1 as UInt64

            return <- passport
        }
    }

    pub fun validateNewName(name: String): Bool {
        return !SocialPassport.passportIDByName.containsKey(name.toLower())
    }

    // SocialPassport contract initializer
    //
    init() {
        // Set the named paths
        self.CollectionStoragePath = /storage/SocialPassportCollection
        self.CollectionPublicPath = /public/SocialPassportCollection
        self.AdminStoragePath = /storage/SocialPassportAdmin
        self.MinterPrivatePath = /private/SocialPassportMinter

        // Initialize the entity counts
        self.totalSupply = 0
        self.nextPassportID = 0

        // Initialize the metadata lookup dictionaries
        self.passportIDByName = {}

        // Create an Admin resource and save it to storage
        let admin <- create Minter()
        self.account.save(<-admin, to: self.AdminStoragePath)
        // Link capabilites to the admin constrained to the Minter
        // and Metadata interfaces
        self.account.link<&SocialPassport.Minter{SocialPassport.PassportMinter}>(
            self.MinterPrivatePath,
            target: self.AdminStoragePath
        )
    }
}