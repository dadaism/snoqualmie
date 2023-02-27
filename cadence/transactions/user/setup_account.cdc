import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import SocialPassport from "../../contracts/SocialPassport.cdc"
import SocialPost from "../../contracts/SocialPost.cdc"

transaction() {
    prepare(acct: AuthAccount) {
        // Initialize for the Passport
        // if the account doesn't already have a passport collection in storage
        if acct.borrow<&SocialPassport.Collection>(from: SocialPassport.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- SocialPassport.createEmptyCollection()
            // save it to the account
            acct.save(<-collection, to: SocialPassport.CollectionStoragePath)
        }

        // create a public capability for the collection
        acct.link<&SocialPassport.Collection{NonFungibleToken.Receiver, SocialPassport.SocialPassportCollectionPublic}>(
            SocialPassport.CollectionPublicPath,
            target: SocialPassport.CollectionStoragePath
        )

        // Initialize for the Post
        // if the account doesn't already have a post collection in storage
        if acct.borrow<&SocialPost.Collection>(from: SocialPost.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- SocialPost.createEmptyCollection()
            // save it to the account
            acct.save(<-collection, to: SocialPost.CollectionStoragePath)
        }

        // create a public capability for the collection
        acct.link<&SocialPost.Collection{NonFungibleToken.Receiver, SocialPost.PostCollectionPublic}>(
            SocialPost.CollectionPublicPath,
            target: SocialPost.CollectionStoragePath
        )
        

        if (!acct.getCapability(SocialPassport.CollectionPublicPath)
                .check<&SocialPassport.Collection{NonFungibleToken.Receiver, SocialPassport.SocialPassportCollectionPublic}>()
        ) {
            panic("Failed to get capability")
        }        
    }

    execute {
        log("Successfully setup your account for Social")
    }
}