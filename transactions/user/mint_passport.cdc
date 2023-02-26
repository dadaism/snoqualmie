import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import SocialPassport from "../../contracts/SocialPassport.cdc"

transaction(recipientAddr: Address) {
    let minter: &{SocialPassport.PassportMinter}
    let recipient: &{NonFungibleToken.CollectionPublic}
    prepare(acct: AuthAccount) {
        // borrow a reference to the PassportMinter resource in storage
        self.minter = acct.getCapability(SocialPassport.MinterPrivatePath)
                        .borrow<&{SocialPassport.PassportMinter}>()
                        ?? panic("Could not borrow a reference to the Passport minter")
        
        let recipientAcct = getAccount(recipientAddr)

        // borrow a public reference to the receivers collection
        self.recipient = recipientAcct.getCapability(SocialPassport.CollectionPublicPath)
                            .borrow<&{NonFungibleToken.CollectionPublic}>()
                            ?? panic("Could not borrow a reference to the collection receiver")
    }

    execute {
       let passport <- self.minter.mintPassport(name: "0x01")
       self.recipient.deposit(token: <- passport)
        // log(HelloWorld.hello())
    }
}