import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import SocialPassport from "../contracts/SocialPassport.cdc"

// This script returns an array of all the Passports in an account's collection.

pub fun main(address: Address): [PassportData] {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(SocialPassport.CollectionPublicPath)
        .borrow<&SocialPassport.Collection{SocialPassport.SocialPassportCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    var rst: [PassportData] = []
    for id in collectionRef.getIDs() {
        var passportRef = collectionRef.borrowPassport(id: id)!
        var passportData = PassportData()
        passportData.id = id
        passportData.name = passportRef.name
        rst.append(passportData)
    }

    return rst

}

pub struct PassportData {
    pub(set) var id: UInt64
    pub(set) var name: String

    init() {
        self.id = 0
        self.name = ""
    }
}