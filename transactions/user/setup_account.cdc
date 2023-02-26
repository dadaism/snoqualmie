import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import SocialPassport from "../../contracts/SocialPassport.cdc"

transaction() {
    prepare(acct: AuthAccount) {
        // if the account doesn't already have a passport collection in storage
        if acct.borrow<&SocialPassport.Collection>(from: SocialPassport.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- SocialPassport.createEmptyCollection()
            // save it to the account
            acct.save(<-collection, to: SocialPassport.CollectionStoragePath)
        }

        // create a public capability for the collection
        acct.link<&SocialPassport.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(
            SocialPassport.CollectionPublicPath,
            target: SocialPassport.CollectionStoragePath
        )

        if (!acct.getCapability(SocialPassport.CollectionPublicPath)
                .check<&SocialPassport.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>()
        ) {
            panic("Failed to get capability")
        }        
    }

    execute {
        log("Successfully setup your account for Social")
    }
}