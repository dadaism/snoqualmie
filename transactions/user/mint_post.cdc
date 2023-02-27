import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import SocialPassport from "../../contracts/SocialPassport.cdc"
import SocialPost from "../../contracts/SocialPost.cdc"
import SocialGraph from "../../contracts/SocialGraph.cdc"

transaction(content: String) {
    let client: &{SocialGraph.SocialClient}
    let passportProviderCapability: Capability<&SocialPassport.Collection{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>
    let recipient: &{NonFungibleToken.CollectionPublic}

    prepare(acct: AuthAccount) {
        // borrow a reference to the PassportMinter resource in storage
        self.client = acct.getCapability(SocialGraph.ClientPublicPath)
                        .borrow<&{SocialGraph.SocialClient}>()
                        ?? panic("Could not borrow a reference to the client")
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let passportProviderPrivatePath = /private/SocialPassportCollectionProvider
        if !acct.getCapability<&SocialPassport.Collection{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>(passportProviderPrivatePath).check() {
            acct.link<&SocialPassport.Collection{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>(passportProviderPrivatePath, target: SocialPassport.CollectionStoragePath)
        }
        self.passportProviderCapability = acct.getCapability<&SocialPassport.Collection{NonFungibleToken.Provider, SocialPassport.SocialPassportCollectionPublic}>(passportProviderPrivatePath)
        
        // borrow a public reference to the receivers collection
        self.recipient = acct.borrow<&{NonFungibleToken.CollectionPublic}>(from: SocialPost.CollectionStoragePath)
                            ?? panic("Could not borrow a reference to the Post collection receiver")

    }

    execute {
        let post <- self.client.createPost(
                            content: "You mother fucker", 
                            passportProviderCapability: self.passportProviderCapability
                       )
        self.recipient.deposit(token: <- post)
        log("Post published! ")
    }
}