
import Foundation
import MultipeerConnectivity

struct Peer: Hashable {
    var name: String = ""
    var partyId: UUID
    var peerId: MCPeerID?
}
