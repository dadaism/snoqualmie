import NonFungibleToken from "NonFungibleToken.cdc"
import SocialPassport from "SocialPassport.cdc"
import SocialPost from "SocialPost.cdc"

pub contract SocialGraph {
    //------------------------------------------------------------
    // Events
    //------------------------------------------------------------
    // Contract Events
    //
    pub event ContractInitialized()

    pub event PassportCreated(user: Address, name: String)

    // Named Paths
    pub let ClientStoragePath: StoragePath
    pub let ClientPublicPath: PublicPath

    pub var totalPassport: UInt128
    pub var nextPassportID: UInt128

    //------------------------------------------------------------
    // Metadata Dictionaries
    //------------------------------------------------------------
    access(contract) let postsOwnedByPassport: {UInt64: [UInt64]}
    // access(self) let passportByID: @{UInt128: Passport}
    // access(self) let followersByID: {UInt128: [UInt128]}


    // pub fun addPassport (
    //     passportName: String,
    //     passportMetadata: {String: String}
    // ): UInt128 {
    //     pre {
    //         !SocialRegistry.passportIDByName.containsKey(passportName.toLower()): "Passport with the name already exists"
    //     }

    //     let passport <- create self.Passport(
    //         passportID: self.nextPassportID,
    //         passportName: passportName,
    //         metadata: passportMetadata
    //     )
        
    //     let passportID = passport.id
    //     self.passportByID[passportID] <-! passport
    //     self.passportIDByName[passportName.toLower()] = passportID
    //     self.nextPassportID = self.nextPassportID + 1
    
    //     return passportID
    // }

    // pub fun addFollower (
    //     passportID: UInt128,
    //     followerID: UInt128
    // ): Bool {
    //     pre {
    //         // Passport with the ID (people to follow) should exist
    //         SocialRegistry.passportByID.containsKey(passportID): "Passport with the ID doesn't exist"
    //     }
    //     if (!SocialRegistry.followersByID.containsKey(passportID)) {    // The first follower
    //         SocialRegistry.followersByID.insert(key: passportID, [followerID])
    //     } else {    // Already have a list of followers
    //         let followers = SocialRegistry.followersByID[passportID]!
    //         if (!followers.contains(followerID)) {  // Dedup just in case
    //             followers.append(followerID)
    //         }
    //     }
    //     return true
    // }

    pub resource interface SocialClient {
        pub fun createUser(name: String): @SocialPassport.NFT
        pub fun createPost(content: String, passportProviderCapability: Capability<&{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>): @SocialPost.NFT 

    }

    pub resource Client: SocialClient {
        // access(self) let passportMinter: @SocialPassport.Minter
        access(self) let passportMinterCapability: Capability<&{SocialPassport.PassportMinter}>
        access(self) let postMinterCapability: Capability<&{SocialPost.PostMinter}>

        pub fun createUser(name: String): @SocialPassport.NFT {
            // return <- self.passportMinter.mintPassport(name: name)
            let passport <- self.passportMinterCapability.borrow()!.mintPassport(name: name)
            return <- passport
        }

        pub fun createPost(content: String, passportProviderCapability: Capability<&{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>): @SocialPost.NFT {
            // Check whether the Passport is owned by the transaction sender
            let provider = passportProviderCapability.borrow()
            assert(provider != nil, message: "cannot borrow passportProviderCapability. does the sender own the passport?")

            // Always get the first passport for now.
            // TODO: allow owner to pick up among multiple passports
            let refPassport = provider!.borrowNFT(id: 0)
            // let post <- self.passportMinter.mintPost(content: content)
            let post <- self.postMinterCapability.borrow()!.mintPost(content: content, passportID: refPassport.id)
            if (!SocialGraph.postsOwnedByPassport.containsKey(refPassport.id)) {   // The first post
                SocialGraph.postsOwnedByPassport.insert(key: refPassport.id, [post.id])
            } else {    // Already have posts
                let postIDs = SocialGraph.postsOwnedByPassport[refPassport.id]!
                if (!postIDs.contains(post.id)) {  // Avoid duplicates just in case
                    postIDs.append(post.id)
                }
            }
            
            return <- post
        }

        init(
            passportMinterCapability: Capability<&{SocialPassport.PassportMinter}>,
            postMinterCapability: Capability<&{SocialPost.PostMinter}>
        ) {
            // self.passportMinter <- passportMinter
            self.passportMinterCapability = passportMinterCapability
            self.postMinterCapability = postMinterCapability
        }

        destroy () {
            // destroy self.passportMinter
        }
    }

    init() {
        // Set the named paths
        self.ClientStoragePath = /storage/SnoqualmieSocialClient
        self.ClientPublicPath =  /public/SnoqualmieSocialClient

        // Initialize the counts
        self.totalPassport = 0
        self.nextPassportID = 0

        // Initialize the metadata lookup dictionaries
        self.postsOwnedByPassport = {}
        // self.passportByID <- {}
        // self.followersByID = {}

        // Create a Social Client resource
        // borrow a reference to the PassportMinter resource in storage
        // let minter <- self.account.load<@SocialPassport.Minter>(from: SocialPassport.AdminStoragePath)!
        let client <- create Client(
            // passportMinter: <- minter, 
            passportMinterCapability: self.account.getCapability<&{SocialPassport.PassportMinter}>(SocialPassport.MinterPrivatePath),
            postMinterCapability: self.account.getCapability<&{SocialPost.PostMinter}>(SocialPost.MinterPrivatePath)
        )
        self.account.save(<-client, to: self.ClientStoragePath)
        self.account.link<&SocialGraph.Client{SocialGraph.SocialClient}>(
            self.ClientPublicPath,
            target: self.ClientStoragePath
        )
    }

}