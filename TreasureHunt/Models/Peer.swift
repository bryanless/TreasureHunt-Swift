
import Foundation
import MultipeerConnectivity

struct Peer: Hashable {
    var partyId: UUID
    var peerId: MCPeerID?
}
